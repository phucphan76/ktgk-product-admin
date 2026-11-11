import 'dart:async';

import 'package:flutter/material.dart';

import '../retro_theme.dart';
import 'bevel.dart';
import 'pixel_icon.dart';
import 'retro_button.dart';
import 'retro_window.dart';

/// Remembers the last pointer-down position so windows can "zoom" open from it.
class PointerTracker extends StatelessWidget {
  const PointerTracker({super.key, required this.child});
  final Widget child;

  static Offset? last;

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (e) => last = e.position,
        child: child,
      );
}

Widget _zoomTransition(BuildContext context, Animation<double> a, Widget child) {
  final size = MediaQuery.sizeOf(context);
  final origin = PointerTracker.last;
  final alignment = origin == null || size.isEmpty
      ? Alignment.center
      : Alignment(
          (origin.dx / size.width) * 2 - 1,
          (origin.dy / size.height) * 2 - 1,
        );
  final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      alignment: alignment,
      scale: Tween(begin: 0.85, end: 1.0).animate(curved),
      child: child,
    ),
  );
}

/// Opens a window as a floating route (centered on desktop, maximized on phones).
class RetroWindowRoute<T> extends PageRouteBuilder<T> {
  RetroWindowRoute({
    required Widget Function(BuildContext context, bool maximized) builder,
    double maxWidth = 640,
  }) : super(
          opaque: false,
          barrierColor: const Color(0x22000000),
          barrierDismissible: false,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 100),
          pageBuilder: (context, _, _) {
            final phone = Retro.isPhone(context);
            if (phone) {
              return Material(
                color: Retro.face,
                child: SafeArea(child: builder(context, true)),
              );
            }
            final h = MediaQuery.sizeOf(context).height;
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: h * 0.9),
                    child: Material(
                      type: MaterialType.transparency,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Color(0x55000000), offset: Offset(4, 4)),
                          ],
                        ),
                        child: builder(context, false),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          transitionsBuilder: (context, a, _, child) =>
              _zoomTransition(context, a, child),
        );
}

enum DialogKind { info, warning, error, question }

class DialogAction<T> {
  const DialogAction(this.label, this.value, {this.isDefault = false});
  final String label;
  final T? value;
  final bool isDefault;
}

/// Classic message box with an icon, a message and a row of buttons.
Future<T?> showRetroDialog<T>(
  BuildContext context, {
  required String title,
  required String message,
  DialogKind kind = DialogKind.info,
  List<DialogAction<T>>? actions,
}) {
  final icon = switch (kind) {
    DialogKind.info => PixelIcons.info,
    DialogKind.warning => PixelIcons.warning,
    DialogKind.error => PixelIcons.error,
    DialogKind.question => PixelIcons.question,
  };
  final acts = actions ?? [DialogAction<T>('OK', null, isDefault: true)];
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0x22000000),
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: (context, a, _, child) => _zoomTransition(context, a, child),
    pageBuilder: (context, _, _) => Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, minWidth: 280),
          child: Material(
            type: MaterialType.transparency,
            child: RetroWindow(
              title: title,
              onClose: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelIcon(icon, size: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(message, style: Retro.body.copyWith(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final a in acts)
                          RetroButton(
                            label: a.label,
                            isDefault: a.isDefault,
                            onPressed: () => Navigator.of(context).pop(a.value),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Yes/No confirmation helper.
Future<bool> confirmRetro(
  BuildContext context, {
  required String title,
  required String message,
  DialogKind kind = DialogKind.question,
}) async {
  final r = await showRetroDialog<bool>(
    context,
    title: title,
    message: message,
    kind: kind,
    actions: const [
      DialogAction('Có', true, isDefault: true),
      DialogAction('Không', false),
    ],
  );
  return r ?? false;
}

class RetroMenuItem<T> {
  const RetroMenuItem(this.label, this.value, {this.icon, this.checked = false, this.enabled = true})
      : separator = false;
  const RetroMenuItem.separator()
      : label = '',
        value = null,
        icon = null,
        checked = false,
        enabled = false,
        separator = true;

  final String label;
  final T? value;
  final List<String>? icon;
  final bool checked;
  final bool enabled;
  final bool separator;
}

/// Shows a beveled drop-down / pop-up menu anchored to [anchorContext].
Future<T?> showRetroMenu<T>(
  BuildContext anchorContext, {
  required List<RetroMenuItem<T>> items,
  bool above = false,
  double minWidth = 180,
}) {
  final box = anchorContext.findRenderObject() as RenderBox;
  final topLeft = box.localToGlobal(Offset.zero);
  final anchor = topLeft & box.size;
  return Navigator.of(anchorContext).push<T>(
    _MenuRoute<T>(anchor: anchor, items: items, above: above, minWidth: minWidth),
  );
}

class _MenuRoute<T> extends PopupRoute<T> {
  _MenuRoute({required this.anchor, required this.items, required this.above, required this.minWidth});

  final Rect anchor;
  final List<RetroMenuItem<T>> items;
  final bool above;
  final double minWidth;

  @override
  Color? get barrierColor => null;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Đóng menu';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 90);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final screen = MediaQuery.sizeOf(context);
    final left = anchor.left.clamp(0.0, (screen.width - minWidth).clamp(0.0, double.infinity));
    final menu = Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: 300),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Color(0x55000000), offset: Offset(2, 2))],
          ),
          child: Bevel(
            style: BevelStyle.window,
            padding: const EdgeInsets.all(2),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in items)
                    item.separator
                        ? const EtchedDivider(margin: EdgeInsets.symmetric(vertical: 3, horizontal: 2))
                        : _MenuEntry<T>(item: item),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: above ? null : anchor.bottom,
            bottom: above ? screen.height - anchor.top : null,
            child: menu,
          ),
        ],
      ),
    );
  }
}

class _MenuEntry<T> extends StatefulWidget {
  const _MenuEntry({required this.item});
  final RetroMenuItem<T> item;

  @override
  State<_MenuEntry<T>> createState() => _MenuEntryState<T>();
}

class _MenuEntryState<T> extends State<_MenuEntry<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hl = _hover && item.enabled;
    final color = !item.enabled
        ? Retro.disabledText
        : hl
            ? Colors.white
            : Retro.text;
    return Semantics(
      button: true,
      enabled: item.enabled,
      checked: item.checked ? true : null,
      child: MouseRegion(
        cursor: item.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.enabled ? () => Navigator.of(context).pop(item.value) : null,
          child: Container(
            color: hl ? Retro.selection : Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: 6,
              vertical: Retro.isPhone(context) ? 11 : 5,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: item.icon != null
                      ? PixelIcon(item.icon!, size: 16)
                      : item.checked
                          ? Text('•', textAlign: TextAlign.center, style: Retro.bodyBold.copyWith(color: color, fontSize: 16))
                          : null,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(item.label, style: Retro.body.copyWith(color: color))),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tray "balloon" notification shown above the taskbar's bottom-right corner.
void showBalloon(BuildContext context, String message, {DialogKind kind = DialogKind.info}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  final icon = kind == DialogKind.error ? PixelIcons.error : PixelIcons.info;
  entry = OverlayEntry(
    builder: (context) => _Balloon(
      message: message,
      icon: icon,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _Balloon extends StatefulWidget {
  const _Balloon({required this.message, required this.icon, required this.onDone});
  final String message;
  final List<String> icon;
  final VoidCallback onDone;

  @override
  State<_Balloon> createState() => _BalloonState();
}

class _BalloonState extends State<_Balloon> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 3200), _close);
  }

  Future<void> _close() async {
    _timer?.cancel();
    if (!mounted) return;
    await _c.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 46;
    return Positioned(
      right: 10,
      bottom: bottom,
      child: FadeTransition(
        opacity: _c,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(_c),
          child: Semantics(
            liveRegion: true,
            child: GestureDetector(
              onTap: _close,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFE1),
                    border: Border.all(color: Retro.shadow),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Color(0x55000000), offset: Offset(2, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PixelIcon(widget.icon, size: 20),
                      const SizedBox(width: 8),
                      Flexible(child: Text(widget.message, style: Retro.body)),
                    ],
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
