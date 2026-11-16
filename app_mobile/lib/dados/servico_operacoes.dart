import 'package:uuid/uuid.dart';

import '../core/rede/cliente_api.dart';
import 'modelos.dart';
import 'modelos_locais.dart';

class ErroOffline implements Exception {
  const ErroOffline(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

class ResultadoOperacao {
  const ResultadoOperacao({required this.pendente, required this.mensagem});

  final bool pendente;
  final String mensagem;
}

class ServicoOperacoes {
  ServicoOperacoes(this._api, this._repo, [Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  final ClienteApi _api;
  final RepositorioLocal _repo;
  final Uuid _uuid;

  Future<ContaDto> consultar(int agencia, int id) async {
    final conta = await _api.consultarConta(agencia, id);
    await _repo.salvarConta(conta, agencia);
    return conta;
  }

  Future<bool> _temFila(int agencia) async {
    final todas = await _repo.observarOperacoes().first;
    return todas.any((o) => o.agencia == agencia && (o.status.aguardando || o.status == StatusOperacao.conflito));
  }

  Future<ResultadoOperacao> movimentar(
    TipoOperacao tipo, {
    required int agencia,
    required int idConta,
    required double valor,
  }) async {
    if (!await _temFila(agencia)) {
      try {
        final conta = tipo == TipoOperacao.deposito
            ? await _api.depositar(agencia, idConta, valor)
            : await _api.sacar(agencia, idConta, valor);
        await _repo.salvarConta(conta, agencia);
        return ResultadoOperacao(
          pendente: false,
          mensagem: tipo == TipoOperacao.deposito ? 'Depósito aplicado.' : 'Saque aplicado.',
        );
      } on ErroRede {
        // cai para a fila abaixo
      }
    }
    return _enfileirar(tipo, agencia: agencia, idConta: idConta, valor: valor);
  }

  Future<ResultadoOperacao> transferir({
    required int agencia,
    required int origem,
    required int destino,
    required double valor,
  }) async {
    if (!await _temFila(agencia)) {
      try {
        final r = await _api.transferir(agencia, origem, destino, valor);
        try {
          await consultar(agencia, origem);
        } on Object {
          // saldo é atualizado na próxima consulta
        }
        return ResultadoOperacao(pendente: false, mensagem: r.mensagem);
      } on ErroRede {
        // cai para a fila abaixo
      }
    }
    return _enfileirar(TipoOperacao.transferencia, agencia: agencia, idConta: origem, valor: valor, idDestino: destino);
  }

  Future<ResultadoOperacao> _enfileirar(
    TipoOperacao tipo, {
    required int agencia,
    required int idConta,
    required double valor,
    int? idDestino,
  }) async {
    final cache = await _repo.buscarConta(idConta);
    if (cache == null) {
      throw const ErroOffline('Consulte esta conta com conexão antes de operar offline.');
    }
    final pendentes = (await _repo.observarOperacoes().first).where((o) => o.idConta == idConta && o.status.aguardando);
    final provisorio = pendentes.fold<double>(cache.saldo, (s, o) => s + o.efeitoNoSaldo);
    if (tipo != TipoOperacao.deposito && provisorio < valor) {
      throw const ErroOffline('Saldo provisório insuficiente para esta operação.');
    }
    await _repo.criarOperacao(
      OperacaoLocal(
        idOperacao: _uuid.v4(),
        idConta: idConta,
        agencia: agencia,
        tipo: tipo,
        valor: valor,
        idDestino: idDestino,
        vetorConhecido: cache.vetorAtual,
        criadoEm: DateTime.now(),
        status: StatusOperacao.pendente,
      ),
    );
    return const ResultadoOperacao(
      pendente: true,
      mensagem: 'Sem conexão. Operação guardada como pendente e será sincronizada sozinha.',
    );
  }
}
