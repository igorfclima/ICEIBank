import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../dados/modelos.dart';

const _host = String.fromEnvironment('ICEI_HOST', defaultValue: kIsWeb ? '127.0.0.1' : '10.0.2.2');
const _portaBase = int.fromEnvironment('ICEI_PORTA_BASE', defaultValue: 4063);
const totalAgencias = 3;

String urlDaAgencia(int id) => 'http://$_host:${_portaBase + id}';

class ErroRede implements Exception {
  const ErroRede([this.mensagem = 'Sem conexão com a agência.']);
  final String mensagem;

  @override
  String toString() => mensagem;
}

class ErroApi implements Exception {
  const ErroApi(this.status, this.mensagem, [this.corpo]);
  final int status;
  final String mensagem;
  final Map<String, dynamic>? corpo;

  bool get sessaoExpirada => status == 401;
  bool get conflito => status == 409;

  @override
  String toString() => mensagem;
}

class ClienteApi {
  ClienteApi(this._token, {Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 4),
                sendTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 8),
                validateStatus: (_) => true,
              ),
            );

  final Dio _dio;
  final String? Function() _token;

  Future<Map<String, dynamic>> _chamar(
    String metodo,
    int agencia,
    String caminho, {
    Object? corpo,
    Duration? limite,
    bool autenticada = true,
  }) async {
    final token = _token();
    final Response<dynamic> resposta;
    try {
      resposta = await _dio.request<dynamic>(
        '${urlDaAgencia(agencia)}$caminho',
        data: corpo,
        options: Options(
          method: metodo,
          headers: {
            'Content-Type': 'application/json',
            if (autenticada) 'Authorization': ?(token == null ? null : 'Bearer $token'),
          },
          sendTimeout: limite,
          receiveTimeout: limite,
        ),
      );
    } on DioException catch (e) {
      throw ErroRede(
        e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout
            ? 'A agência demorou demais para responder.'
            : 'Sem conexão com a agência $agencia.',
      );
    }
    final dados = resposta.data;
    final mapa = dados is Map ? Map<String, dynamic>.from(dados) : <String, dynamic>{};
    final status = resposta.statusCode ?? 0;
    if (status >= 400) {
      throw ErroApi(status, mapa['erro'] as String? ?? 'Erro $status', mapa);
    }
    return mapa;
  }

  Future<String> login(int agencia, String usuario, String senha) async {
    final r = await _chamar(
      'POST',
      agencia,
      '/auth/login',
      corpo: {'usuario': usuario, 'senha': senha},
      autenticada: false,
    );
    return r['token'] as String;
  }

  Future<ContaDto> consultarConta(int agencia, int id) async =>
      ContaDto.fromJson(await _chamar('GET', agencia, '/contas/$id'));

  Future<List<EventoDto>> historico(int agencia, int id, {int limite = 10}) async {
    final r = await _chamar('GET', agencia, '/contas/$id/historico?limite=$limite');
    return (r['eventos'] as List).map((e) => EventoDto.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<ContaDto> depositar(int agencia, int id, double valor) async =>
      ContaDto.fromJson(await _chamar('POST', agencia, '/contas/$id/depositar', corpo: {'valor': valor}));

  Future<ContaDto> sacar(int agencia, int id, double valor) async =>
      ContaDto.fromJson(await _chamar('POST', agencia, '/contas/$id/sacar', corpo: {'valor': valor}));

  Future<ResultadoTransferencia> transferir(int agencia, int origem, int destino, double valor) async =>
      ResultadoTransferencia.fromJson(
        await _chamar(
          'POST',
          agencia,
          '/transferencias',
          corpo: {'idOrigem': origem, 'idDestino': destino, 'valor': valor},
        ),
      );

  Future<ContaDto> sincronizar(
    int agencia,
    int idConta, {
    required String idOperacao,
    required TipoOperacao tipo,
    required double valor,
    required List<int> vetorConhecido,
    int? idDestino,
  }) async =>
      ContaDto.fromJson(
        await _chamar(
          'POST',
          agencia,
          '/contas/$idConta/sincronizar',
          corpo: {
            'idOperacao': idOperacao,
            'tipo': tipo.codigo,
            'valor': valor,
            'vetorConhecido': vetorConhecido,
            'idDestino': ?idDestino,
          },
        ),
      );

  Future<Lideranca> lideranca(int agencia) async => Lideranca.fromJson(
        await _chamar('GET', agencia, '/bully/lider', limite: const Duration(seconds: 2), autenticada: false),
      );
}
