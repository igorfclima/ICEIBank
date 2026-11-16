import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/rede/cliente_api.dart';
import '../../core/sessao/sessao.dart';
import '../../core/tema/tokens.dart';
import '../../dados/modelos.dart';
import '../../dados/servico_operacoes.dart';
import '../../providers.dart';
import '../sincronizacao/dialogo_conflito.dart';

Future<void> mostrarFolhaMovimento(BuildContext context, {required TipoOperacao tipo, required int idConta}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => FolhaMovimento(tipo: tipo, idConta: idConta),
  );
}

class FolhaMovimento extends ConsumerStatefulWidget {
  const FolhaMovimento({super.key, required this.tipo, required this.idConta});

  final TipoOperacao tipo;
  final int idConta;

  @override
  ConsumerState<FolhaMovimento> createState() => _FolhaMovimentoState();
}

class _FolhaMovimentoState extends ConsumerState<FolhaMovimento> {
  final _valor = TextEditingController();
  String? _erro;
  bool _ocupado = false;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  double? get _numero => double.tryParse(_valor.text.replaceAll(',', '.'));

  Future<void> _confirmar() async {
    final valor = _numero;
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe um valor maior que zero.');
      return;
    }
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    final navegador = Navigator.of(context);
    try {
      final r = await ref.read(operacoesProvider).movimentar(
            widget.tipo,
            agencia: widget.idConta % totalAgencias,
            idConta: widget.idConta,
            valor: valor,
          );
      ref.invalidate(lancamentosProvider(widget.idConta));
      ref.read(avisosProvider.notifier).mostrar(r.mensagem);
      navegador.pop();
    } on ErroOffline catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } on Object catch (e) {
      if (e is ErroApi && e.sessaoExpirada) {
        navegador.pop();
        await ref.read(sessaoProvider.notifier).sair();
        ref.read(avisosProvider.notifier).mostrar('Sua sessão expirou. Entre novamente.', erro: true);
        return;
      }
      if (mounted) setState(() => _erro = mensagemDeErro(e));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final titulo = widget.tipo == TipoOperacao.deposito ? 'Depositar' : 'Sacar';
    return Padding(
      padding: EdgeInsets.fromLTRB(espaco24, 0, espaco24, MediaQuery.of(context).viewInsets.bottom + espaco24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$titulo na conta ${widget.idConta}', style: tema.textTheme.titleLarge),
          const SizedBox(height: espaco16),
          TextField(
            controller: _valor,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            decoration: InputDecoration(labelText: 'Valor em reais', errorText: _erro),
            onChanged: (_) => setState(() => _erro = null),
            onSubmitted: (_) => _ocupado ? null : _confirmar(),
          ),
          const SizedBox(height: espaco16),
          FilledButton(
            onPressed: _ocupado || _numero == null ? null : _confirmar,
            child: Text(_ocupado ? 'Enviando…' : titulo),
          ),
        ],
      ),
    );
  }
}
