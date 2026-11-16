import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iceibank/app.dart';
import 'package:iceibank/compartilhado/widgets.dart' show formatarMoeda;
import 'package:iceibank/core/rede/cliente_api.dart';
import 'package:iceibank/core/sessao/sessao.dart';
import 'package:iceibank/dados/modelos.dart';
import 'package:iceibank/providers.dart';
import 'package:material_ui/material_ui.dart';

import 'servico_sincronizacao_test.dart' show RepositorioMemoria;

class ArmazenamentoMemoria implements ArmazenamentoSessao {
  final dados = <String, String>{};

  @override
  Future<String?> ler(String chave) async => dados[chave];

  @override
  Future<void> gravar(String chave, String valor) async => dados[chave] = valor;

  @override
  Future<void> apagar(String chave) async => dados.remove(chave);
}

class ApiDaTela extends ClienteApi {
  ApiDaTela() : super(() => null);

  bool offline = false;
  int saldo = 100;
  List<int> vetor = [1, 0, 0];

  static const _tokenFalso = 'e30.eyJzdWIiOiJhbmEiLCJwYXBlbCI6ImNsaWVudGUiLCJleHAiOjQxMDI0NDQ4MDB9.assinatura';

  ContaDto _conta() => ContaDto(id: 0, saldo: saldo.toDouble(), vetorAtual: List.of(vetor), nomeAluno: 'Ana Souza', dono: 'ana');

  @override
  Future<String> login(int agencia, String usuario, String senha) async {
    if (senha != 'ana123') throw const ErroApi(401, 'Credenciais inválidas.');
    return _tokenFalso;
  }

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
  Future<List<EventoDto>> historico(int agencia, int id, {int limite = 10}) async {
    if (offline) throw const ErroRede();
    return [
      EventoDto(tipo: 'CRIAR_CONTA', vetor: [1, 0, 0], hora: DateTime(2026, 11, 16, 12), detalhes: const {}),
    ];
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
    if (vetorConhecido.join() != vetor.join()) {
      throw ErroApi(409, 'Conflito detectado', {
        'erro': 'Conflito detectado',
        'vetorConhecido': vetorConhecido,
        'vetorAtual': List.of(vetor),
        'contaAtual': {'id': idConta, 'saldo': saldo, 'nomeAluno': 'Ana Souza'},
      });
    }
    saldo += valor.toInt();
    vetor[0]++;
    return _conta();
  }
}

Future<void> _entrar(WidgetTester t) async {
  await t.enterText(find.widgetWithText(TextField, 'Usuário'), 'ana');
  await t.enterText(find.widgetWithText(TextField, 'Senha'), 'ana123');
  await t.pump();
  await t.tap(find.widgetWithText(FilledButton, 'Entrar'));
  await t.pumpAndSettle();
}

Future<void> _consultarConta(WidgetTester t) async {
  await t.enterText(find.widgetWithText(TextField, 'Número da conta'), '0');
  await t.pump();
  await t.tap(find.widgetWithText(FilledButton, 'Consultar'));
  await t.pumpAndSettle();
}

void main() {
  late ApiDaTela api;
  late RepositorioMemoria repo;
  late StreamController<bool> conexao;

  Future<void> subir(WidgetTester t) async {
    api = ApiDaTela();
    repo = RepositorioMemoria();
    conexao = StreamController<bool>.broadcast();
    addTearDown(conexao.close);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          armazenamentoProvider.overrideWithValue(ArmazenamentoMemoria()),
          apiProvider.overrideWithValue(api),
          repositorioProvider.overrideWithValue(repo),
          conectividadeProvider.overrideWith((ref) async* {
            yield true;
            yield* conexao.stream;
          }),
          liderancaProvider.overrideWith((ref) => Stream.value(const LiderancaDefinida({0: true, 1: true, 2: true}, 2, null))),
        ],
        child: const IceiApp(),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('sem sessão abre o login e recusa senha errada com mensagem na tela', (t) async {
    await subir(t);
    expect(find.text('Entrar'), findsWidgets);
    await t.enterText(find.widgetWithText(TextField, 'Usuário'), 'ana');
    await t.enterText(find.widgetWithText(TextField, 'Senha'), 'errada');
    await t.pump();
    await t.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await t.pumpAndSettle();
    expect(find.text('Credenciais inválidas.'), findsOneWidget);
  });

  testWidgets('fluxo offline: guarda pendente com saldo provisório e sincroniza sozinho ao reconectar', (t) async {
    await subir(t);
    await _entrar(t);
    expect(find.text('Conta'), findsWidgets);

    await _consultarConta(t);
    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text(formatarMoeda(100)), findsOneWidget);
    expect(find.text('Pendente · sem série'), findsNothing);

    api.offline = true;
    conexao.add(false);
    await t.pumpAndSettle();
    expect(find.text('Sem conexão'), findsOneWidget);

    await t.tap(find.widgetWithText(FilledButton, 'Depositar'));
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextField, 'Valor em reais'), '50');
    await t.pump();
    await t.tap(find.widgetWithText(FilledButton, 'Depositar').last);
    await t.pumpAndSettle();

    expect(find.text('SALDO PROVISÓRIO'), findsOneWidget);
    expect(find.text(formatarMoeda(150)), findsOneWidget);
    expect(find.text('Pendente · sem série'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.textContaining('Confirmado: ${formatarMoeda(100)}'), findsOneWidget);

    api.offline = false;
    conexao.add(true);
    await t.pumpAndSettle();

    expect(find.text('SALDO PROVISÓRIO'), findsNothing);
    expect(find.text('Pendente · sem série'), findsNothing);
    expect(find.text(formatarMoeda(150)), findsOneWidget);
    expect(api.saldo, 150);
  });

  testWidgets('conflito: a agência mudou offline, o app avisa e mostra o estado real', (t) async {
    await subir(t);
    await _entrar(t);
    await _consultarConta(t);

    api.offline = true;
    conexao.add(false);
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(FilledButton, 'Depositar'));
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextField, 'Valor em reais'), '50');
    await t.pump();
    await t.tap(find.widgetWithText(FilledButton, 'Depositar').last);
    await t.pumpAndSettle();

    api
      ..saldo = 400
      ..vetor = [5, 2, 0]
      ..offline = false;
    conexao.add(true);
    await t.pumpAndSettle();

    expect(find.text('Conflito'), findsOneWidget);
    expect(find.text('Resolver'), findsOneWidget);
    expect(api.saldo, 400, reason: 'nada foi aplicado às cegas');

    await t.ensureVisible(find.text('Resolver'));
    await t.pumpAndSettle();
    await t.tap(find.text('Resolver'));
    await t.pumpAndSettle();
    expect(find.text('Conflito de sincronização'), findsOneWidget);
    expect(find.text(formatarMoeda(400)), findsWidgets);
    expect(find.text('Descartar'), findsOneWidget);

    await t.tap(find.widgetWithText(FilledButton, 'Aplicar agora'));
    await t.pumpAndSettle();
    expect(api.saldo, 450);
    expect(find.text('Conflito'), findsNothing);
  });
}
