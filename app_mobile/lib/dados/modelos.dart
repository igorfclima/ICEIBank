class ContaDto {
  const ContaDto({
    required this.id,
    required this.saldo,
    required this.vetorAtual,
    this.nomeAluno,
    this.dono,
  });

  final int id;
  final double saldo;
  final List<int> vetorAtual;
  final String? nomeAluno;
  final String? dono;

  factory ContaDto.fromJson(Map<String, dynamic> json) => ContaDto(
        id: (json['id'] as num).toInt(),
        saldo: (json['saldo'] as num).toDouble(),
        vetorAtual: ((json['vetorAtual'] as List?) ?? const []).map((e) => (e as num).toInt()).toList(),
        nomeAluno: json['nomeAluno'] as String?,
        dono: json['dono'] as String?,
      );
}

class EventoDto {
  const EventoDto({
    required this.tipo,
    required this.vetor,
    required this.hora,
    required this.detalhes,
  });

  final String tipo;
  final List<int> vetor;
  final DateTime hora;
  final Map<String, dynamic> detalhes;

  factory EventoDto.fromJson(Map<String, dynamic> json) => EventoDto(
        tipo: json['tipo'] as String,
        vetor: (json['timestampVetorial'] as List).map((e) => (e as num).toInt()).toList(),
        hora: DateTime.parse(json['horaParede'] as String).toLocal(),
        detalhes: Map<String, dynamic>.from(json['detalhes'] as Map),
      );

  double? get valor => (detalhes['valor'] as num?)?.toDouble();
}

class Lideranca {
  const Lideranca({required this.idAgencia, required this.liderAtual, required this.desde});

  final int idAgencia;
  final int? liderAtual;
  final DateTime? desde;

  factory Lideranca.fromJson(Map<String, dynamic> json) {
    final epoch = (json['desde'] as num?)?.toDouble();
    return Lideranca(
      idAgencia: (json['idAgencia'] as num).toInt(),
      liderAtual: (json['liderAtual'] as num?)?.toInt(),
      desde: epoch == null ? null : DateTime.fromMillisecondsSinceEpoch((epoch * 1000).round()),
    );
  }
}

class ResultadoTransferencia {
  const ResultadoTransferencia({required this.status, required this.mensagem});

  final String status;
  final String mensagem;

  factory ResultadoTransferencia.fromJson(Map<String, dynamic> json) => ResultadoTransferencia(
        status: json['status'] as String? ?? 'concluida',
        mensagem: json['mensagem'] as String? ?? '',
      );
}

enum TipoOperacao {
  deposito('DEPOSITO'),
  saque('SAQUE'),
  transferencia('TRANSFERENCIA');

  const TipoOperacao(this.codigo);
  final String codigo;

  static TipoOperacao deCodigo(String codigo) =>
      TipoOperacao.values.firstWhere((t) => t.codigo == codigo);
}

enum StatusOperacao {
  pendente,
  enviando,
  sincronizada,
  conflito,
  rejeitada;

  bool get aguardando => this == pendente || this == enviando;
}
