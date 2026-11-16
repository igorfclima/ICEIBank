import 'dart:convert';

import 'package:drift/drift.dart';

import 'abrir_banco.dart';
import 'modelos.dart';
import 'modelos_locais.dart';

part 'banco.g.dart';

@DataClassName('LinhaConta')
class ContasCache extends Table {
  IntColumn get id => integer()();
  IntColumn get agencia => integer()();
  TextColumn get nomeAluno => text().nullable()();
  TextColumn get dono => text().nullable()();
  RealColumn get saldo => real()();
  TextColumn get vetorAtual => text()();
  DateTimeColumn get atualizadoEm => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LinhaOperacao')
class OperacoesPendentes extends Table {
  TextColumn get idOperacao => text()();
  IntColumn get idConta => integer()();
  IntColumn get agencia => integer()();
  TextColumn get tipo => text()();
  RealColumn get valor => real()();
  IntColumn get idDestino => integer().nullable()();
  TextColumn get vetorConhecido => text()();
  DateTimeColumn get criadoEm => dateTime()();
  TextColumn get status => text()();
  TextColumn get resposta => text().nullable()();

  @override
  Set<Column> get primaryKey => {idOperacao};
}

@DriftDatabase(tables: [ContasCache, OperacoesPendentes])
class BancoLocal extends _$BancoLocal {
  BancoLocal([QueryExecutor? executor]) : super(executor ?? abrirBanco());

  @override
  int get schemaVersion => 1;
}

List<int> _lerVetor(String texto) => (jsonDecode(texto) as List).map((e) => (e as num).toInt()).toList();

ContaLocal _paraConta(LinhaConta l) => ContaLocal(
      id: l.id,
      agencia: l.agencia,
      saldo: l.saldo,
      vetorAtual: _lerVetor(l.vetorAtual),
      atualizadoEm: l.atualizadoEm,
      nomeAluno: l.nomeAluno,
      dono: l.dono,
    );

OperacaoLocal _paraOperacao(LinhaOperacao l) => OperacaoLocal(
      idOperacao: l.idOperacao,
      idConta: l.idConta,
      agencia: l.agencia,
      tipo: TipoOperacao.deCodigo(l.tipo),
      valor: l.valor,
      idDestino: l.idDestino,
      vetorConhecido: _lerVetor(l.vetorConhecido),
      criadoEm: l.criadoEm,
      status: StatusOperacao.values.byName(l.status),
      resposta: l.resposta == null ? null : Map<String, dynamic>.from(jsonDecode(l.resposta!) as Map),
    );

OperacoesPendentesCompanion _paraLinha(OperacaoLocal o) => OperacoesPendentesCompanion(
      idOperacao: Value(o.idOperacao),
      idConta: Value(o.idConta),
      agencia: Value(o.agencia),
      tipo: Value(o.tipo.codigo),
      valor: Value(o.valor),
      idDestino: Value(o.idDestino),
      vetorConhecido: Value(jsonEncode(o.vetorConhecido)),
      criadoEm: Value(o.criadoEm),
      status: Value(o.status.name),
      resposta: Value(o.resposta == null ? null : jsonEncode(o.resposta)),
    );

class RepositorioDrift implements RepositorioLocal {
  RepositorioDrift(this._db);

  final BancoLocal _db;

  @override
  Stream<ContaLocal?> observarConta(int id) =>
      (_db.select(_db.contasCache)..where((t) => t.id.equals(id))).watchSingleOrNull().map((l) => l == null ? null : _paraConta(l));

  @override
  Future<ContaLocal?> buscarConta(int id) async {
    final l = await (_db.select(_db.contasCache)..where((t) => t.id.equals(id))).getSingleOrNull();
    return l == null ? null : _paraConta(l);
  }

  @override
  Future<void> salvarConta(ContaDto conta, int agencia) => _db.into(_db.contasCache).insertOnConflictUpdate(
        ContasCacheCompanion(
          id: Value(conta.id),
          agencia: Value(agencia),
          nomeAluno: Value(conta.nomeAluno),
          dono: Value(conta.dono),
          saldo: Value(conta.saldo),
          vetorAtual: Value(jsonEncode(conta.vetorAtual)),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  @override
  Stream<List<OperacaoLocal>> observarOperacoes() =>
      (_db.select(_db.operacoesPendentes)..orderBy([(t) => OrderingTerm.asc(t.criadoEm)])).watch().map((ls) => ls.map(_paraOperacao).toList());

  @override
  Future<List<OperacaoLocal>> operacoesAguardando() async {
    final ls = await (_db.select(_db.operacoesPendentes)
          ..where((t) => t.status.equals(StatusOperacao.pendente.name))
          ..orderBy([(t) => OrderingTerm.asc(t.criadoEm)]))
        .get();
    return ls.map(_paraOperacao).toList();
  }

  @override
  Future<void> criarOperacao(OperacaoLocal operacao) => _db.into(_db.operacoesPendentes).insert(_paraLinha(operacao));

  @override
  Future<void> atualizarOperacao(OperacaoLocal operacao) => _db.into(_db.operacoesPendentes).insertOnConflictUpdate(_paraLinha(operacao));

  @override
  Future<void> atualizarVetorDosPendentes(int agencia, List<int> vetor, {String? exceto}) =>
      (_db.update(_db.operacoesPendentes)
            ..where((t) =>
                t.agencia.equals(agencia) &
                t.status.equals(StatusOperacao.pendente.name) &
                (exceto == null ? const Constant(true) : t.idOperacao.equals(exceto).not())))
          .write(OperacoesPendentesCompanion(vetorConhecido: Value(jsonEncode(vetor))));

  @override
  Future<void> remover(String idOperacao) =>
      (_db.delete(_db.operacoesPendentes)..where((t) => t.idOperacao.equals(idOperacao))).go();

  @override
  Future<void> limparTudo() async {
    await _db.delete(_db.operacoesPendentes).go();
    await _db.delete(_db.contasCache).go();
  }
}
