import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../compartilhado/widgets.dart';
import '../../core/rede/cliente_api.dart';
import '../../core/sessao/sessao.dart';
import '../../core/tema/tokens.dart';
import '../../dados/modelos.dart';
import '../../dados/modelos_locais.dart';
import '../../providers.dart';
import '../sincronizacao/dialogo_conflito.dart';
import 'folha_movimento.dart';

class TelaConta extends ConsumerStatefulWidget {
  const TelaConta({super.key});

  @override
  ConsumerState<TelaConta> createState() => _TelaContaState();
}

class _TelaContaState extends ConsumerState<TelaConta> {
  final _numero = TextEditingController();
  String? _erro;
  bool _consultando = false;

  @override
  void dispose() {
    _numero.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    final id = int.tryParse(_numero.text);
    if (id == null) return;
    setState(() {
      _consultando = true;
      _erro = null;
    });
    ref.read(contaSelecionadaProvider.notifier).definir(id);
    try {
      await ref.read(operacoesProvider).consultar(id % totalAgencias, id);
      ref.invalidate(lancamentosProvider(id));
    } on ErroApi catch (e) {
      if (e.sessaoExpirada) {
        await ref.read(sessaoProvider.notifier).sair();
        ref.read(avisosProvider.notifier).mostrar('Sua sessão expirou. Entre novamente.', erro: true);
      } else if (mounted) {
        setState(() => _erro = e.mensagem);
      }
    } on ErroRede catch (e) {
      final temCache = await ref.read(repositorioProvider).buscarConta(id) != null;
      if (mounted) {
        setState(() => _erro = temCache ? null : e.mensagem);
        if (temCache) {
          ref.read(avisosProvider.notifier).mostrar('Sem conexão. Mostrando o último saldo conhecido.', erro: false);
        }
      }
    } finally {
      if (mounted) setState(() => _consultando = false);
    }
  }

  Future<void> _resolver(OperacaoLocal op) async {
    final decisao = await mostrarDialogoConflito(context, op);
    if (!mounted || decisao == null) return;
    final sincronizacao = ref.read(sincronizacaoProvider.notifier);
    switch (decisao) {
      case DecisaoConflito.aplicar:
        await sincronizacao.aplicarComEstadoAtual(op);
      case DecisaoConflito.descartar:
        await sincronizacao.descartar(op);
      case DecisaoConflito.depois:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(contaSelecionadaProvider);
    final conta = id == null ? null : ref.watch(contaLocalProvider(id)).value;
    final operacoes = (ref.watch(operacoesLocaisProvider).value ?? const <OperacaoLocal>[])
        .where((o) => o.idConta == id && o.status != StatusOperacao.sincronizada)
        .toList();
    final aguardando = operacoes.where((o) => o.status.aguardando).toList();
    final provisorio = conta == null ? null : aguardando.fold<double>(conta.saldo, (s, o) => s + o.efeitoNoSaldo);
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(espaco16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _numero,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Número da conta', errorText: _erro),
                onChanged: (_) => setState(() => _erro = null),
                onSubmitted: (_) => _consultar(),
              ),
            ),
            const SizedBox(width: espaco12),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _consultando || int.tryParse(_numero.text) == null ? null : _consultar,
                child: const Text('Consultar'),
              ),
            ),
          ],
        ),
        const SizedBox(height: espaco16),
        if (conta == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: espaco24),
            child: Text(
              'Informe o número de uma conta com conexão para ver o saldo. '
              'Depois disso ele fica guardado e aparece mesmo offline.',
              style: tema.textTheme.bodyMedium,
            ),
          )
        else ...[
          _CartaoConta(conta: conta, provisorio: provisorio!, pendente: aguardando.isNotEmpty),
          const SizedBox(height: espaco16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => mostrarFolhaMovimento(context, tipo: TipoOperacao.deposito, idConta: conta.id),
                  child: const Text('Depositar'),
                ),
              ),
              const SizedBox(width: espaco12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => mostrarFolhaMovimento(context, tipo: TipoOperacao.saque, idConta: conta.id),
                  child: const Text('Sacar'),
                ),
              ),
            ],
          ),
          if (operacoes.isNotEmpty) ...[
            const SizedBox(height: espaco24),
            const Rotulo('Operações pendentes'),
            const SizedBox(height: espaco8),
            for (final op in operacoes) _LinhaPendente(op: op, aoResolver: () => _resolver(op)),
          ],
          const SizedBox(height: espaco24),
          const Rotulo('Lançamentos'),
          const SizedBox(height: espaco8),
          _Lancamentos(idConta: conta.id, posicao: conta.id % totalAgencias),
        ],
      ],
    );
  }
}

class _CartaoConta extends StatelessWidget {
  const _CartaoConta({required this.conta, required this.provisorio, required this.pendente});

  final ContaLocal conta;
  final double provisorio;
  final bool pendente;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = coresDoTema(context);
    return Container(
      decoration: BoxDecoration(
        color: tema.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(raioXs),
      ),
      child: MarcaDagua(
        ativa: pendente,
        child: Padding(
          padding: const EdgeInsets.all(espaco16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Rotulo('Titular'),
                      Text(conta.nomeAluno ?? '—', style: tema.textTheme.titleLarge),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Rotulo('Conta · Agência ${conta.agencia}'),
                      Text('${conta.id}', style: tema.textTheme.titleLarge),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: espaco16),
              Row(
                children: [
                  Rotulo(pendente ? 'Saldo provisório' : 'Saldo'),
                  const SizedBox(width: espaco8),
                  if (pendente) const ChipEstado('Pendente · sem série', tom: TomChip.alerta),
                ],
              ),
              Text(formatarMoeda(provisorio), style: tema.textTheme.displaySmall),
              const SizedBox(height: espaco8),
              if (pendente)
                Text('Confirmado: ${formatarMoeda(conta.saldo)}', style: tema.textTheme.bodyMedium?.copyWith(color: cores.tinta2)),
              Wrap(
                spacing: espaco8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Série atual', style: tema.textTheme.bodyMedium?.copyWith(color: cores.tinta2)),
                  ColunaSerie(vetor: conta.vetorAtual, posicao: conta.agencia),
                  Text(
                    'atualizado às ${horaCurta(conta.atualizadoEm)}',
                    style: tema.textTheme.bodyMedium?.copyWith(color: cores.tinta2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinhaPendente extends StatelessWidget {
  const _LinhaPendente({required this.op, required this.aoResolver});

  final OperacaoLocal op;
  final VoidCallback aoResolver;

  @override
  Widget build(BuildContext context) {
    final (rotulo, tom) = switch (op.status) {
      StatusOperacao.pendente => ('Pendente', TomChip.alerta),
      StatusOperacao.enviando => ('Enviando', TomChip.neutro),
      StatusOperacao.conflito => ('Conflito', TomChip.erro),
      StatusOperacao.rejeitada => ('Recusada', TomChip.erro),
      StatusOperacao.sincronizada => ('Sincronizada', TomChip.ok),
    };
    final erroResposta = op.resposta?['erro'];
    final motivo = op.status == StatusOperacao.rejeitada && erroResposta is String ? erroResposta : null;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: coresDoTema(context).regra))),
      padding: const EdgeInsets.symmetric(vertical: espaco8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(descreverOperacao(op), style: Theme.of(context).textTheme.titleMedium),
                if (motivo != null) Text(motivo, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          ChipEstado(rotulo, tom: tom),
          if (op.status == StatusOperacao.conflito) ...[
            const SizedBox(width: espaco8),
            TextButton(onPressed: aoResolver, child: const Text('Resolver')),
          ],
        ],
      ),
    );
  }
}

class _Lancamentos extends ConsumerWidget {
  const _Lancamentos({required this.idConta, required this.posicao});

  final int idConta;
  final int posicao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventos = ref.watch(lancamentosProvider(idConta));
    final cores = coresDoTema(context);
    return eventos.when(
      loading: () => const Esqueleto(largura: double.infinity, altura: 96),
      error: (_, _) => Text(
        'Lançamentos indisponíveis sem conexão.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cores.tinta2),
      ),
      data: (lista) => lista.isEmpty
          ? Text('Nenhum lançamento ainda.', style: Theme.of(context).textTheme.bodyMedium)
          : Column(
              children: [
                for (final e in lista)
                  Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cores.regra))),
                    padding: const EdgeInsets.symmetric(vertical: espaco8),
                    child: Row(
                      children: [
                        Expanded(child: Text(_rotuloEvento(e), style: Theme.of(context).textTheme.titleMedium)),
                        if (e.valor != null)
                          Padding(
                            padding: const EdgeInsets.only(right: espaco12),
                            child: Text('${_sinal(e)}${formatarMoeda(e.valor!)}'),
                          ),
                        ColunaSerie(vetor: e.vetor, posicao: posicao),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

String _rotuloEvento(EventoDto e) => switch (e.tipo) {
      'CRIAR_CONTA' => 'Conta aberta',
      'DEPOSITO' => 'Depósito',
      'SAQUE' => 'Saque',
      'TRANSFERENCIA_DEBITO' => 'Transferência enviada',
      'TRANSFERENCIA_CREDITO' => 'Transferência recebida',
      'TRANSFERENCIA_CREDITO_REMOTO' => 'Crédito de outra agência',
      'SINCRONIZACAO_OFFLINE' => 'Sincronização offline',
      _ => e.tipo,
    };

String _sinal(EventoDto e) => switch (e.tipo) {
      'DEPOSITO' || 'TRANSFERENCIA_CREDITO' || 'TRANSFERENCIA_CREDITO_REMOTO' => '+ ',
      'SAQUE' || 'TRANSFERENCIA_DEBITO' => '− ',
      'SINCRONIZACAO_OFFLINE' => e.detalhes['tipo'] == 'DEPOSITO' ? '+ ' : '− ',
      _ => '',
    };
