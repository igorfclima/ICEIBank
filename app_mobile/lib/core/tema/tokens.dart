import 'package:material_ui/material_ui.dart';

const duracaoRapido = Duration(milliseconds: 120);
const duracaoPadrao = Duration(milliseconds: 200);
const duracaoVirada = Duration(milliseconds: 240);

const raioXs = 2.0;
const raioSm = 6.0;

const espaco4 = 4.0;
const espaco8 = 8.0;
const espaco12 = 12.0;
const espaco16 = 16.0;
const espaco24 = 24.0;
const espaco32 = 32.0;

class IceiCores extends ThemeExtension<IceiCores> {
  const IceiCores({
    required this.papel2,
    required this.tinta2,
    required this.regra,
    required this.ag0,
    required this.ag1,
    required this.ag2,
    required this.alerta,
    required this.sucesso,
  });

  final Color papel2;
  final Color tinta2;
  final Color regra;
  final Color ag0;
  final Color ag1;
  final Color ag2;
  final Color alerta;
  final Color sucesso;

  Color agencia(int id) => switch (id) {
        0 => ag0,
        1 => ag1,
        _ => ag2,
      };

  static const claro = IceiCores(
    papel2: Color(0xFFEAE8E1),
    tinta2: Color(0xFF5C5A55),
    regra: Color(0x241C1B19),
    ag0: Color(0xFF157A89),
    ag1: Color(0xFFD9A520),
    ag2: Color(0xFF8A5A2B),
    alerta: Color(0xFF9A4A06),
    sucesso: Color(0xFF2E7D32),
  );

  static const escuro = IceiCores(
    papel2: Color(0xFF1F1E1B),
    tinta2: Color(0xFFB5B2AA),
    regra: Color(0x24F3F2EE),
    ag0: Color(0xFF3FB0C0),
    ag1: Color(0xFFE6B935),
    ag2: Color(0xFFC68A4E),
    alerta: Color(0xFFE08A3C),
    sucesso: Color(0xFF5BB960),
  );

  @override
  IceiCores copyWith({
    Color? papel2,
    Color? tinta2,
    Color? regra,
    Color? ag0,
    Color? ag1,
    Color? ag2,
    Color? alerta,
    Color? sucesso,
  }) =>
      IceiCores(
        papel2: papel2 ?? this.papel2,
        tinta2: tinta2 ?? this.tinta2,
        regra: regra ?? this.regra,
        ag0: ag0 ?? this.ag0,
        ag1: ag1 ?? this.ag1,
        ag2: ag2 ?? this.ag2,
        alerta: alerta ?? this.alerta,
        sucesso: sucesso ?? this.sucesso,
      );

  @override
  IceiCores lerp(ThemeExtension<IceiCores>? other, double t) {
    if (other is! IceiCores) return this;
    return IceiCores(
      papel2: Color.lerp(papel2, other.papel2, t)!,
      tinta2: Color.lerp(tinta2, other.tinta2, t)!,
      regra: Color.lerp(regra, other.regra, t)!,
      ag0: Color.lerp(ag0, other.ag0, t)!,
      ag1: Color.lerp(ag1, other.ag1, t)!,
      ag2: Color.lerp(ag2, other.ag2, t)!,
      alerta: Color.lerp(alerta, other.alerta, t)!,
      sucesso: Color.lerp(sucesso, other.sucesso, t)!,
    );
  }
}

const papelClaro = Color(0xFFF3F2EE);
const tintaClara = Color(0xFF1C1B19);
const erroClaro = Color(0xFFB3261E);
const papelEscuro = Color(0xFF141412);
const tintaEscura = Color(0xFFF3F2EE);
const erroEscuro = Color(0xFFE5484D);

Color sobreAgencia(int agencia, Brightness brilho) {
  if (brilho == Brightness.dark) return papelEscuro;
  return agencia == 1 ? tintaClara : const Color(0xFFFFFFFF);
}

const familiaSerie = 'CourierPrime';

TextStyle estiloArchivo({
  required double tamanho,
  required double altura,
  double largura = 100,
  double peso = 400,
  Color? cor,
  double espacamento = 0,
}) {
  return TextStyle(
    fontFamily: 'Archivo',
    fontSize: tamanho,
    height: altura / tamanho,
    fontWeight: FontWeight.values[((peso / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wdth', largura), FontVariation('wght', peso)],
    fontFeatures: const [FontFeature.tabularFigures()],
    letterSpacing: espacamento,
    color: cor,
  );
}

TextStyle estiloSerie({Color? cor, bool negrito = false}) => TextStyle(
      fontFamily: familiaSerie,
      fontSize: 13,
      height: 18 / 13,
      fontWeight: negrito ? FontWeight.w700 : FontWeight.w400,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: cor,
    );
