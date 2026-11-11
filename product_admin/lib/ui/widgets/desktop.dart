import 'package:flutter/material.dart';

import '../retro_theme.dart';
import 'bevel.dart';
import 'pixel_icon.dart';
import 'retro_button.dart';
import 'retro_fields.dart';

/// Teal desktop with a bottom taskbar. [child] fills the area above the taskbar.
class DesktopShell extends StatelessWidget {
  const DesktopShell({
    super.key,
    required this.child,
    this.onStart,
    this.windowTitle,
    this.windowActive = true,
    this.onWindowButton,
    this.userLabel,
  });

  final Widget child;

  /// Called with the start button's context so the menu can anchor to it.
  final void Function(BuildContext startButtonContext)? onStart;
  final String? windowTitle;
  final bool windowActive;
  final VoidCallback? onWindowButton;
  final String? userLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Retro.desktop,
      body: Column(
        children: [
          Expanded(child: SafeArea(bottom: false, child: child)),
          Taskbar(
            onStart: onStart,
            windowTitle: windowTitle,
            windowActive: windowActive,
            onWindowButton: onWindowButton,
            userLabel: userLabel,
          ),
        ],
      ),
    );
  }
}

class Taskbar extends StatelessWidget {
  const Taskbar({
    super.key,
    this.onStart,
    this.windowTitle,
    this.windowActive = true,
    this.onWindowButton,
    this.userLabel,
  });

  final void Function(BuildContext startButtonContext)? onStart;
  final String? windowTitle;
  final bool windowActive;
  final VoidCallback? onWindowButton;
  final String? userLabel;

  @override
  Widget build(BuildContext context) {
    final phone = Retro.isPhone(context);
    final showUser = userLabel != null && MediaQuery.sizeOf(context).width >= 700;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(2, 3, 2, 3 + bottomInset),
      decoration: const BoxDecoration(
        color: Retro.face,
        border: Border(top: BorderSide(color: Retro.light, width: 2)),
      ),
      child: SizedBox(
        height: phone ? 40 : 30,
        child: Row(
          children: [
            Builder(
              builder: (ctx) => RetroButton(
                label: 'Bắt đầu',
                icon: PixelIcons.computer,
                bold: true,
                minWidth: 0,
                height: phone ? 40 : 30,
                tooltip: 'Menu Bắt đầu',
                onPressed: onStart == null ? null : () => onStart!(ctx),
              ),
            ),
            const SizedBox(width: 4),
            Container(width: 2, decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Retro.dark), right: BorderSide(color: Retro.light)),
            )),
            const SizedBox(width: 4),
            if (windowTitle != null)
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: RetroButton(
                    label: windowTitle!,
                    icon: PixelIcons.folder,
                    selected: windowActive,
                    minWidth: 0,
                    height: phone ? 40 : 30,
                    onPressed: onWindowButton ?? () {},
                  ),
                ),
              ),
            const Spacer(),
            Bevel(
              style: BevelStyle.shallow,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showUser) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        userLabel!,
                        style: Retro.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  const RetroClock(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop shortcut: pixel icon with a caption. Single tap selects, double tap opens
/// (on touch screens a single tap opens).
class DesktopIcon extends StatefulWidget {
  const DesktopIcon({super.key, required this.icon, required this.label, required this.onOpen});
  final List<String> icon;
  final String label;
  final VoidCallback onOpen;

  @override
  State<DesktopIcon> createState() => _DesktopIconState();
}

class _DesktopIconState extends State<DesktopIcon> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _selected = !_selected),
          onDoubleTap: () {
            setState(() => _selected = false);
            widget.onOpen();
          },
          child: SizedBox(
            width: 84,
            child: Column(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _selected ? const Color(0x880A1F7A) : Colors.transparent,
                    BlendMode.srcATop,
                  ),
                  child: PixelIcon(widget.icon, size: 36),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  color: _selected ? Retro.selection : Colors.transparent,
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: Retro.label.copyWith(
                      color: Colors.white,
                      shadows: _selected
                          ? null
                          : const [Shadow(color: Colors.black, offset: Offset(1, 1))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chrome Y2K logo text.
class ChromeText extends StatelessWidget {
  const ChromeText(this.text, {super.key, this.size = 48});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = Retro.pixelStyle.copyWith(fontSize: size, letterSpacing: 2);
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = const Color(0xFF1B2440),
          ),
        ),
        ShaderMask(
          shaderCallback: (r) => Retro.chrome.createShader(r),
          blendMode: BlendMode.srcIn,
          child: Text(text, style: style.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
