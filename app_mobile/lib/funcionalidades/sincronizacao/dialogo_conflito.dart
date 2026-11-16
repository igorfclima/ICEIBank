import 'package:material_ui/material_ui.dart';

import '../../compartilhado/widgets.dart';
import '../../core/rede/cliente_api.dart';
import '../../core/tema/tokens.dart';
import '../../dados/modelos.dart';
import '../../dados/modelos_locais.dart';

enum DecisaoConflito { aplicar, descartar, depois }

String descreverOperacao(OperacaoLocal op) {
  final base = switch (op.tipo) {
    TipoOperacao.deposito => 'Depósito',
    TipoOperacao.saque => 'Saque',
    TipoOperacao.transferencia => 'Transferência para a conta ${op.idDestino}',
  };
  return '$base de ${formatarMoeda(op.valor)}';
}

Future<DecisaoConflito?> mostrarDialogoConflito(BuildContext context, OperacaoLocal op) {
  return showDialog<DecisaoConflito>(
    context: context,
    builder: (_) => _DialogoConflito(op: op),
  );
}

class _DialogoConflito extends StatelessWidget {
  const _DialogoConflito({required this.op});

  final OperacaoLocal op;

  List<int>? _vetor(String chave) {
    final v = op.resposta?[chave];
    return v is List ? v.map((e) => (e as num).toInt()).toList() : null;
  }

  @override
  Widget build(BuildContext context) {
    final cores = coresDoTema(context);
    final tema = Theme.of(context);
    final conta = op.resposta?['contaAtual'];
    final saldoReal = conta is Map ? (conta['saldo'] as num?)?.toDouble() : null;
    final posicao = op.agencia;
    final saqueSemSaldo = op.tipo != TipoOperacao.deposito && saldoReal != null && saldoReal < op.valor;

    return AlertDialog(
      title: const Text('Conflito de sincronização'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A agência registrou outras operações enquanto você estava offline, '
              'então esta operação não foi aplicada.',
              style: tema.textTheme.bodyMedium,
            ),
            const SizedBox(height: espaco16),
            const Rotulo('Operação pendente'),
            Text(descreverOperacao(op), style: tema.textTheme.titleMedium),
            const SizedBox(height: espaco12),
            const Rotulo('Saldo real agora'),
            Text(saldoReal == null ? '—' : formatarMoeda(saldoReal), style: tema.textTheme.titleLarge),
            const SizedBox(height: espaco12),
            const Rotulo('Série conhecida pelo app'),
            DefaultTextStyle.merge(
              style: const TextStyle(decoration: TextDecoration.lineThrough),
              child: ColunaSerie(vetor: _vetor('vetorConhecido'), posicao: posicao),
            ),
            const SizedBox(height: espaco4),
            const Rotulo('Série atual da agência'),
            ColunaSerie(vetor: _vetor('vetorAtual'), posicao: posicao),
            if (saqueSemSaldo) ...[
              const SizedBox(height: espaco16),
              Text(
                'O saldo real não cobre esta operação.',
                style: tema.textTheme.bodyMedium?.copyWith(color: cores.alerta),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, DecisaoConflito.depois),
          child: const Text('Decidir depois'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, DecisaoConflito.descartar),
          child: const Text('Descartar'),
        ),
        FilledButton(
          onPressed: saqueSemSaldo ? null : () => Navigator.pop(context, DecisaoConflito.aplicar),
          child: const Text('Aplicar agora'),
        ),
      ],
    );
  }
}

String mensagemDeErro(Object erro) {
  if (erro is ErroApi) return erro.mensagem;
  if (erro is ErroRede) return erro.mensagem;
  return erro.toString();
}
