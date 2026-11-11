import 'package:flutter/material.dart';

import '../retro_theme.dart';

enum BevelStyle {
  /// Buttons, panels: light top-left, dark bottom-right.
  raised,

  /// Window frame: like raised but softer outer edge.
  window,

  /// Text fields, image wells: dark top-left, light bottom-right.
  sunken,

  /// Status bar panels: single 1px sunken line.
  shallow,

  /// Pressed button.
  pressed,
}

/// Two-tone beveled box: the core building block of the retro look.
class Bevel extends StatelessWidget {
  const Bevel({
    super.key,
    required this.child,
    this.style = BevelStyle.raised,
    this.color,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final BevelStyle style;
  final Color? color;
  final EdgeInsetsGeometry padding;

  static Border _border(Color tl, Color br) => Border(
        top: BorderSide(color: tl),
        left: BorderSide(color: tl),
        bottom: BorderSide(color: br),
        right: BorderSide(color: br),
      );

  @override
  Widget build(BuildContext context) {
    final (Color, Color, Color?, Color?) c = switch (style) {
      BevelStyle.raised => (Retro.light, Retro.shadow, Retro.midLight, Retro.dark),
      BevelStyle.window => (Retro.midLight, Retro.shadow, Retro.light, Retro.dark),
      BevelStyle.sunken => (Retro.dark, Retro.light, Retro.shadow, Retro.midLight),
      BevelStyle.shallow => (Retro.dark, Retro.light, null, null),
      BevelStyle.pressed => (Retro.shadow, Retro.light, Retro.dark, Retro.midLight),
    };
    final bg = color ?? Retro.face;
    Widget inner = Container(
      color: bg,
      padding: padding,
      child: child,
    );
    if (c.$3 != null) {
      inner = Container(
        decoration: BoxDecoration(color: bg, border: _border(c.$3!, c.$4!)),
        child: inner,
      );
    }
    return Container(
      decoration: BoxDecoration(color: bg, border: _border(c.$1, c.$2)),
      child: inner,
    );
  }
}

/// Etched horizontal separator line.
class EtchedDivider extends StatelessWidget {
  const EtchedDivider({super.key, this.margin = const EdgeInsets.symmetric(vertical: 6)});
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: 2,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Retro.dark),
          bottom: BorderSide(color: Retro.light),
        ),
      ),
    );
  }
}
