import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../rede/cliente_api.dart';

class Sessao {
  const Sessao({
    this.token,
    this.usuario,
    this.papel,
    this.agenciaId = 0,
    this.carregada = false,
  });

  final String? token;
  final String? usuario;
  final String? papel;
  final int agenciaId;
  final bool carregada;

  bool get autenticada => token != null;
  bool get operador => papel == 'operador';

  Sessao copiar({String? token, String? usuario, String? papel, int? agenciaId, bool? carregada, bool limparToken = false}) => Sessao(
        token: limparToken ? null : (token ?? this.token),
        usuario: limparToken ? null : (usuario ?? this.usuario),
        papel: limparToken ? null : (papel ?? this.papel),
        agenciaId: agenciaId ?? this.agenciaId,
        carregada: carregada ?? this.carregada,
      );
}

abstract class ArmazenamentoSessao {
  Future<String?> ler(String chave);
  Future<void> gravar(String chave, String valor);
  Future<void> apagar(String chave);
}

class ArmazenamentoSeguro implements ArmazenamentoSessao {
  const ArmazenamentoSeguro();

  static const _armazem = FlutterSecureStorage();

  @override
  Future<String?> ler(String chave) => _armazem.read(key: chave);

  @override
  Future<void> gravar(String chave, String valor) => _armazem.write(key: chave, value: valor);

  @override
  Future<void> apagar(String chave) => _armazem.delete(key: chave);
}

Map<String, dynamic> lerPayloadJwt(String token) {
  final partes = token.split('.');
  if (partes.length != 3) return const {};
  final texto = utf8.decode(base64Url.decode(base64Url.normalize(partes[1])));
  return Map<String, dynamic>.from(jsonDecode(texto) as Map);
}

final armazenamentoProvider = Provider<ArmazenamentoSessao>((ref) => const ArmazenamentoSeguro());

final apiProvider = Provider<ClienteApi>((ref) => ClienteApi(() => ref.read(sessaoProvider).token));

final sessaoProvider = NotifierProvider<SessaoNotifier, Sessao>(SessaoNotifier.new);

class SessaoNotifier extends Notifier<Sessao> {
  @override
  Sessao build() => const Sessao();

  ArmazenamentoSessao get _armazem => ref.read(armazenamentoProvider);

  Future<void> restaurar() async {
    final token = await _armazem.ler('token');
    final agencia = int.tryParse(await _armazem.ler('agencia') ?? '') ?? 0;
    if (token == null) {
      state = state.copiar(agenciaId: agencia, carregada: true);
      return;
    }
    final payload = lerPayloadJwt(token);
    final exp = (payload['exp'] as num?)?.toInt();
    if (exp != null && DateTime.fromMillisecondsSinceEpoch(exp * 1000).isBefore(DateTime.now())) {
      await _armazem.apagar('token');
      state = state.copiar(agenciaId: agencia, carregada: true);
      return;
    }
    state = Sessao(
      token: token,
      usuario: payload['sub'] as String?,
      papel: payload['papel'] as String?,
      agenciaId: agencia,
      carregada: true,
    );
  }

  Future<void> entrar(int agencia, String usuario, String senha) async {
    final token = await ref.read(apiProvider).login(agencia, usuario.trim(), senha);
    final payload = lerPayloadJwt(token);
    await _armazem.gravar('token', token);
    await _armazem.gravar('agencia', '$agencia');
    state = Sessao(
      token: token,
      usuario: payload['sub'] as String?,
      papel: payload['papel'] as String?,
      agenciaId: agencia,
      carregada: true,
    );
  }

  Future<void> trocarAgencia(int agencia) async {
    await _armazem.gravar('agencia', '$agencia');
    state = state.copiar(agenciaId: agencia);
  }

  Future<void> sair() async {
    await _armazem.apagar('token');
    state = state.copiar(limparToken: true);
  }
}
