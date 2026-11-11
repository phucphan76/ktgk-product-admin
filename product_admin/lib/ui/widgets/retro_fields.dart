import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../retro_theme.dart';
import 'bevel.dart';

/// Sunken white text field with a label above and pixel error text below.
class RetroTextFormField extends FormField<String> {
  RetroTextFormField({
    super.key,
    required TextEditingController controller,
    String? label,
    String? hint,
    super.validator,
    bool obscure = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
    Iterable<String>? autofillHints,
    bool autofocus = false,
    bool enabled = true,
    Widget? suffix,
    String? suffixText,
  }) : super(
          initialValue: controller.text,
          builder: (state) {
            final phone = Retro.isPhone(state.context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null) ...[
                  Text(label, style: Retro.label),
                  const SizedBox(height: 3),
                ],
                Bevel(
                  style: BevelStyle.sunken,
                  color: enabled ? Retro.field : Retro.face,
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: phone ? 9 : 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          enabled: enabled,
                          obscureText: obscure,
                          keyboardType: keyboardType,
                          inputFormatters: inputFormatters,
                          textInputAction: textInputAction,
                          autofillHints: autofillHints,
                          autofocus: autofocus,
                          onSubmitted: onSubmitted,
                          onChanged: (v) {
                            state.didChange(v);
                            onChanged?.call(v);
                          },
                          style: Retro.body.copyWith(fontSize: 14),
                          cursorColor: Retro.text,
                          cursorWidth: 7,
                          cursorHeight: 16,
                          cursorRadius: Radius.zero,
                          decoration: InputDecoration.collapsed(
                            hintText: hint,
                            hintStyle: Retro.body.copyWith(
                              fontSize: 14,
                              color: Retro.disabledText,
                            ),
                          ),
                        ),
                      ),
                      if (suffixText != null)
                        Text(suffixText, style: Retro.body.copyWith(color: Retro.dark)),
                      ?suffix,
                    ],
                  ),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 2),
                  Text(
                    '▲ ${state.errorText}',
                    style: Retro.pixelStyle.copyWith(fontSize: 18, color: Retro.error),
                  ),
                ],
              ],
            );
          },
        );
}

/// Segmented "blocks" progress bar. `value == null` shows an indeterminate sweep.
class RetroProgressBar extends StatefulWidget {
  const RetroProgressBar({super.key, this.value, this.height = 22});
  final double? value;
  final double height;

  @override
  State<RetroProgressBar> createState() => _RetroProgressBarState();
}

class _RetroProgressBarState extends State<RetroProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.value == null) _c.repeat();
  }

  @override
  void didUpdateWidget(RetroProgressBar old) {
    super.didUpdateWidget(old);
    if (widget.value == null && !_c.isAnimating) _c.repeat();
    if (widget.value != null && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.value;
    return Semantics(
      label: 'Tiến trình',
      value: v == null ? 'Đang xử lý' : '${(v * 100).round()}%',
      child: SizedBox(
        height: widget.height,
        child: Bevel(
          style: BevelStyle.sunken,
          color: Retro.field,
          padding: const EdgeInsets.all(2),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _BlocksPainter(v, _c.value),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

class _BlocksPainter extends CustomPainter {
  _BlocksPainter(this.value, this.t);
  final double? value;
  final double t;

  static const block = 9.0;
  static const gap = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Retro.segment
      ..isAntiAlias = false;
    final total = (size.width / (block + gap)).floor();
    if (total <= 0) return;
    if (value != null) {
      final n = (total * value!.clamp(0, 1)).ceil();
      for (var i = 0; i < n; i++) {
        canvas.drawRect(Rect.fromLTWH(i * (block + gap), 0, block, size.height), p);
      }
    } else {
      const run = 5;
      final start = ((total + run) * t).floor() - run;
      for (var i = start; i < start + run; i++) {
        if (i < 0 || i >= total) continue;
        canvas.drawRect(Rect.fromLTWH(i * (block + gap), 0, block, size.height), p);
      }
    }
  }

  @override
  bool shouldRepaint(_BlocksPainter old) => old.value != value || old.t != t;
}

/// Live HH:mm clock for the taskbar tray.
class RetroClock extends StatefulWidget {
  const RetroClock({super.key});

  @override
  State<RetroClock> createState() => _RetroClockState();
}

class _RetroClockState extends State<RetroClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final n = DateTime.now();
      if (n.minute != _now.minute) setState(() => _now = n);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int v) => v.toString().padLeft(2, '0');
    return Text('${two(_now.hour)}:${two(_now.minute)}', style: Retro.label);
  }
}
