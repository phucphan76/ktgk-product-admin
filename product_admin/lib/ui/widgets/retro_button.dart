import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../retro_theme.dart';
import 'bevel.dart';
import 'pixel_icon.dart';

/// Raised push button that sinks when pressed, with a dotted focus ring.
class RetroButton extends StatefulWidget {
  const RetroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDefault = false,
    this.selected = false,
    this.minWidth = 84,
    this.height,
    this.tooltip,
    this.bold = false,
    this.trailing,
  });

  final String label;
  final VoidCallback? onPressed;
  final List<String>? icon;
  final bool isDefault;

  /// Toggle buttons: draws the button as latched down.
  final bool selected;
  final double minWidth;
  final double? height;
  final String? tooltip;
  final bool bold;
  final Widget? trailing;

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _down = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  void _activate() {
    if (!_enabled) return;
    widget.onPressed!.call();
  }

  @override
  Widget build(BuildContext context) {
    final phone = Retro.isPhone(context);
    final height = widget.height ?? (phone ? 40.0 : 30.0);
    final sunk = _down || widget.selected;
    final textStyle = (widget.bold ? Retro.bodyBold : Retro.body).copyWith(
      color: _enabled ? Retro.text : Retro.disabledText,
      shadows: _enabled
          ? null
          : const [Shadow(color: Retro.light, offset: Offset(1, 1))],
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Opacity(
            opacity: _enabled ? 1 : 0.45,
            child: PixelIcon(widget.icon!, size: 16),
          ),
          if (widget.label.isNotEmpty) const SizedBox(width: 6),
        ],
        if (widget.label.isNotEmpty)
          Flexible(
            child: Text(
              widget.label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        if (widget.trailing != null) ...[
          const SizedBox(width: 4),
          widget.trailing!,
        ],
      ],
    );

    if (_focused) {
      content = CustomPaint(
        foregroundPainter: DottedRectPainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: content,
        ),
      );
    }

    Widget button = Bevel(
      style: sunk ? BevelStyle.pressed : BevelStyle.raised,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minWidth,
          minHeight: height - 4,
        ),
        child: Transform.translate(
          offset: sunk ? const Offset(1, 1) : Offset.zero,
          child: Center(widthFactor: 1, child: content),
        ),
      ),
    );

    if (widget.isDefault) {
      button = DecoratedBox(
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(BorderSide(color: Retro.shadow)),
        ),
        child: button,
      );
    }

    button = FocusableActionDetector(
      enabled: _enabled,
      mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
          _activate();
          return null;
        }),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: _enabled ? () => setState(() => _down = false) : null,
        onTapUp: _enabled
            ? (_) {
                setState(() => _down = false);
                _activate();
              }
            : null,
        child: button,
      ),
    );

    button = Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.label.isEmpty ? widget.tooltip : null,
      child: button,
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

/// Small square button used in title bars (minimize / maximize / close, edit, delete).
class CaptionButton extends StatefulWidget {
  const CaptionButton({
    super.key,
    required this.glyph,
    required this.onPressed,
    required this.tooltip,
    this.size = const Size(20, 18),
  });

  final CaptionGlyph glyph;
  final VoidCallback? onPressed;
  final String tooltip;
  final Size size;

  @override
  State<CaptionButton> createState() => _CaptionButtonState();
}

enum CaptionGlyph { minimize, maximize, restore, close, edit, help }

class _CaptionButtonState extends State<CaptionButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    // Visual size stays small; the hit area grows on touch screens.
    final hitPad = Retro.isPhone(context)
        ? const EdgeInsets.symmetric(horizontal: 3, vertical: 8)
        : const EdgeInsets.all(1);
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled ? (_) => setState(() => _down = true) : null,
            onTapCancel: () => setState(() => _down = false),
            onTapUp: enabled
                ? (_) {
                    setState(() => _down = false);
                    widget.onPressed!();
                  }
                : null,
            child: Padding(
              padding: hitPad,
              child: SizedBox.fromSize(
                size: widget.size,
                child: Bevel(
                  style: _down ? BevelStyle.pressed : BevelStyle.raised,
                  child: Transform.translate(
                    offset: _down ? const Offset(1, 1) : Offset.zero,
                    child: widget.glyph == CaptionGlyph.edit
                        ? const Center(child: PixelIcon(PixelIcons.pencil, size: 14))
                        : CustomPaint(
                            painter: _GlyphPainter(widget.glyph, enabled),
                            size: Size.infinite,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.enabled);
  final CaptionGlyph glyph;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = enabled ? Retro.shadow : Retro.dark
      ..isAntiAlias = false
      ..strokeWidth = 2;
    final cx = size.width / 2;
    final cy = size.height / 2;
    switch (glyph) {
      case CaptionGlyph.minimize:
        canvas.drawRect(Rect.fromLTWH(cx - 4, cy + 2, 7, 2), p);
      case CaptionGlyph.maximize:
        final r = Rect.fromLTWH(cx - 5, cy - 5, 9, 8);
        canvas.drawRect(Rect.fromLTWH(r.left, r.top, r.width, 2), p);
        canvas.drawRect(r, p..style = PaintingStyle.stroke..strokeWidth = 1);
      case CaptionGlyph.restore:
        p
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawRect(Rect.fromLTWH(cx - 2, cy - 5, 7, 6), p);
        canvas.drawRect(Rect.fromLTWH(cx - 5, cy - 2, 7, 6), p);
      case CaptionGlyph.close:
        p.strokeWidth = 2;
        canvas.drawLine(Offset(cx - 4, cy - 4), Offset(cx + 4, cy + 4), p);
        canvas.drawLine(Offset(cx + 4, cy - 4), Offset(cx - 4, cy + 4), p);
      case CaptionGlyph.help:
        final tp = TextPainter(
          text: const TextSpan(text: '?', style: Retro.pixelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
      case CaptionGlyph.edit:
        break;
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.enabled != enabled;
}

/// 1px dotted rectangle used for keyboard focus.
class DottedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Retro.shadow
      ..isAntiAlias = false;
    for (double x = 0; x < size.width; x += 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, 1), p);
      canvas.drawRect(Rect.fromLTWH(x, size.height - 1, 1, 1), p);
    }
    for (double y = 0; y < size.height; y += 2) {
      canvas.drawRect(Rect.fromLTWH(0, y, 1, 1), p);
      canvas.drawRect(Rect.fromLTWH(size.width - 1, y, 1, 1), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
