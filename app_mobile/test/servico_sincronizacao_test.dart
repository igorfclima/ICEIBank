import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iceibank/core/rede/cliente_api.dart';
import 'package:iceibank/dados/modelos.dart';
import 'package:iceibank/dados/modelos_locais.dart';
import 'package:iceibank/dados/servico_operacoes.dart';
import 'package:iceibank/funcionalidades/sincronizacao/servico_sincronizacao.dart';

class RepositorioMemoria implements RepositorioLocal {
  final contas = <int, ContaLocal>{};
  final operacoes = <String, OperacaoLocal>{};
  final _mudancas = StreamController<void>.broadcast(sync: true);

  void _notificar() => _mudancas.add(null);

  @override
  Stream<ContaLocal?> observarConta(int id) async* {
    yield contas[id];
    yield* _mudancas.stream.map((_) => contas[id]);
  }

  @override
  Future<ContaLocal?> buscarConta(int id) async => contas[id];

  @override
  Future<void> salvarConta(ContaDto conta, int agencia) async {
    contas[conta.id] = ContaLocal(
      id: conta.id,
      agencia: agencia,
      saldo: conta.saldo,
      vetorAtual: conta.vetorAtual,
      atualizadoEm: DateTime.now(),
      nomeAluno: conta.nomeAluno,
      dono: conta.dono,
    );
    _notificar();
  }

  @override
  Stream<List<OperacaoLocal>> observarOperacoes() async* {
    yield operacoes.values.toList();
    yield* _mudancas.stream.map((_) => operacoes.values.toList());
  }

  @override
  Future<List<OperacaoLocal>> operacoesAguardando() async =>
      operacoes.values.where((o) => o.status == StatusOperacao.pendente).toList()
        ..sort((a, b) => a.criadoEm.compareTo(b.criadoEm));

  @override
  Future<void> criarOperacao(OperacaoLocal operacao) async {
    operacoes[operacao.idOperacao] = operacao;
    _notificar();
  }

  @override
  Future<void> atualizarOperacao(OperacaoLocal operacao) async {
    operacoes[operacao.idOperacao] = operacao;
    _notificar();
  }

  @override
  Future<void> atualizarVetorDosPendentes(int agencia, List<int> vetor, {String? exceto}) async {
    for (final o in operacoes.values.toList()) {
      if (o.agencia == agencia && o.status == StatusOperacao.pendente && o.idOperacao != exceto) {
        operacoes[o.idOperacao] = o.copiar(vetorConhecido: vetor);
      }
    }
    _notificar();
  }

  @override
  Future<void> remover(String idOperacao) async {
    operacoes.remove(idOperacao);
    _notificar();
  }

  @override
  Future<void> limparTudo() async {
    contas.clear();
    operacoes.clear();
  }
}

class ApiFalsa extends ClienteApi {
  ApiFalsa() : super(() => 'token');

  bool offline = false;
  int saldo = 100;
  List<int> vetor = [1, 0, 0];
  final recebidas = <String>[];
  int? statusFixo;

  ContaDto _conta() => ContaDto(id: 0, saldo: saldo.toDouble(), vetorAtual: List.of(vetor), nomeAluno: 'Ana');

  @override
  Future<ContaDto> consultarConta(int agencia, int id) async {
    if (offline) throw const ErroRede();
    return _conta();
  }

  @override
  Future<ContaDto> depositar(int agencia, int id, double valor) async {
    if (offline) throw const ErroRede();
    saldo += valor.toInt();
    vetor[0]++;
    return _conta();
  }

  @override
  Future<ContaDto> sincronizar(
    int agencia,
    int idConta, {
    required String idOperacao,
    required TipoOperacao tipo,
    required double valor,
    required List<int> vetorConhecido,
    int? idDestino,
  }) async {
    if (offline) throw const ErroRede();
    if (statusFixo == 401) throw const ErroApi(401, 'Token inválido ou expirado.');
    if (statusFixo == 400) throw const ErroApi(400, 'Saldo insuficiente.');
    if (vetorConhecido.join() != vetor.join()) {
      throw ErroApi(409, 'Conflito detectado', {
        'erro': 'Conflito detectado',
        'vetorConhecido': vetorConhecido,
        'vetorAtual': List.of(vetor),
        'contaAtual': {'id': idConta, 'saldo': saldo, 'nomeAluno': 'Ana'},
      });
    }
    if (recebidas.contains(idOperacao)) return _conta();
    recebidas.add(idOperacao);
    saldo += tipo == TipoOperacao.deposito ? valor.toInt() : -valor.toInt();
    vetor[0]++;
    return _conta();
  }
}

void main() {
  late RepositorioMemoria repo;
  late ApiFalsa api;
  late ServicoOperacoes operacoes;
  late ServicoSincronizacao sync;

  setUp(() async {
    repo = RepositorioMemoria();
    api = ApiFalsa();
    operacoes = ServicoOperacoes(api, repo);
    sync = ServicoSincronizacao(api, repo);
    await operacoes.consultar(0, 0);
  });

  test('online: deposita direto e atualiza o cache com o novo vetor', () async {
    final r = await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 25);
    expect(r.pendente, isFalse);
    expect(repo.contas[0]!.saldo, 125);
    expect(repo.contas[0]!.vetorAtual, [2, 0, 0]);
    expect(repo.operacoes, isEmpty);
  });

  test('offline: operação vai para a fila com o vetor conhecido e sem erro', () async {
    api.offline = true;
    final r = await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 50);
    expect(r.pendente, isTrue);
    final op = repo.operacoes.values.single;
    expect(op.status, StatusOperacao.pendente);
    expect(op.vetorConhecido, [1, 0, 0]);
    expect(repo.contas[0]!.saldo, 100, reason: 'saldo confirmado não muda; o provisório é derivado');
  });

  test('offline: saque acima do saldo provisório é recusado localmente', () async {
    api.offline = true;
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 10);
    expect(
      () => operacoes.movimentar(TipoOperacao.saque, agencia: 0, idConta: 0, valor: 500),
      throwsA(isA<ErroOffline>()),
    );
  });

  test('offline sem cache: pede para consultar a conta antes', () async {
    api.offline = true;
    expect(
      () => operacoes.movimentar(TipoOperacao.deposito, agencia: 1, idConta: 7, valor: 5),
      throwsA(isA<ErroOffline>()),
    );
  });

  test('ao reconectar, sincroniza a fila e o próximo pendente herda o novo vetor', () async {
    api.offline = true;
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 50);
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 20);
    api.offline = false;

    final r = await sync.sincronizar();
    expect(r.aplicadas, 2);
    expect(r.conflitos, 0);
    expect(api.saldo, 170);
    expect(repo.operacoes.values.every((o) => o.status == StatusOperacao.sincronizada), isTrue);
    expect(repo.contas[0]!.saldo, 170);
  });

  test('sem conexão durante a sincronização: volta tudo para pendente', () async {
    api.offline = true;
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 50);
    final r = await sync.sincronizar();
    expect(r.semConexao, isTrue);
    expect(repo.operacoes.values.single.status, StatusOperacao.pendente);
  });

  test('conflito: agência mudou enquanto offline, nada é aplicado e o estado real é guardado', () async {
    api.offline = true;
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 50);
    api.offline = false;
    api.saldo = 300;
    api.vetor = [4, 1, 0];

    final r = await sync.sincronizar();
    expect(r.conflitos, 1);
    expect(api.recebidas, isEmpty);
    final op = repo.operacoes.values.single;
    expect(op.status, StatusOperacao.conflito);
    expect(op.resposta!['vetorAtual'], [4, 1, 0]);
    expect(repo.contas[0]!.saldo, 300);
    expect(repo.contas[0]!.vetorAtual, [4, 1, 0]);
  });

  test('conflito resolvido com aplicar: reenvia com o vetor atual e conclui', () async {
    api.offline = true;
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 50);
    api.offline = false;
    api.saldo = 300;
    api.vetor = [4, 1, 0];
    await sync.sincronizar();

    final r = await sync.aplicarComEstadoAtual(repo.operacoes.values.single);
    expect(r.aplicadas, 1);
    expect(api.saldo, 350);
    expect(repo.operacoes.values.single.status, StatusOperacao.sincronizada);
  });

  test('conflito resolvido com descartar: a operação sai da fila', () async {
    api.offline = true;
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 50);
    api.offline = false;
    api.vetor = [3, 0, 0];
    await sync.sincronizar();

    await sync.descartar(repo.operacoes.values.single);
    expect(repo.operacoes, isEmpty);
    expect(api.recebidas, isEmpty);
  });

  test('operação recusada pela agência vira rejeitada, não conflito', () async {
    api.offline = true;
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 50);
    api.offline = false;
    api.statusFixo = 400;
    final r = await sync.sincronizar();
    expect(r.rejeitadas, 1);
    expect(repo.operacoes.values.single.status, StatusOperacao.rejeitada);
    expect(repo.operacoes.values.single.resposta!['erro'], 'Saldo insuficiente.');
  });

  test('token expirado durante a sincronização: para, mantém pendente e avisa', () async {
    api.offline = true;
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 50);
    api.offline = false;
    api.statusFixo = 401;
    final r = await sync.sincronizar();
    expect(r.sessaoExpirada, isTrue);
    expect(repo.operacoes.values.single.status, StatusOperacao.pendente);
  });

  test('nova operação com fila em conflito entra na fila em vez de ir direto', () async {
    api.offline = true;
    await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 50);
    api.offline = false;
    api.vetor = [3, 0, 0];
    await sync.sincronizar();

    final r = await operacoes.movimentar(TipoOperacao.deposito, agencia: 0, idConta: 0, valor: 5);
    expect(r.pendente, isTrue);
    expect(repo.operacoes.length, 2);
  });
}
