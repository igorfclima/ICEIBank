import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import 'compartilhado/widgets.dart';
import 'core/sessao/sessao.dart';
import 'core/tema/tema.dart';
import 'funcionalidades/agencias/tela_agencias.dart';
import 'funcionalidades/conta/tela_conta.dart';
import 'funcionalidades/login/tela_login.dart';
import 'funcionalidades/transferir/tela_transferir.dart';
import 'providers.dart';

final roteadorProvider = Provider<GoRouter>((ref) {
  final mudancas = ValueNotifier<int>(0);
  ref.listen(sessaoProvider, (_, _) => mudancas.value++);
  ref.onDispose(mudancas.dispose);

  return GoRouter(
    initialLocation: '/conta',
    refreshListenable: mudancas,
    redirect: (context, estado) {
      final sessao = ref.read(sessaoProvider);
      if (!sessao.carregada) return null;
      final noLogin = estado.matchedLocation == '/login';
      if (!sessao.autenticada) return noLogin ? null : '/login';
      return noLogin ? '/conta' : null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const TelaLogin()),
      StatefulShellRoute.indexedStack(
        builder: (context, estado, shell) => CascaProduto(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/conta', builder: (_, _) => const TelaConta())]),
          StatefulShellBranch(routes: [GoRoute(path: '/transferir', builder: (_, _) => const TelaTransferir())]),
          StatefulShellBranch(routes: [GoRoute(path: '/agencias', builder: (_, _) => const TelaAgencias())]),
        ],
      ),
    ],
  );
});

class IceiApp extends ConsumerStatefulWidget {
  const IceiApp({super.key});

  @override
  ConsumerState<IceiApp> createState() => _IceiAppState();
}

class _IceiAppState extends ConsumerState<IceiApp> {
  late final AppLifecycleListener _ciclo;

  @override
  void initState() {
    super.initState();
    ref.read(sessaoProvider.notifier).restaurar();
    _ciclo = AppLifecycleListener(onResume: () => ref.read(sincronizacaoProvider.notifier).executar());
  }

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(conectividadeProvider, (anterior, atual) {
      final voltou = atual.value == true && anterior?.value == false;
      if (voltou) ref.read(sincronizacaoProvider.notifier).executar();
    });
    ref.listen(sessaoProvider.select((s) => s.autenticada), (_, autenticada) {
      if (autenticada) ref.read(sincronizacaoProvider.notifier).executar();
    });

    final sessao = ref.watch(sessaoProvider);
    final roteador = ref.watch(roteadorProvider);

    return MaterialApp.router(
      title: 'ICEIBank',
      debugShowCheckedModeBanner: false,
      theme: construirTema(Brightness.light, sessao.agenciaId),
      darkTheme: construirTema(Brightness.dark, sessao.agenciaId),
      themeMode: ThemeMode.system,
      routerConfig: roteador,
      builder: (context, filho) => sessao.carregada ? filho! : const _Carregando(),
    );
  }
}

class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ICEIBank')),
        body: const SizedBox.expand(),
      );
}

class CascaProduto extends ConsumerWidget {
  const CascaProduto({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(avisosProvider, (_, aviso) {
      if (aviso == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(aviso.texto), duration: const Duration(seconds: 4)));
      ref.read(avisosProvider.notifier).limpar();
    });

    final conectado = ref.watch(conectividadeProvider).value ?? true;
    final operacoes = ref.watch(operacoesLocaisProvider).value ?? const [];
    final aguardando = operacoes.where((o) => o.status.aguardando).length;
    final sincronizando = ref.watch(sincronizacaoProvider).emAndamento;
    final sessao = ref.watch(sessaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ICEIBank'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(sessao.usuario ?? '', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onPrimary),
            onPressed: () => ref.read(sessaoProvider.notifier).sair(),
            child: const Text('Sair'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!conectado || aguardando > 0 || sincronizando)
            BannerAviso(
              alerta: true,
              texto: sincronizando
                  ? 'Sincronizando…'
                  : conectado
                      ? '$aguardando ${aguardando == 1 ? 'operação pendente' : 'operações pendentes'}'
                      : 'Sem conexão${aguardando > 0 ? ' · $aguardando pendente${aguardando == 1 ? '' : 's'}' : ''}',
              acao: conectado && aguardando > 0 && !sincronizando
                  ? TextButton(
                      onPressed: () => ref.read(sincronizacaoProvider.notifier).executar(),
                      child: const Text('Tentar agora'),
                    )
                  : null,
            ),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) {
          ref.read(abaAtualProvider.notifier).definir(i);
          shell.goBranch(i, initialLocation: i == shell.currentIndex);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Symbols.account_balance_wallet), label: 'Conta'),
          NavigationDestination(icon: Icon(Symbols.swap_horiz), label: 'Transferir'),
          NavigationDestination(icon: Icon(Symbols.hub), label: 'Agências'),
        ],
      ),
    );
  }
}
