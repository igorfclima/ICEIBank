import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../compartilhado/widgets.dart';
import '../../core/rede/cliente_api.dart';
import '../../core/sessao/sessao.dart';
import '../../core/tema/tokens.dart';

class TelaLogin extends ConsumerStatefulWidget {
  const TelaLogin({super.key});

  @override
  ConsumerState<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends ConsumerState<TelaLogin> {
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  String? _erro;
  bool _ocupado = false;

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    final sessao = ref.read(sessaoProvider);
    try {
      await ref.read(sessaoProvider.notifier).entrar(sessao.agenciaId, _usuario.text, _senha.text);
    } on ErroApi catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } on ErroRede catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessao = ref.watch(sessaoProvider);
    final tema = Theme.of(context);
    final pronto = _usuario.text.isNotEmpty && _senha.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('ICEIBank')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.all(espaco24),
              children: [
                Text('Entrar', style: tema.textTheme.headlineMedium),
                const SizedBox(height: espaco24),
                const Rotulo('Agência de entrada'),
                const SizedBox(height: espaco8),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    for (var i = 0; i < totalAgencias; i++) ButtonSegment(value: i, label: Text('Ag. $i')),
                  ],
                  selected: {sessao.agenciaId},
                  onSelectionChanged: (s) => ref.read(sessaoProvider.notifier).trocarAgencia(s.first),
                ),
                const SizedBox(height: espaco16),
                TextField(
                  controller: _usuario,
                  decoration: const InputDecoration(labelText: 'Usuário'),
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: espaco16),
                TextField(
                  controller: _senha,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => pronto && !_ocupado ? _entrar() : null,
                ),
                const SizedBox(height: espaco24),
                FilledButton(
                  onPressed: pronto && !_ocupado ? _entrar : null,
                  child: Text(_ocupado ? 'Entrando…' : 'Entrar'),
                ),
                if (_erro != null) ...[
                  const SizedBox(height: espaco16),
                  BannerAviso(texto: _erro!, erro: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
