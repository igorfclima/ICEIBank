import '../../core/rede/cliente_api.dart';
import '../../dados/modelos.dart';
import '../../dados/modelos_locais.dart';

class ResultadoSincronizacao {
  const ResultadoSincronizacao({
    this.aplicadas = 0,
    this.conflitos = 0,
    this.rejeitadas = 0,
    this.semConexao = false,
    this.sessaoExpirada = false,
  });

  final int aplicadas;
  final int conflitos;
  final int rejeitadas;
  final bool semConexao;
  final bool sessaoExpirada;

  bool get houveMudanca => aplicadas + conflitos + rejeitadas > 0;
}

class ServicoSincronizacao {
  ServicoSincronizacao(this._api, this._repo);

  final ClienteApi _api;
  final RepositorioLocal _repo;
  bool _emAndamento = false;

  bool get emAndamento => _emAndamento;

  Future<ResultadoSincronizacao> sincronizar() async {
    if (_emAndamento) return const ResultadoSincronizacao();
    _emAndamento = true;
    var aplicadas = 0;
    var conflitos = 0;
    var rejeitadas = 0;
    final bloqueadas = <int>{};
    try {
      while (true) {
        final fila = (await _repo.operacoesAguardando()).where((o) => !bloqueadas.contains(o.agencia));
        if (fila.isEmpty) break;
        final op = fila.first;
        await _repo.atualizarOperacao(op.copiar(status: StatusOperacao.enviando));
        try {
          final conta = await _api.sincronizar(
            op.agencia,
            op.idConta,
            idOperacao: op.idOperacao,
            tipo: op.tipo,
            valor: op.valor,
            vetorConhecido: op.vetorConhecido,
            idDestino: op.idDestino,
          );
          await _repo.atualizarOperacao(op.copiar(status: StatusOperacao.sincronizada));
          await _repo.salvarConta(conta, op.agencia);
          await _repo.atualizarVetorDosPendentes(op.agencia, conta.vetorAtual);
          aplicadas++;
        } on ErroApi catch (e) {
          if (e.conflito) {
            await _guardarEstadoReal(op, e.corpo ?? const {});
            await _repo.atualizarOperacao(op.copiar(status: StatusOperacao.conflito, resposta: e.corpo));
            bloqueadas.add(op.agencia);
            conflitos++;
          } else if (e.sessaoExpirada) {
            await _repo.atualizarOperacao(op.copiar(status: StatusOperacao.pendente));
            return ResultadoSincronizacao(
              aplicadas: aplicadas,
              conflitos: conflitos,
              rejeitadas: rejeitadas,
              sessaoExpirada: true,
            );
          } else {
            await _repo.atualizarOperacao(op.copiar(status: StatusOperacao.rejeitada, resposta: {'erro': e.mensagem}));
            rejeitadas++;
          }
        } on ErroRede {
          await _repo.atualizarOperacao(op.copiar(status: StatusOperacao.pendente));
          return ResultadoSincronizacao(
            aplicadas: aplicadas,
            conflitos: conflitos,
            rejeitadas: rejeitadas,
            semConexao: true,
          );
        }
      }
      return ResultadoSincronizacao(aplicadas: aplicadas, conflitos: conflitos, rejeitadas: rejeitadas);
    } finally {
      _emAndamento = false;
    }
  }

  Future<void> _guardarEstadoReal(OperacaoLocal op, Map<String, dynamic> corpo) async {
    final atual = corpo['contaAtual'];
    final vetor = corpo['vetorAtual'];
    if (atual is Map && vetor is List) {
      await _repo.salvarConta(ContaDto.fromJson({...Map<String, dynamic>.from(atual), 'vetorAtual': vetor}), op.agencia);
    }
  }

  Future<ResultadoSincronizacao> aplicarComEstadoAtual(OperacaoLocal op) async {
    final vetor = op.resposta?['vetorAtual'];
    if (vetor is List) {
      await _repo.atualizarVetorDosPendentes(op.agencia, vetor.map((e) => (e as num).toInt()).toList());
    }
    await _repo.atualizarOperacao(
      op.copiar(
        status: StatusOperacao.pendente,
        vetorConhecido: vetor is List ? vetor.map((e) => (e as num).toInt()).toList() : null,
      ),
    );
    return sincronizar();
  }

  Future<void> descartar(OperacaoLocal op) async {
    final vetor = op.resposta?['vetorAtual'];
    if (vetor is List) {
      await _repo.atualizarVetorDosPendentes(op.agencia, vetor.map((e) => (e as num).toInt()).toList());
    }
    await _repo.remover(op.idOperacao);
  }
}
