import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/rede/cliente_api.dart';
import 'core/sessao/sessao.dart';
import 'dados/banco.dart';
import 'dados/modelos.dart';
import 'dados/modelos_locais.dart';
import 'dados/servico_operacoes.dart';
import 'funcionalidades/sincronizacao/servico_sincronizacao.dart';

final bancoProvider = Provider<BancoLocal>((ref) {
  final banco = BancoLocal();
  ref.onDispose(banco.close);
  return banco;
});

final repositorioProvider = Provider<RepositorioLocal>((ref) => RepositorioDrift(ref.watch(bancoProvider)));

final operacoesProvider = Provider<ServicoOperacoes>(
  (ref) => ServicoOperacoes(ref.watch(apiProvider), ref.watch(repositorioProvider)),
);

final servicoSincronizacaoProvider = Provider<ServicoSincronizacao>(
  (ref) => ServicoSincronizacao(ref.watch(apiProvider), ref.watch(repositorioProvider)),
);

final conectividadeProvider = StreamProvider<bool>((ref) async* {
  final conectividade = Connectivity();
  bool conectado(List<ConnectivityResult> r) => r.any((e) => e != ConnectivityResult.none);
  yield conectado(await conectividade.checkConnectivity());
  yield* conectividade.onConnectivityChanged.map(conectado);
});

final contaSelecionadaProvider = NotifierProvider<ContaSelecionada, int?>(ContaSelecionada.new);

class ContaSelecionada extends Notifier<int?> {
  @override
  int? build() => null;

  void definir(int? id) => state = id;
}

final contaLocalProvider = StreamProvider.family<ContaLocal?, int>(
  (ref, id) => ref.watch(repositorioProvider).observarConta(id),
);

final operacoesLocaisProvider = StreamProvider<List<OperacaoLocal>>(
  (ref) => ref.watch(repositorioProvider).observarOperacoes(),
);

final lancamentosProvider = FutureProvider.family.autoDispose<List<EventoDto>, int>((ref, id) {
  final sessao = ref.watch(sessaoProvider);
  if (!sessao.autenticada) return const <EventoDto>[];
  return ref.watch(apiProvider).historico(id % totalAgencias, id);
});

class Aviso {
  const Aviso(this.texto, {this.erro = false});
  final String texto;
  final bool erro;
}

final avisosProvider = NotifierProvider<AvisosNotifier, Aviso?>(AvisosNotifier.new);

class AvisosNotifier extends Notifier<Aviso?> {
  @override
  Aviso? build() => null;

  void mostrar(String texto, {bool erro = false}) => state = Aviso(texto, erro: erro);

  void limpar() => state = null;
}

class EstadoSincronizacao {
  const EstadoSincronizacao({this.emAndamento = false});
  final bool emAndamento;
}

final sincronizacaoProvider = NotifierProvider<SincronizacaoNotifier, EstadoSincronizacao>(SincronizacaoNotifier.new);

class SincronizacaoNotifier extends Notifier<EstadoSincronizacao> {
  @override
  EstadoSincronizacao build() => const EstadoSincronizacao();

  Future<void> executar() async {
    if (state.emAndamento || !ref.read(sessaoProvider).autenticada) return;
    state = const EstadoSincronizacao(emAndamento: true);
    try {
      final r = await ref.read(servicoSincronizacaoProvider).sincronizar();
      _anunciar(r);
      if (r.houveMudanca) ref.invalidate(lancamentosProvider);
    } finally {
      state = const EstadoSincronizacao();
    }
  }

  Future<void> aplicarComEstadoAtual(OperacaoLocal op) async {
    state = const EstadoSincronizacao(emAndamento: true);
    try {
      final r = await ref.read(servicoSincronizacaoProvider).aplicarComEstadoAtual(op);
      _anunciar(r);
      if (r.houveMudanca) ref.invalidate(lancamentosProvider);
    } finally {
      state = const EstadoSincronizacao();
    }
  }

  Future<void> descartar(OperacaoLocal op) => ref.read(servicoSincronizacaoProvider).descartar(op);

  void _anunciar(ResultadoSincronizacao r) {
    final avisos = ref.read(avisosProvider.notifier);
    if (r.sessaoExpirada) {
      ref.read(sessaoProvider.notifier).sair();
      avisos.mostrar('Sua sessão expirou. Entre novamente para sincronizar.', erro: true);
    } else if (r.conflitos > 0) {
      avisos.mostrar('A sincronização encontrou um conflito. Revise a operação pendente.', erro: true);
    } else if (r.rejeitadas > 0) {
      avisos.mostrar('Uma operação foi recusada pela agência.', erro: true);
    } else if (r.aplicadas > 0) {
      avisos.mostrar(r.aplicadas == 1 ? 'Operação sincronizada.' : '${r.aplicadas} operações sincronizadas.');
    }
  }
}

sealed class EstadoLideranca {
  const EstadoLideranca(this.ativas);
  final Map<int, bool> ativas;
}

class LiderancaCarregando extends EstadoLideranca {
  const LiderancaCarregando() : super(const {});
}

class LiderancaSemResposta extends EstadoLideranca {
  const LiderancaSemResposta(super.ativas, this.ultimoLider);
  final int? ultimoLider;
}

class LiderancaEmEleicao extends EstadoLideranca {
  const LiderancaEmEleicao(super.ativas);
}

class LiderancaDefinida extends EstadoLideranca {
  const LiderancaDefinida(super.ativas, this.lider, this.desde);
  final int lider;
  final DateTime? desde;
}

final abaAtualProvider = NotifierProvider<AbaAtual, int>(AbaAtual.new);

class AbaAtual extends Notifier<int> {
  @override
  int build() => 0;

  void definir(int indice) => state = indice;
}

const abaAgencias = 2;
const intervaloAbaAtiva = Duration(seconds: 5);
const intervaloAbaOculta = Duration(seconds: 15);

Future<EstadoLideranca> consultarLideranca(ClienteApi api, int? ultimoLider) async {
  final resultados = await Future.wait(
    List.generate(totalAgencias, (i) => api.lideranca(i).then<Lideranca?>((l) => l).catchError((_) => null)),
  );
  final ativas = {for (var i = 0; i < totalAgencias; i++) i: resultados[i] != null};
  final respostas = resultados.whereType<Lideranca>().toList();
  if (respostas.isEmpty) return LiderancaSemResposta(ativas, ultimoLider);
  final lideres = respostas.map((r) => r.liderAtual).whereType<int>().toSet();
  if (lideres.length != 1) return LiderancaEmEleicao(ativas);
  final lider = lideres.first;
  final registro = respostas.where((r) => r.idAgencia == lider).firstOrNull ?? respostas.firstWhere((r) => r.liderAtual == lider);
  return LiderancaDefinida(ativas, lider, registro.desde);
}

final liderancaProvider = StreamProvider<EstadoLideranca>((ref) async* {
  final api = ref.watch(apiProvider);
  int? ultimo;
  while (true) {
    final emPrimeiroPlano = WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused;
    if (emPrimeiroPlano) {
      final estado = await consultarLideranca(api, ultimo);
      if (estado is LiderancaDefinida) ultimo = estado.lider;
      yield estado;
    }
    final naAba = ref.read(abaAtualProvider) == abaAgencias;
    await Future<void>.delayed(naAba ? intervaloAbaAtiva : intervaloAbaOculta);
  }
});
