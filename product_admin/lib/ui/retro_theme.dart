import 'package:flutter/material.dart';

/// Design tokens for the "KTGK OS 2000" retro desktop look.
class Retro {
  Retro._();

  // Colors
  static const desktop = Color(0xFF0F7F7F);
  static const face = Color(0xFFC3C3C3);
  static const light = Color(0xFFFFFFFF);
  static const midLight = Color(0xFFDFDFDF);
  static const dark = Color(0xFF7B7B7B);
  static const shadow = Color(0xFF000000);
  static const field = Color(0xFFFFFFFF);
  static const text = Color(0xFF000000);
  static const disabledText = Color(0xFF7B7B7B);
  static const titleA = Color(0xFF0A1F7A);
  static const titleB = Color(0xFF2A8BD6);
  static const inactiveA = Color(0xFF7B7B7B);
  static const inactiveB = Color(0xFFB5B5B5);
  static const selection = Color(0xFF0A1F7A);
  static const accent = Color(0xFFE0007A);
  static const error = Color(0xFFB00020);
  static const segment = Color(0xFF0A1F7A);

  // Fonts
  static const pixelFont = 'VT323';
  static const bodyFont = 'BeVietnamPro';

  static const titleStyle = TextStyle(
    fontFamily: pixelFont,
    fontSize: 20,
    height: 1.0,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const pixelStyle = TextStyle(
    fontFamily: pixelFont,
    fontSize: 20,
    height: 1.0,
    color: text,
  );

  static const body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    height: 1.35,
    color: text,
  );

  static const bodyBold = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: text,
  );

  static const label = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    height: 1.3,
    color: text,
  );

  static const titleGradient = LinearGradient(colors: [titleA, titleB]);
  static const inactiveGradient = LinearGradient(colors: [inactiveA, inactiveB]);

  /// Chrome / metallic gradient used for the Y2K logo text.
  static const chrome = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFB8C6D9),
      Color(0xFF5A6B85),
      Color(0xFFE9F1FF),
      Color(0xFF9FB3CF),
    ],
    stops: [0.0, 0.42, 0.5, 0.62, 1.0],
  );

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: bodyFont,
      colorScheme: ColorScheme.fromSeed(
        seedColor: titleA,
        surface: face,
        primary: titleA,
        error: error,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: desktop,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: text,
        selectionColor: Color(0x660A1F7A),
        selectionHandleColor: titleA,
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFE1),
          border: Border.fromBorderSide(BorderSide(color: shadow)),
        ),
        textStyle: TextStyle(fontFamily: bodyFont, fontSize: 12, color: text),
        waitDuration: Duration(milliseconds: 500),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(10),
        radius: Radius.zero,
        thumbColor: WidgetStateProperty.all(dark),
        trackColor: WidgetStateProperty.all(midLight),
        trackVisibility: WidgetStateProperty.all(true),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: bodyFont,
        bodyColor: text,
        displayColor: text,
      ),
    );
  }
}
