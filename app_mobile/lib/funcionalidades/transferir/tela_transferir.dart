import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../compartilhado/widgets.dart';
import '../../core/rede/cliente_api.dart';
import '../../core/sessao/sessao.dart';
import '../../core/tema/tokens.dart';
import '../../providers.dart';
import '../sincronizacao/dialogo_conflito.dart';

class TelaTransferir extends ConsumerStatefulWidget {
  const TelaTransferir({super.key});

  @override
  ConsumerState<TelaTransferir> createState() => _TelaTransferirState();
}

class _TelaTransferirState extends ConsumerState<TelaTransferir> {
  final _origem = TextEditingController();
  final _destino = TextEditingController();
  final _valor = TextEditingController();
  ({String texto, bool erro, bool pendente})? _resultado;
  bool _ocupado = false;

  @override
  void dispose() {
    _origem.dispose();
    _destino.dispose();
    _valor.dispose();
    super.dispose();
  }

  int? get _idOrigem => int.tryParse(_origem.text);
  int? get _idDestino => int.tryParse(_destino.text);
  double? get _numero => double.tryParse(_valor.text.replaceAll(',', '.'));
  bool get _completo => _idOrigem != null && _idDestino != null && (_numero ?? 0) > 0;

  Future<void> _transferir() async {
    setState(() {
      _ocupado = true;
      _resultado = null;
    });
    try {
      final r = await ref.read(operacoesProvider).transferir(
            agencia: _idOrigem! % totalAgencias,
            origem: _idOrigem!,
            destino: _idDestino!,
            valor: _numero!,
          );
      ref.invalidate(lancamentosProvider(_idOrigem!));
      if (mounted) setState(() => _resultado = (texto: r.mensagem, erro: false, pendente: r.pendente));
    } on ErroApi catch (e) {
      if (e.sessaoExpirada) {
        await ref.read(sessaoProvider.notifier).sair();
        ref.read(avisosProvider.notifier).mostrar('Sua sessão expirou. Entre novamente.', erro: true);
      } else if (mounted) {
        setState(() => _resultado = (texto: e.mensagem, erro: true, pendente: false));
      }
    } on Object catch (e) {
      if (mounted) setState(() => _resultado = (texto: mensagemDeErro(e), erro: true, pendente: false));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = coresDoTema(context);
    return ListView(
      padding: const EdgeInsets.all(espaco16),
      children: [
        Text('Transferência', style: tema.textTheme.headlineMedium),
        const SizedBox(height: espaco4),
        Text(
          'Local ou entre agências. O destino é resolvido pela agência da conta de origem.',
          style: tema.textTheme.bodyMedium?.copyWith(color: cores.tinta2),
        ),
        const SizedBox(height: espaco24),
        TextField(
          controller: _origem,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Conta de origem'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: espaco16),
        TextField(
          controller: _destino,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Conta de destino'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: espaco16),
        TextField(
          controller: _valor,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
          decoration: const InputDecoration(labelText: 'Valor em reais'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: espaco24),
        FilledButton(
          onPressed: _completo && !_ocupado ? _transferir : null,
          child: Text(_ocupado ? 'Enviando…' : 'Transferir'),
        ),
        if (_resultado != null) ...[
          const SizedBox(height: espaco16),
          BannerAviso(
            texto: _resultado!.texto,
            erro: _resultado!.erro,
            alerta: _resultado!.pendente,
          ),
        ],
      ],
    );
  }
}
