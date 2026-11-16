import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

ThemeData construirTema(Brightness brilho, int agencia) {
  final escuro = brilho == Brightness.dark;
  final cores = escuro ? IceiCores.escuro : IceiCores.claro;
  final papel = escuro ? papelEscuro : papelClaro;
  final tinta = escuro ? tintaEscura : tintaClara;
  final erro = escuro ? erroEscuro : erroClaro;
  final corAgencia = cores.agencia(agencia);
  final sobre = sobreAgencia(agencia, brilho);

  final esquema = ColorScheme(
    brightness: brilho,
    primary: corAgencia,
    onPrimary: sobre,
    secondary: tinta,
    onSecondary: papel,
    error: erro,
    onError: escuro ? papelEscuro : const Color(0xFFFFFFFF),
    surface: papel,
    onSurface: tinta,
    surfaceContainerLowest: papel,
    surfaceContainerLow: papel,
    surfaceContainer: cores.papel2,
    surfaceContainerHigh: cores.papel2,
    surfaceContainerHighest: cores.papel2,
    onSurfaceVariant: cores.tinta2,
    outline: cores.tinta2,
    outlineVariant: cores.regra,
    secondaryContainer: Color.alphaBlend(corAgencia.withValues(alpha: 0.16), papel),
    onSecondaryContainer: tinta,
    primaryContainer: Color.alphaBlend(corAgencia.withValues(alpha: 0.16), papel),
    onPrimaryContainer: tinta,
    surfaceTint: const Color(0x00000000),
  );

  final texto = TextTheme(
    displaySmall: estiloArchivo(tamanho: 36, altura: 40, largura: 112, peso: 700, cor: tinta),
    headlineMedium: estiloArchivo(tamanho: 28, altura: 32, peso: 600, cor: tinta),
    titleLarge: estiloArchivo(tamanho: 20, altura: 28, peso: 600, cor: tinta),
    titleMedium: estiloArchivo(tamanho: 16, altura: 24, peso: 600, cor: tinta),
    bodyLarge: estiloArchivo(tamanho: 16, altura: 24, cor: tinta),
    bodyMedium: estiloArchivo(tamanho: 14, altura: 20, cor: tinta),
    labelLarge: estiloArchivo(tamanho: 16, altura: 24, peso: 600, cor: tinta),
    labelMedium: estiloArchivo(tamanho: 14, altura: 20, peso: 600, cor: tinta),
    labelSmall: estiloArchivo(
      tamanho: 12,
      altura: 16,
      largura: 75,
      peso: 600,
      espacamento: 0.72,
      cor: cores.tinta2,
    ),
  );

  final forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(raioSm));
  const alvo = Size(64, 48);

  return ThemeData(
    useMaterial3: true,
    brightness: brilho,
    colorScheme: esquema,
    scaffoldBackgroundColor: papel,
    textTheme: texto,
    extensions: [cores],
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: corAgencia,
      foregroundColor: sobre,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: estiloArchivo(tamanho: 20, altura: 28, largura: 112, peso: 700, cor: sobre),
    ),
    cardTheme: CardThemeData(
      color: cores.papel2,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(raioXs),
        side: BorderSide(color: cores.regra),
      ),
    ),
    dividerTheme: DividerThemeData(color: cores.regra, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: alvo,
        shape: forma,
        textStyle: texto.labelLarge,
        backgroundColor: corAgencia,
        foregroundColor: sobre,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: alvo,
        shape: forma,
        textStyle: texto.labelLarge,
        foregroundColor: tinta,
        side: BorderSide(color: tinta),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: alvo,
        shape: forma,
        textStyle: texto.labelLarge,
        foregroundColor: tinta,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(raioXs),
        borderSide: BorderSide(color: cores.tinta2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(raioXs),
        borderSide: BorderSide(color: cores.tinta2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(raioXs),
        borderSide: BorderSide(color: tinta, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(raioXs),
        borderSide: BorderSide(color: erro),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: espaco12, vertical: espaco12),
      labelStyle: texto.bodyMedium?.copyWith(color: cores.tinta2),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(raioSm))),
        side: WidgetStatePropertyAll(BorderSide(color: cores.tinta2)),
        minimumSize: const WidgetStatePropertyAll(alvo),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cores.papel2,
      indicatorColor: Color.alphaBlend(corAgencia.withValues(alpha: 0.24), cores.papel2),
      elevation: 0,
      height: 72,
      labelTextStyle: WidgetStatePropertyAll(texto.labelMedium),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: tinta,
      contentTextStyle: texto.bodyMedium?.copyWith(color: papel),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(raioXs)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: papel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(raioXs),
        side: BorderSide(color: tinta),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: papel,
      shape: const RoundedRectangleBorder(),
      showDragHandle: true,
    ),
  );
}
