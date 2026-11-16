import 'modelos.dart';

class ContaLocal {
  const ContaLocal({
    required this.id,
    required this.agencia,
    required this.saldo,
    required this.vetorAtual,
    required this.atualizadoEm,
    this.nomeAluno,
    this.dono,
  });

  final int id;
  final int agencia;
  final double saldo;
  final List<int> vetorAtual;
  final DateTime atualizadoEm;
  final String? nomeAluno;
  final String? dono;
}

class OperacaoLocal {
  const OperacaoLocal({
    required this.idOperacao,
    required this.idConta,
    required this.agencia,
    required this.tipo,
    required this.valor,
    required this.vetorConhecido,
    required this.criadoEm,
    required this.status,
    this.idDestino,
    this.resposta,
  });

  final String idOperacao;
  final int idConta;
  final int agencia;
  final TipoOperacao tipo;
  final double valor;
  final List<int> vetorConhecido;
  final DateTime criadoEm;
  final StatusOperacao status;
  final int? idDestino;
  final Map<String, dynamic>? resposta;

  double get efeitoNoSaldo => switch (tipo) {
        TipoOperacao.deposito => valor,
        TipoOperacao.saque || TipoOperacao.transferencia => -valor,
      };

  OperacaoLocal copiar({StatusOperacao? status, List<int>? vetorConhecido, Map<String, dynamic>? resposta}) =>
      OperacaoLocal(
        idOperacao: idOperacao,
        idConta: idConta,
        agencia: agencia,
        tipo: tipo,
        valor: valor,
        vetorConhecido: vetorConhecido ?? this.vetorConhecido,
        criadoEm: criadoEm,
        status: status ?? this.status,
        idDestino: idDestino,
        resposta: resposta ?? this.resposta,
      );
}

abstract class RepositorioLocal {
  Stream<ContaLocal?> observarConta(int id);
  Future<ContaLocal?> buscarConta(int id);
  Future<void> salvarConta(ContaDto conta, int agencia);

  Stream<List<OperacaoLocal>> observarOperacoes();
  Future<List<OperacaoLocal>> operacoesAguardando();
  Future<void> criarOperacao(OperacaoLocal operacao);
  Future<void> atualizarOperacao(OperacaoLocal operacao);
  Future<void> atualizarVetorDosPendentes(int agencia, List<int> vetor, {String? exceto});
  Future<void> remover(String idOperacao);
  Future<void> limparTudo();
}
