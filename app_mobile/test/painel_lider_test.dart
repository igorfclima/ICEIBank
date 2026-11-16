import 'package:flutter_test/flutter_test.dart';
import 'package:iceibank/core/rede/cliente_api.dart';
import 'package:iceibank/core/tema/tema.dart';
import 'package:iceibank/dados/modelos.dart';
import 'package:iceibank/funcionalidades/agencias/tela_agencias.dart';
import 'package:iceibank/providers.dart';
import 'package:material_ui/material_ui.dart';

class ApiLideranca extends ClienteApi {
  ApiLideranca(this.respostas) : super(() => null);

  final Map<int, int?> respostas;

  @override
  Future<Lideranca> lideranca(int agencia) async {
    if (!respostas.containsKey(agencia)) throw const ErroRede();
    return Lideranca(idAgencia: agencia, liderAtual: respostas[agencia], desde: DateTime(2026, 11, 16, 14, 32, 5));
  }
}

Widget _app(EstadoLideranca estado, {int entrada = 0, Brightness brilho = Brightness.light}) => MaterialApp(
      theme: construirTema(brilho, entrada),
      home: Scaffold(body: SingleChildScrollView(child: PainelLider(estado: estado, agenciaDeEntrada: entrada))),
    );

void main() {
  group('consultarLideranca', () {
    test('as três concordam: líder definida e todas ativas', () async {
      final e = await consultarLideranca(ApiLideranca({0: 2, 1: 2, 2: 2}), null);
      expect(e, isA<LiderancaDefinida>());
      expect((e as LiderancaDefinida).lider, 2);
      expect(e.ativas, {0: true, 1: true, 2: true});
    });

    test('líder caiu: quem responde concorda no novo líder e a outra aparece fora do ar', () async {
      final e = await consultarLideranca(ApiLideranca({0: 1, 1: 1}), 2);
      expect((e as LiderancaDefinida).lider, 1);
      expect(e.ativas, {0: true, 1: true, 2: false});
    });

    test('respostas divergentes: eleição em andamento, nunca escolhe uma ao acaso', () async {
      final e = await consultarLideranca(ApiLideranca({0: 2, 1: 1, 2: 2}), null);
      expect(e, isA<LiderancaEmEleicao>());
    });

    test('ninguém responde: mantém o último líder conhecido', () async {
      final e = await consultarLideranca(ApiLideranca({}), 2);
      expect(e, isA<LiderancaSemResposta>());
      expect((e as LiderancaSemResposta).ultimoLider, 2);
    });

    test('agências sem líder ainda contam como eleição não definida', () async {
      final e = await consultarLideranca(ApiLideranca({0: null, 1: null, 2: null}), null);
      expect(e, isA<LiderancaEmEleicao>());
    });
  });

  group('PainelLider', () {
    testWidgets('mostra a líder, a assinatura e a agência fora do ar', (t) async {
      await t.pumpWidget(_app(LiderancaDefinida({0: true, 1: true, 2: false}, 1, DateTime(2026, 11, 16, 14, 32, 5)), entrada: 0));
      await t.pumpAndSettle();
      expect(find.text('Agência 1'), findsWidgets);
      expect(find.text('Líder'), findsOneWidget);
      expect(find.text('Fora do ar'), findsOneWidget);
      expect(find.text('entrada'), findsOneWidget);
      expect(find.textContaining('Assina: Agência 1 · desde 14:32:05'), findsOneWidget);
    });

    testWidgets('a troca de líder atualiza o painel sozinha', (t) async {
      await t.pumpWidget(_app(LiderancaDefinida({0: true, 1: true, 2: true}, 2, null)));
      await t.pumpAndSettle();
      expect(find.textContaining('Assina: Agência 2'), findsOneWidget);

      await t.pumpWidget(_app(LiderancaDefinida({0: true, 1: true, 2: false}, 1, null)));
      await t.pumpAndSettle();
      expect(find.textContaining('Assina: Agência 1'), findsOneWidget);
      expect(find.textContaining('Assina: Agência 2'), findsNothing);
    });

    testWidgets('estado de eleição e sem resposta têm texto próprio', (t) async {
      await t.pumpWidget(_app(const LiderancaEmEleicao({0: true, 1: true, 2: true})));
      await t.pumpAndSettle();
      expect(find.text('Eleição em andamento'), findsOneWidget);

      await t.pumpWidget(_app(const LiderancaSemResposta({0: false, 1: false, 2: false}, 2)));
      await t.pumpAndSettle();
      expect(find.text('Sem resposta'), findsOneWidget);
      expect(find.textContaining('Último valor conhecido: Agência 2'), findsOneWidget);
    });

    testWidgets('renderiza no tema escuro com a agência 1 de entrada', (t) async {
      await t.pumpWidget(_app(LiderancaDefinida({0: true, 1: true, 2: true}, 2, null), entrada: 1, brilho: Brightness.dark));
      await t.pumpAndSettle();
      expect(find.text('Líder'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });
}
