import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../compartilhado/widgets.dart';
import '../../core/rede/cliente_api.dart';
import '../../core/sessao/sessao.dart';
import '../../core/tema/tokens.dart';
import '../../providers.dart';

class TelaAgencias extends ConsumerWidget {
  const TelaAgencias({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessao = ref.watch(sessaoProvider);
    final lideranca = ref.watch(liderancaProvider);
    final estado = lideranca.value ?? const LiderancaCarregando();
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(espaco16),
      children: [
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
        const SizedBox(height: espaco24),
        PainelLider(estado: estado, agenciaDeEntrada: sessao.agenciaId),
        const SizedBox(height: espaco16),
        Text(
          'O app consulta as três agências a cada 5 segundos e mostra o líder em que a maioria concorda.',
          style: tema.textTheme.bodyMedium?.copyWith(color: coresDoTema(context).tinta2),
        ),
      ],
    );
  }
}

class PainelLider extends StatelessWidget {
  const PainelLider({super.key, required this.estado, required this.agenciaDeEntrada});

  final EstadoLideranca estado;
  final int agenciaDeEntrada;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = coresDoTema(context);
    final esquema = tema.colorScheme;
    final lider = estado is LiderancaDefinida ? (estado as LiderancaDefinida).lider : null;
    final desde = estado is LiderancaDefinida ? (estado as LiderancaDefinida).desde : null;

    final (titulo, chave) = switch (estado) {
      LiderancaCarregando() => ('', 'carregando'),
      LiderancaDefinida(:final lider) => ('Agência $lider', 'lider-$lider'),
      LiderancaEmEleicao() => ('Eleição em andamento', 'eleicao'),
      LiderancaSemResposta() => ('Sem resposta', 'sem-resposta'),
    };

    return Container(
      decoration: BoxDecoration(border: Border.all(color: cores.regra)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(espaco16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Rotulo('Liderança entre as agências'),
                const SizedBox(height: espaco8),
                MergeSemantics(
                  child: Semantics(
                    liveRegion: true,
                    child: AnimatedSwitcher(
                      duration: duracaoVirada,
                      switchInCurve: const Cubic(0.2, 0, 0, 1),
                      transitionBuilder: (filho, animacao) => FadeTransition(
                        opacity: animacao,
                        child: SlideTransition(
                          position: Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(animacao),
                          child: filho,
                        ),
                      ),
                      child: Container(
                        key: ValueKey(chave),
                        constraints: const BoxConstraints(minHeight: 48),
                        alignment: Alignment.centerLeft,
                        child: estado is LiderancaCarregando
                            ? const Esqueleto(largura: 180, altura: 36)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(titulo, style: tema.textTheme.displaySmall),
                                  if (estado is LiderancaEmEleicao)
                                    Text('As agências ainda divergem sobre quem lidera.', style: tema.textTheme.bodyMedium),
                                  if (estado case LiderancaSemResposta(:final ultimoLider))
                                    Text(
                                      ultimoLider == null
                                          ? 'Nenhuma agência respondeu.'
                                          : 'Nenhuma agência respondeu. Último valor conhecido: Agência $ultimoLider.',
                                      style: tema.textTheme.bodyMedium,
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < totalAgencias; i++)
            _LinhaAgencia(
              id: i,
              entrada: i == agenciaDeEntrada,
              lider: lider == i,
              ativa: estado is LiderancaCarregando ? null : (estado.ativas[i] ?? false),
            ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(border: Border(top: BorderSide(color: cores.regra))),
            padding: const EdgeInsets.all(espaco16),
            child: Text(
              lider == null ? 'Assina: —' : 'Assina: Agência $lider${desde == null ? '' : ' · desde ${horaCurta(desde)}'}',
              style: estiloSerie(cor: esquema.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaAgencia extends StatelessWidget {
  const _LinhaAgencia({required this.id, required this.entrada, required this.lider, required this.ativa});

  final int id;
  final bool entrada;
  final bool lider;
  final bool? ativa;

  @override
  Widget build(BuildContext context) {
    final cores = coresDoTema(context);
    final esquema = Theme.of(context).colorScheme;
    final fundo = entrada ? esquema.primary : null;
    final letra = entrada ? esquema.onPrimary : esquema.onSurface;
    final foraDoAr = ativa == false;

    Widget chip(String texto, TomChip tom) => entrada ? _ChipSobre(texto: texto, cor: letra) : ChipEstado(texto, tom: tom);

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(color: fundo, border: Border(top: BorderSide(color: cores.regra))),
      padding: const EdgeInsets.symmetric(horizontal: espaco16, vertical: espaco8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: foraDoAr ? null : cores.agencia(id),
              border: foraDoAr ? Border.all(color: cores.tinta2) : null,
            ),
          ),
          const SizedBox(width: espaco12),
          Text('Agência $id', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: letra)),
          if (entrada) ...[
            const SizedBox(width: espaco8),
            Text('entrada', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: letra, fontSize: 12)),
          ],
          const Spacer(),
          if (lider) chip('Líder', TomChip.lider),
          if (ativa == true && !lider) chip('Ativa', TomChip.ok),
          if (foraDoAr) chip('Fora do ar', TomChip.alerta),
        ],
      ),
    );
  }
}

class _ChipSobre extends StatelessWidget {
  const _ChipSobre({required this.texto, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: espaco8, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: cor),
          borderRadius: BorderRadius.circular(raioSm),
        ),
        child: Text(
          texto,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(color: cor, fontSize: 12, height: 16 / 12),
        ),
      );
}
