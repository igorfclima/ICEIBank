// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco.dart';

// ignore_for_file: type=lint
class $ContasCacheTable extends ContasCache
    with TableInfo<$ContasCacheTable, LinhaConta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContasCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _agenciaMeta = const VerificationMeta(
    'agencia',
  );
  @override
  late final GeneratedColumn<int> agencia = GeneratedColumn<int>(
    'agencia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeAlunoMeta = const VerificationMeta(
    'nomeAluno',
  );
  @override
  late final GeneratedColumn<String> nomeAluno = GeneratedColumn<String>(
    'nome_aluno',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _donoMeta = const VerificationMeta('dono');
  @override
  late final GeneratedColumn<String> dono = GeneratedColumn<String>(
    'dono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saldoMeta = const VerificationMeta('saldo');
  @override
  late final GeneratedColumn<double> saldo = GeneratedColumn<double>(
    'saldo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vetorAtualMeta = const VerificationMeta(
    'vetorAtual',
  );
  @override
  late final GeneratedColumn<String> vetorAtual = GeneratedColumn<String>(
    'vetor_atual',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    agencia,
    nomeAluno,
    dono,
    saldo,
    vetorAtual,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contas_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinhaConta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('agencia')) {
      context.handle(
        _agenciaMeta,
        agencia.isAcceptableOrUnknown(data['agencia']!, _agenciaMeta),
      );
    } else if (isInserting) {
      context.missing(_agenciaMeta);
    }
    if (data.containsKey('nome_aluno')) {
      context.handle(
        _nomeAlunoMeta,
        nomeAluno.isAcceptableOrUnknown(data['nome_aluno']!, _nomeAlunoMeta),
      );
    }
    if (data.containsKey('dono')) {
      context.handle(
        _donoMeta,
        dono.isAcceptableOrUnknown(data['dono']!, _donoMeta),
      );
    }
    if (data.containsKey('saldo')) {
      context.handle(
        _saldoMeta,
        saldo.isAcceptableOrUnknown(data['saldo']!, _saldoMeta),
      );
    } else if (isInserting) {
      context.missing(_saldoMeta);
    }
    if (data.containsKey('vetor_atual')) {
      context.handle(
        _vetorAtualMeta,
        vetorAtual.isAcceptableOrUnknown(data['vetor_atual']!, _vetorAtualMeta),
      );
    } else if (isInserting) {
      context.missing(_vetorAtualMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LinhaConta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinhaConta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      agencia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}agencia'],
      )!,
      nomeAluno: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_aluno'],
      ),
      dono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dono'],
      ),
      saldo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saldo'],
      )!,
      vetorAtual: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vetor_atual'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $ContasCacheTable createAlias(String alias) {
    return $ContasCacheTable(attachedDatabase, alias);
  }
}

class LinhaConta extends DataClass implements Insertable<LinhaConta> {
  final int id;
  final int agencia;
  final String? nomeAluno;
  final String? dono;
  final double saldo;
  final String vetorAtual;
  final DateTime atualizadoEm;
  const LinhaConta({
    required this.id,
    required this.agencia,
    this.nomeAluno,
    this.dono,
    required this.saldo,
    required this.vetorAtual,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['agencia'] = Variable<int>(agencia);
    if (!nullToAbsent || nomeAluno != null) {
      map['nome_aluno'] = Variable<String>(nomeAluno);
    }
    if (!nullToAbsent || dono != null) {
      map['dono'] = Variable<String>(dono);
    }
    map['saldo'] = Variable<double>(saldo);
    map['vetor_atual'] = Variable<String>(vetorAtual);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  ContasCacheCompanion toCompanion(bool nullToAbsent) {
    return ContasCacheCompanion(
      id: Value(id),
      agencia: Value(agencia),
      nomeAluno: nomeAluno == null && nullToAbsent
          ? const Value.absent()
          : Value(nomeAluno),
      dono: dono == null && nullToAbsent ? const Value.absent() : Value(dono),
      saldo: Value(saldo),
      vetorAtual: Value(vetorAtual),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory LinhaConta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinhaConta(
      id: serializer.fromJson<int>(json['id']),
      agencia: serializer.fromJson<int>(json['agencia']),
      nomeAluno: serializer.fromJson<String?>(json['nomeAluno']),
      dono: serializer.fromJson<String?>(json['dono']),
      saldo: serializer.fromJson<double>(json['saldo']),
      vetorAtual: serializer.fromJson<String>(json['vetorAtual']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'agencia': serializer.toJson<int>(agencia),
      'nomeAluno': serializer.toJson<String?>(nomeAluno),
      'dono': serializer.toJson<String?>(dono),
      'saldo': serializer.toJson<double>(saldo),
      'vetorAtual': serializer.toJson<String>(vetorAtual),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  LinhaConta copyWith({
    int? id,
    int? agencia,
    Value<String?> nomeAluno = const Value.absent(),
    Value<String?> dono = const Value.absent(),
    double? saldo,
    String? vetorAtual,
    DateTime? atualizadoEm,
  }) => LinhaConta(
    id: id ?? this.id,
    agencia: agencia ?? this.agencia,
    nomeAluno: nomeAluno.present ? nomeAluno.value : this.nomeAluno,
    dono: dono.present ? dono.value : this.dono,
    saldo: saldo ?? this.saldo,
    vetorAtual: vetorAtual ?? this.vetorAtual,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  LinhaConta copyWithCompanion(ContasCacheCompanion data) {
    return LinhaConta(
      id: data.id.present ? data.id.value : this.id,
      agencia: data.agencia.present ? data.agencia.value : this.agencia,
      nomeAluno: data.nomeAluno.present ? data.nomeAluno.value : this.nomeAluno,
      dono: data.dono.present ? data.dono.value : this.dono,
      saldo: data.saldo.present ? data.saldo.value : this.saldo,
      vetorAtual: data.vetorAtual.present
          ? data.vetorAtual.value
          : this.vetorAtual,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinhaConta(')
          ..write('id: $id, ')
          ..write('agencia: $agencia, ')
          ..write('nomeAluno: $nomeAluno, ')
          ..write('dono: $dono, ')
          ..write('saldo: $saldo, ')
          ..write('vetorAtual: $vetorAtual, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    agencia,
    nomeAluno,
    dono,
    saldo,
    vetorAtual,
    atualizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinhaConta &&
          other.id == this.id &&
          other.agencia == this.agencia &&
          other.nomeAluno == this.nomeAluno &&
          other.dono == this.dono &&
          other.saldo == this.saldo &&
          other.vetorAtual == this.vetorAtual &&
          other.atualizadoEm == this.atualizadoEm);
}

class ContasCacheCompanion extends UpdateCompanion<LinhaConta> {
  final Value<int> id;
  final Value<int> agencia;
  final Value<String?> nomeAluno;
  final Value<String?> dono;
  final Value<double> saldo;
  final Value<String> vetorAtual;
  final Value<DateTime> atualizadoEm;
  const ContasCacheCompanion({
    this.id = const Value.absent(),
    this.agencia = const Value.absent(),
    this.nomeAluno = const Value.absent(),
    this.dono = const Value.absent(),
    this.saldo = const Value.absent(),
    this.vetorAtual = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  });
  ContasCacheCompanion.insert({
    this.id = const Value.absent(),
    required int agencia,
    this.nomeAluno = const Value.absent(),
    this.dono = const Value.absent(),
    required double saldo,
    required String vetorAtual,
    required DateTime atualizadoEm,
  }) : agencia = Value(agencia),
       saldo = Value(saldo),
       vetorAtual = Value(vetorAtual),
       atualizadoEm = Value(atualizadoEm);
  static Insertable<LinhaConta> custom({
    Expression<int>? id,
    Expression<int>? agencia,
    Expression<String>? nomeAluno,
    Expression<String>? dono,
    Expression<double>? saldo,
    Expression<String>? vetorAtual,
    Expression<DateTime>? atualizadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (agencia != null) 'agencia': agencia,
      if (nomeAluno != null) 'nome_aluno': nomeAluno,
      if (dono != null) 'dono': dono,
      if (saldo != null) 'saldo': saldo,
      if (vetorAtual != null) 'vetor_atual': vetorAtual,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
    });
  }

  ContasCacheCompanion copyWith({
    Value<int>? id,
    Value<int>? agencia,
    Value<String?>? nomeAluno,
    Value<String?>? dono,
    Value<double>? saldo,
    Value<String>? vetorAtual,
    Value<DateTime>? atualizadoEm,
  }) {
    return ContasCacheCompanion(
      id: id ?? this.id,
      agencia: agencia ?? this.agencia,
      nomeAluno: nomeAluno ?? this.nomeAluno,
      dono: dono ?? this.dono,
      saldo: saldo ?? this.saldo,
      vetorAtual: vetorAtual ?? this.vetorAtual,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (agencia.present) {
      map['agencia'] = Variable<int>(agencia.value);
    }
    if (nomeAluno.present) {
      map['nome_aluno'] = Variable<String>(nomeAluno.value);
    }
    if (dono.present) {
      map['dono'] = Variable<String>(dono.value);
    }
    if (saldo.present) {
      map['saldo'] = Variable<double>(saldo.value);
    }
    if (vetorAtual.present) {
      map['vetor_atual'] = Variable<String>(vetorAtual.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContasCacheCompanion(')
          ..write('id: $id, ')
          ..write('agencia: $agencia, ')
          ..write('nomeAluno: $nomeAluno, ')
          ..write('dono: $dono, ')
          ..write('saldo: $saldo, ')
          ..write('vetorAtual: $vetorAtual, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }
}

class $OperacoesPendentesTable extends OperacoesPendentes
    with TableInfo<$OperacoesPendentesTable, LinhaOperacao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperacoesPendentesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idOperacaoMeta = const VerificationMeta(
    'idOperacao',
  );
  @override
  late final GeneratedColumn<String> idOperacao = GeneratedColumn<String>(
    'id_operacao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idContaMeta = const VerificationMeta(
    'idConta',
  );
  @override
  late final GeneratedColumn<int> idConta = GeneratedColumn<int>(
    'id_conta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agenciaMeta = const VerificationMeta(
    'agencia',
  );
  @override
  late final GeneratedColumn<int> agencia = GeneratedColumn<int>(
    'agencia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idDestinoMeta = const VerificationMeta(
    'idDestino',
  );
  @override
  late final GeneratedColumn<int> idDestino = GeneratedColumn<int>(
    'id_destino',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vetorConhecidoMeta = const VerificationMeta(
    'vetorConhecido',
  );
  @override
  late final GeneratedColumn<String> vetorConhecido = GeneratedColumn<String>(
    'vetor_conhecido',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respostaMeta = const VerificationMeta(
    'resposta',
  );
  @override
  late final GeneratedColumn<String> resposta = GeneratedColumn<String>(
    'resposta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    idOperacao,
    idConta,
    agencia,
    tipo,
    valor,
    idDestino,
    vetorConhecido,
    criadoEm,
    status,
    resposta,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operacoes_pendentes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinhaOperacao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_operacao')) {
      context.handle(
        _idOperacaoMeta,
        idOperacao.isAcceptableOrUnknown(data['id_operacao']!, _idOperacaoMeta),
      );
    } else if (isInserting) {
      context.missing(_idOperacaoMeta);
    }
    if (data.containsKey('id_conta')) {
      context.handle(
        _idContaMeta,
        idConta.isAcceptableOrUnknown(data['id_conta']!, _idContaMeta),
      );
    } else if (isInserting) {
      context.missing(_idContaMeta);
    }
    if (data.containsKey('agencia')) {
      context.handle(
        _agenciaMeta,
        agencia.isAcceptableOrUnknown(data['agencia']!, _agenciaMeta),
      );
    } else if (isInserting) {
      context.missing(_agenciaMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('id_destino')) {
      context.handle(
        _idDestinoMeta,
        idDestino.isAcceptableOrUnknown(data['id_destino']!, _idDestinoMeta),
      );
    }
    if (data.containsKey('vetor_conhecido')) {
      context.handle(
        _vetorConhecidoMeta,
        vetorConhecido.isAcceptableOrUnknown(
          data['vetor_conhecido']!,
          _vetorConhecidoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vetorConhecidoMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('resposta')) {
      context.handle(
        _respostaMeta,
        resposta.isAcceptableOrUnknown(data['resposta']!, _respostaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idOperacao};
  @override
  LinhaOperacao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinhaOperacao(
      idOperacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_operacao'],
      )!,
      idConta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_conta'],
      )!,
      agencia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}agencia'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      idDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_destino'],
      ),
      vetorConhecido: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vetor_conhecido'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      resposta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resposta'],
      ),
    );
  }

  @override
  $OperacoesPendentesTable createAlias(String alias) {
    return $OperacoesPendentesTable(attachedDatabase, alias);
  }
}

class LinhaOperacao extends DataClass implements Insertable<LinhaOperacao> {
  final String idOperacao;
  final int idConta;
  final int agencia;
  final String tipo;
  final double valor;
  final int? idDestino;
  final String vetorConhecido;
  final DateTime criadoEm;
  final String status;
  final String? resposta;
  const LinhaOperacao({
    required this.idOperacao,
    required this.idConta,
    required this.agencia,
    required this.tipo,
    required this.valor,
    this.idDestino,
    required this.vetorConhecido,
    required this.criadoEm,
    required this.status,
    this.resposta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_operacao'] = Variable<String>(idOperacao);
    map['id_conta'] = Variable<int>(idConta);
    map['agencia'] = Variable<int>(agencia);
    map['tipo'] = Variable<String>(tipo);
    map['valor'] = Variable<double>(valor);
    if (!nullToAbsent || idDestino != null) {
      map['id_destino'] = Variable<int>(idDestino);
    }
    map['vetor_conhecido'] = Variable<String>(vetorConhecido);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resposta != null) {
      map['resposta'] = Variable<String>(resposta);
    }
    return map;
  }

  OperacoesPendentesCompanion toCompanion(bool nullToAbsent) {
    return OperacoesPendentesCompanion(
      idOperacao: Value(idOperacao),
      idConta: Value(idConta),
      agencia: Value(agencia),
      tipo: Value(tipo),
      valor: Value(valor),
      idDestino: idDestino == null && nullToAbsent
          ? const Value.absent()
          : Value(idDestino),
      vetorConhecido: Value(vetorConhecido),
      criadoEm: Value(criadoEm),
      status: Value(status),
      resposta: resposta == null && nullToAbsent
          ? const Value.absent()
          : Value(resposta),
    );
  }

  factory LinhaOperacao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinhaOperacao(
      idOperacao: serializer.fromJson<String>(json['idOperacao']),
      idConta: serializer.fromJson<int>(json['idConta']),
      agencia: serializer.fromJson<int>(json['agencia']),
      tipo: serializer.fromJson<String>(json['tipo']),
      valor: serializer.fromJson<double>(json['valor']),
      idDestino: serializer.fromJson<int?>(json['idDestino']),
      vetorConhecido: serializer.fromJson<String>(json['vetorConhecido']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      status: serializer.fromJson<String>(json['status']),
      resposta: serializer.fromJson<String?>(json['resposta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idOperacao': serializer.toJson<String>(idOperacao),
      'idConta': serializer.toJson<int>(idConta),
      'agencia': serializer.toJson<int>(agencia),
      'tipo': serializer.toJson<String>(tipo),
      'valor': serializer.toJson<double>(valor),
      'idDestino': serializer.toJson<int?>(idDestino),
      'vetorConhecido': serializer.toJson<String>(vetorConhecido),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'status': serializer.toJson<String>(status),
      'resposta': serializer.toJson<String?>(resposta),
    };
  }

  LinhaOperacao copyWith({
    String? idOperacao,
    int? idConta,
    int? agencia,
    String? tipo,
    double? valor,
    Value<int?> idDestino = const Value.absent(),
    String? vetorConhecido,
    DateTime? criadoEm,
    String? status,
    Value<String?> resposta = const Value.absent(),
  }) => LinhaOperacao(
    idOperacao: idOperacao ?? this.idOperacao,
    idConta: idConta ?? this.idConta,
    agencia: agencia ?? this.agencia,
    tipo: tipo ?? this.tipo,
    valor: valor ?? this.valor,
    idDestino: idDestino.present ? idDestino.value : this.idDestino,
    vetorConhecido: vetorConhecido ?? this.vetorConhecido,
    criadoEm: criadoEm ?? this.criadoEm,
    status: status ?? this.status,
    resposta: resposta.present ? resposta.value : this.resposta,
  );
  LinhaOperacao copyWithCompanion(OperacoesPendentesCompanion data) {
    return LinhaOperacao(
      idOperacao: data.idOperacao.present
          ? data.idOperacao.value
          : this.idOperacao,
      idConta: data.idConta.present ? data.idConta.value : this.idConta,
      agencia: data.agencia.present ? data.agencia.value : this.agencia,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      valor: data.valor.present ? data.valor.value : this.valor,
      idDestino: data.idDestino.present ? data.idDestino.value : this.idDestino,
      vetorConhecido: data.vetorConhecido.present
          ? data.vetorConhecido.value
          : this.vetorConhecido,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      status: data.status.present ? data.status.value : this.status,
      resposta: data.resposta.present ? data.resposta.value : this.resposta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinhaOperacao(')
          ..write('idOperacao: $idOperacao, ')
          ..write('idConta: $idConta, ')
          ..write('agencia: $agencia, ')
          ..write('tipo: $tipo, ')
          ..write('valor: $valor, ')
          ..write('idDestino: $idDestino, ')
          ..write('vetorConhecido: $vetorConhecido, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('status: $status, ')
          ..write('resposta: $resposta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    idOperacao,
    idConta,
    agencia,
    tipo,
    valor,
    idDestino,
    vetorConhecido,
    criadoEm,
    status,
    resposta,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinhaOperacao &&
          other.idOperacao == this.idOperacao &&
          other.idConta == this.idConta &&
          other.agencia == this.agencia &&
          other.tipo == this.tipo &&
          other.valor == this.valor &&
          other.idDestino == this.idDestino &&
          other.vetorConhecido == this.vetorConhecido &&
          other.criadoEm == this.criadoEm &&
          other.status == this.status &&
          other.resposta == this.resposta);
}

class OperacoesPendentesCompanion extends UpdateCompanion<LinhaOperacao> {
  final Value<String> idOperacao;
  final Value<int> idConta;
  final Value<int> agencia;
  final Value<String> tipo;
  final Value<double> valor;
  final Value<int?> idDestino;
  final Value<String> vetorConhecido;
  final Value<DateTime> criadoEm;
  final Value<String> status;
  final Value<String?> resposta;
  final Value<int> rowid;
  const OperacoesPendentesCompanion({
    this.idOperacao = const Value.absent(),
    this.idConta = const Value.absent(),
    this.agencia = const Value.absent(),
    this.tipo = const Value.absent(),
    this.valor = const Value.absent(),
    this.idDestino = const Value.absent(),
    this.vetorConhecido = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.status = const Value.absent(),
    this.resposta = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperacoesPendentesCompanion.insert({
    required String idOperacao,
    required int idConta,
    required int agencia,
    required String tipo,
    required double valor,
    this.idDestino = const Value.absent(),
    required String vetorConhecido,
    required DateTime criadoEm,
    required String status,
    this.resposta = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : idOperacao = Value(idOperacao),
       idConta = Value(idConta),
       agencia = Value(agencia),
       tipo = Value(tipo),
       valor = Value(valor),
       vetorConhecido = Value(vetorConhecido),
       criadoEm = Value(criadoEm),
       status = Value(status);
  static Insertable<LinhaOperacao> custom({
    Expression<String>? idOperacao,
    Expression<int>? idConta,
    Expression<int>? agencia,
    Expression<String>? tipo,
    Expression<double>? valor,
    Expression<int>? idDestino,
    Expression<String>? vetorConhecido,
    Expression<DateTime>? criadoEm,
    Expression<String>? status,
    Expression<String>? resposta,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idOperacao != null) 'id_operacao': idOperacao,
      if (idConta != null) 'id_conta': idConta,
      if (agencia != null) 'agencia': agencia,
      if (tipo != null) 'tipo': tipo,
      if (valor != null) 'valor': valor,
      if (idDestino != null) 'id_destino': idDestino,
      if (vetorConhecido != null) 'vetor_conhecido': vetorConhecido,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (status != null) 'status': status,
      if (resposta != null) 'resposta': resposta,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperacoesPendentesCompanion copyWith({
    Value<String>? idOperacao,
    Value<int>? idConta,
    Value<int>? agencia,
    Value<String>? tipo,
    Value<double>? valor,
    Value<int?>? idDestino,
    Value<String>? vetorConhecido,
    Value<DateTime>? criadoEm,
    Value<String>? status,
    Value<String?>? resposta,
    Value<int>? rowid,
  }) {
    return OperacoesPendentesCompanion(
      idOperacao: idOperacao ?? this.idOperacao,
      idConta: idConta ?? this.idConta,
      agencia: agencia ?? this.agencia,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      idDestino: idDestino ?? this.idDestino,
      vetorConhecido: vetorConhecido ?? this.vetorConhecido,
      criadoEm: criadoEm ?? this.criadoEm,
      status: status ?? this.status,
      resposta: resposta ?? this.resposta,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idOperacao.present) {
      map['id_operacao'] = Variable<String>(idOperacao.value);
    }
    if (idConta.present) {
      map['id_conta'] = Variable<int>(idConta.value);
    }
    if (agencia.present) {
      map['agencia'] = Variable<int>(agencia.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (idDestino.present) {
      map['id_destino'] = Variable<int>(idDestino.value);
    }
    if (vetorConhecido.present) {
      map['vetor_conhecido'] = Variable<String>(vetorConhecido.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resposta.present) {
      map['resposta'] = Variable<String>(resposta.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperacoesPendentesCompanion(')
          ..write('idOperacao: $idOperacao, ')
          ..write('idConta: $idConta, ')
          ..write('agencia: $agencia, ')
          ..write('tipo: $tipo, ')
          ..write('valor: $valor, ')
          ..write('idDestino: $idDestino, ')
          ..write('vetorConhecido: $vetorConhecido, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('status: $status, ')
          ..write('resposta: $resposta, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BancoLocal extends GeneratedDatabase {
  _$BancoLocal(QueryExecutor e) : super(e);
  $BancoLocalManager get managers => $BancoLocalManager(this);
  late final $ContasCacheTable contasCache = $ContasCacheTable(this);
  late final $OperacoesPendentesTable operacoesPendentes =
      $OperacoesPendentesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contasCache,
    operacoesPendentes,
  ];
}

typedef $$ContasCacheTableCreateCompanionBuilder =
    ContasCacheCompanion Function({
      Value<int> id,
      required int agencia,
      Value<String?> nomeAluno,
      Value<String?> dono,
      required double saldo,
      required String vetorAtual,
      required DateTime atualizadoEm,
    });
typedef $$ContasCacheTableUpdateCompanionBuilder =
    ContasCacheCompanion Function({
      Value<int> id,
      Value<int> agencia,
      Value<String?> nomeAluno,
      Value<String?> dono,
      Value<double> saldo,
      Value<String> vetorAtual,
      Value<DateTime> atualizadoEm,
    });

class $$ContasCacheTableFilterComposer
    extends Composer<_$BancoLocal, $ContasCacheTable> {
  $$ContasCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get agencia => $composableBuilder(
    column: $table.agencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomeAluno => $composableBuilder(
    column: $table.nomeAluno,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dono => $composableBuilder(
    column: $table.dono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saldo => $composableBuilder(
    column: $table.saldo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vetorAtual => $composableBuilder(
    column: $table.vetorAtual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContasCacheTableOrderingComposer
    extends Composer<_$BancoLocal, $ContasCacheTable> {
  $$ContasCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get agencia => $composableBuilder(
    column: $table.agencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomeAluno => $composableBuilder(
    column: $table.nomeAluno,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dono => $composableBuilder(
    column: $table.dono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saldo => $composableBuilder(
    column: $table.saldo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vetorAtual => $composableBuilder(
    column: $table.vetorAtual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContasCacheTableAnnotationComposer
    extends Composer<_$BancoLocal, $ContasCacheTable> {
  $$ContasCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get agencia =>
      $composableBuilder(column: $table.agencia, builder: (column) => column);

  GeneratedColumn<String> get nomeAluno =>
      $composableBuilder(column: $table.nomeAluno, builder: (column) => column);

  GeneratedColumn<String> get dono =>
      $composableBuilder(column: $table.dono, builder: (column) => column);

  GeneratedColumn<double> get saldo =>
      $composableBuilder(column: $table.saldo, builder: (column) => column);

  GeneratedColumn<String> get vetorAtual => $composableBuilder(
    column: $table.vetorAtual,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );
}

class $$ContasCacheTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $ContasCacheTable,
          LinhaConta,
          $$ContasCacheTableFilterComposer,
          $$ContasCacheTableOrderingComposer,
          $$ContasCacheTableAnnotationComposer,
          $$ContasCacheTableCreateCompanionBuilder,
          $$ContasCacheTableUpdateCompanionBuilder,
          (
            LinhaConta,
            BaseReferences<_$BancoLocal, $ContasCacheTable, LinhaConta>,
          ),
          LinhaConta,
          PrefetchHooks Function()
        > {
  $$ContasCacheTableTableManager(_$BancoLocal db, $ContasCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContasCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContasCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContasCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> agencia = const Value.absent(),
                Value<String?> nomeAluno = const Value.absent(),
                Value<String?> dono = const Value.absent(),
                Value<double> saldo = const Value.absent(),
                Value<String> vetorAtual = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => ContasCacheCompanion(
                id: id,
                agencia: agencia,
                nomeAluno: nomeAluno,
                dono: dono,
                saldo: saldo,
                vetorAtual: vetorAtual,
                atualizadoEm: atualizadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int agencia,
                Value<String?> nomeAluno = const Value.absent(),
                Value<String?> dono = const Value.absent(),
                required double saldo,
                required String vetorAtual,
                required DateTime atualizadoEm,
              }) => ContasCacheCompanion.insert(
                id: id,
                agencia: agencia,
                nomeAluno: nomeAluno,
                dono: dono,
                saldo: saldo,
                vetorAtual: vetorAtual,
                atualizadoEm: atualizadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContasCacheTable, LinhaConta>(table),
                  BaseReferences<_$BancoLocal, $ContasCacheTable, LinhaConta>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContasCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $ContasCacheTable,
      LinhaConta,
      $$ContasCacheTableFilterComposer,
      $$ContasCacheTableOrderingComposer,
      $$ContasCacheTableAnnotationComposer,
      $$ContasCacheTableCreateCompanionBuilder,
      $$ContasCacheTableUpdateCompanionBuilder,
      (LinhaConta, BaseReferences<_$BancoLocal, $ContasCacheTable, LinhaConta>),
      LinhaConta,
      PrefetchHooks Function()
    >;
typedef $$OperacoesPendentesTableCreateCompanionBuilder =
    OperacoesPendentesCompanion Function({
      required String idOperacao,
      required int idConta,
      required int agencia,
      required String tipo,
      required double valor,
      Value<int?> idDestino,
      required String vetorConhecido,
      required DateTime criadoEm,
      required String status,
      Value<String?> resposta,
      Value<int> rowid,
    });
typedef $$OperacoesPendentesTableUpdateCompanionBuilder =
    OperacoesPendentesCompanion Function({
      Value<String> idOperacao,
      Value<int> idConta,
      Value<int> agencia,
      Value<String> tipo,
      Value<double> valor,
      Value<int?> idDestino,
      Value<String> vetorConhecido,
      Value<DateTime> criadoEm,
      Value<String> status,
      Value<String?> resposta,
      Value<int> rowid,
    });

class $$OperacoesPendentesTableFilterComposer
    extends Composer<_$BancoLocal, $OperacoesPendentesTable> {
  $$OperacoesPendentesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idOperacao => $composableBuilder(
    column: $table.idOperacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idConta => $composableBuilder(
    column: $table.idConta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get agencia => $composableBuilder(
    column: $table.agencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idDestino => $composableBuilder(
    column: $table.idDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vetorConhecido => $composableBuilder(
    column: $table.vetorConhecido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resposta => $composableBuilder(
    column: $table.resposta,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OperacoesPendentesTableOrderingComposer
    extends Composer<_$BancoLocal, $OperacoesPendentesTable> {
  $$OperacoesPendentesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idOperacao => $composableBuilder(
    column: $table.idOperacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idConta => $composableBuilder(
    column: $table.idConta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get agencia => $composableBuilder(
    column: $table.agencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idDestino => $composableBuilder(
    column: $table.idDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vetorConhecido => $composableBuilder(
    column: $table.vetorConhecido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resposta => $composableBuilder(
    column: $table.resposta,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OperacoesPendentesTableAnnotationComposer
    extends Composer<_$BancoLocal, $OperacoesPendentesTable> {
  $$OperacoesPendentesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idOperacao => $composableBuilder(
    column: $table.idOperacao,
    builder: (column) => column,
  );

  GeneratedColumn<int> get idConta =>
      $composableBuilder(column: $table.idConta, builder: (column) => column);

  GeneratedColumn<int> get agencia =>
      $composableBuilder(column: $table.agencia, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<int> get idDestino =>
      $composableBuilder(column: $table.idDestino, builder: (column) => column);

  GeneratedColumn<String> get vetorConhecido => $composableBuilder(
    column: $table.vetorConhecido,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get resposta =>
      $composableBuilder(column: $table.resposta, builder: (column) => column);
}

class $$OperacoesPendentesTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $OperacoesPendentesTable,
          LinhaOperacao,
          $$OperacoesPendentesTableFilterComposer,
          $$OperacoesPendentesTableOrderingComposer,
          $$OperacoesPendentesTableAnnotationComposer,
          $$OperacoesPendentesTableCreateCompanionBuilder,
          $$OperacoesPendentesTableUpdateCompanionBuilder,
          (
            LinhaOperacao,
            BaseReferences<
              _$BancoLocal,
              $OperacoesPendentesTable,
              LinhaOperacao
            >,
          ),
          LinhaOperacao,
          PrefetchHooks Function()
        > {
  $$OperacoesPendentesTableTableManager(
    _$BancoLocal db,
    $OperacoesPendentesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperacoesPendentesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperacoesPendentesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperacoesPendentesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> idOperacao = const Value.absent(),
                Value<int> idConta = const Value.absent(),
                Value<int> agencia = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<int?> idDestino = const Value.absent(),
                Value<String> vetorConhecido = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> resposta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperacoesPendentesCompanion(
                idOperacao: idOperacao,
                idConta: idConta,
                agencia: agencia,
                tipo: tipo,
                valor: valor,
                idDestino: idDestino,
                vetorConhecido: vetorConhecido,
                criadoEm: criadoEm,
                status: status,
                resposta: resposta,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idOperacao,
                required int idConta,
                required int agencia,
                required String tipo,
                required double valor,
                Value<int?> idDestino = const Value.absent(),
                required String vetorConhecido,
                required DateTime criadoEm,
                required String status,
                Value<String?> resposta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperacoesPendentesCompanion.insert(
                idOperacao: idOperacao,
                idConta: idConta,
                agencia: agencia,
                tipo: tipo,
                valor: valor,
                idDestino: idDestino,
                vetorConhecido: vetorConhecido,
                criadoEm: criadoEm,
                status: status,
                resposta: resposta,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OperacoesPendentesTable, LinhaOperacao>(table),
                  BaseReferences<
                    _$BancoLocal,
                    $OperacoesPendentesTable,
                    LinhaOperacao
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OperacoesPendentesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $OperacoesPendentesTable,
      LinhaOperacao,
      $$OperacoesPendentesTableFilterComposer,
      $$OperacoesPendentesTableOrderingComposer,
      $$OperacoesPendentesTableAnnotationComposer,
      $$OperacoesPendentesTableCreateCompanionBuilder,
      $$OperacoesPendentesTableUpdateCompanionBuilder,
      (
        LinhaOperacao,
        BaseReferences<_$BancoLocal, $OperacoesPendentesTable, LinhaOperacao>,
      ),
      LinhaOperacao,
      PrefetchHooks Function()
    >;

class $BancoLocalManager {
  final _$BancoLocal _db;
  $BancoLocalManager(this._db);
  $$ContasCacheTableTableManager get contasCache =>
      $$ContasCacheTableTableManager(_db, _db.contasCache);
  $$OperacoesPendentesTableTableManager get operacoesPendentes =>
      $$OperacoesPendentesTableTableManager(_db, _db.operacoesPendentes);
}
