import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../core/tema/tokens.dart';

final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

String formatarMoeda(double valor) => _moeda.format(valor);

IceiCores coresDoTema(BuildContext context) => Theme.of(context).extension<IceiCores>()!;

class Rotulo extends StatelessWidget {
  const Rotulo(this.texto, {super.key, this.cor});

  final String texto;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelSmall!;
    return Text(texto.toUpperCase(), style: cor == null ? estilo : estilo.copyWith(color: cor));
  }
}

enum TomChip { neutro, lider, ok, alerta, erro }

class ChipEstado extends StatelessWidget {
  const ChipEstado(this.texto, {super.key, this.tom = TomChip.neutro});

  final String texto;
  final TomChip tom;

  @override
  Widget build(BuildContext context) {
    final cores = coresDoTema(context);
    final esquema = Theme.of(context).colorScheme;
    final (borda, fundo, letra) = switch (tom) {
      TomChip.neutro => (cores.tinta2, const Color(0x00000000), cores.tinta2),
      TomChip.lider => (esquema.onSurface, esquema.onSurface, esquema.surface),
      TomChip.ok => (cores.sucesso, const Color(0x00000000), cores.sucesso),
      TomChip.alerta => (cores.alerta, const Color(0x00000000), cores.alerta),
      TomChip.erro => (esquema.error, const Color(0x00000000), esquema.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: espaco8, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        border: Border.all(color: borda),
        borderRadius: BorderRadius.circular(raioSm),
      ),
      child: Text(
        texto,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: letra, fontSize: 12, height: 16 / 12),
      ),
    );
  }
}

class ColunaSerie extends StatelessWidget {
  const ColunaSerie({super.key, required this.vetor, required this.posicao});

  final List<int>? vetor;
  final int posicao;

  @override
  Widget build(BuildContext context) {
    final cores = coresDoTema(context);
    final base = estiloSerie(cor: Theme.of(context).colorScheme.onSurface);
    if (vetor == null || vetor!.isEmpty) {
      return Text('[— · — · —]', style: base.copyWith(color: cores.tinta2));
    }
    final partes = <InlineSpan>[const TextSpan(text: '[')];
    for (var i = 0; i < vetor!.length; i++) {
      if (i > 0) partes.add(const TextSpan(text: ' · '));
      partes.add(
        TextSpan(
          text: '${vetor![i]}',
          style: i == posicao ? base.copyWith(fontWeight: FontWeight.w700) : base.copyWith(color: cores.tinta2),
        ),
      );
    }
    partes.add(const TextSpan(text: ']'));
    return Semantics(
      label: 'série ${vetor!.join(' ')}',
      excludeSemantics: true,
      child: Text.rich(TextSpan(style: base, children: partes)),
    );
  }
}

class BannerAviso extends StatelessWidget {
  const BannerAviso({super.key, required this.texto, this.erro = false, this.alerta = false, this.acao});

  final String texto;
  final bool erro;
  final bool alerta;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final cores = coresDoTema(context);
    final esquema = Theme.of(context).colorScheme;
    final cor = erro ? esquema.error : (alerta ? cores.alerta : cores.sucesso);
    final rotulo = erro ? 'Erro' : (alerta ? 'Atenção' : 'Feito');
    return Semantics(
      liveRegion: true,
      child: Container(
        decoration: BoxDecoration(
          color: cores.papel2,
          border: Border.all(color: cor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: espaco16, vertical: espaco12),
        child: Row(
          children: [
            Rotulo(rotulo, cor: cor),
            const SizedBox(width: espaco12),
            Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
            ?acao,
          ],
        ),
      ),
    );
  }
}

class MarcaDagua extends StatelessWidget {
  const MarcaDagua({super.key, required this.child, this.ativa = true});

  final Widget child;
  final bool ativa;

  @override
  Widget build(BuildContext context) {
    if (!ativa) return child;
    return CustomPaint(
      painter: _PintorHachura(coresDoTema(context).regra),
      child: child,
    );
  }
}

class _PintorHachura extends CustomPainter {
  _PintorHachura(this.cor);

  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = cor
      ..strokeWidth = 1;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (double x = -size.height; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), pincel);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorHachura antigo) => antigo.cor != cor;
}

class Esqueleto extends StatelessWidget {
  const Esqueleto({super.key, this.largura = 160, this.altura = 24});

  final double largura;
  final double altura;

  @override
  Widget build(BuildContext context) =>
      Container(width: largura, height: altura, color: coresDoTema(context).papel2);
}

String horaCurta(DateTime momento) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(momento.hour)}:${dois(momento.minute)}:${dois(momento.second)}';
}
