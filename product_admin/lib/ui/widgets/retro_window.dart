import 'package:flutter/material.dart';

import '../retro_theme.dart';
import 'bevel.dart';
import 'pixel_icon.dart';
import 'retro_button.dart';

/// A beveled window with a gradient title bar and optional menu/tool/status bars.
class RetroWindow extends StatelessWidget {
  const RetroWindow({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.menuBar,
    this.toolbar,
    this.statusBar,
    this.onClose,
    this.onMinimize,
    this.onMaximize,
    this.maximized = false,
    this.active = true,
    this.expand = false,
    this.titleActions = const [],
    this.compact = false,
  });

  final String title;
  final Widget child;
  final List<String>? icon;
  final Widget? menuBar;
  final Widget? toolbar;
  final Widget? statusBar;
  final VoidCallback? onClose;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final bool maximized;
  final bool active;

  /// When true the body fills the available height (use inside bounded parents).
  final bool expand;

  /// Extra caption buttons (e.g. edit/delete on product cards).
  final List<Widget> titleActions;

  /// Smaller title bar for cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleBar = Container(
      height: compact ? 24 : 28,
      padding: const EdgeInsets.only(left: 4, right: 2),
      decoration: BoxDecoration(
        gradient: active ? Retro.titleGradient : Retro.inactiveGradient,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            PixelIcon(icon!, size: compact ? 14 : 16),
            const SizedBox(width: 5),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Retro.titleStyle.copyWith(fontSize: compact ? 18 : 20),
            ),
          ),
          ...titleActions,
          if (onMinimize != null)
            CaptionButton(
              glyph: CaptionGlyph.minimize,
              onPressed: onMinimize,
              tooltip: 'Thu nhỏ',
            ),
          if (onMaximize != null)
            CaptionButton(
              glyph: maximized ? CaptionGlyph.restore : CaptionGlyph.maximize,
              onPressed: onMaximize,
              tooltip: maximized ? 'Khôi phục' : 'Phóng to',
            ),
          if (onClose != null) ...[
            const SizedBox(width: 2),
            CaptionButton(
              glyph: CaptionGlyph.close,
              onPressed: onClose,
              tooltip: 'Đóng',
            ),
          ],
        ],
      ),
    );

    final body = Padding(
      padding: const EdgeInsets.all(2),
      child: child,
    );

    return Semantics(
      container: true,
      label: title,
      child: Bevel(
        style: BevelStyle.window,
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titleBar,
            ?menuBar,
            if (toolbar != null) ...[
              if (menuBar != null) const EtchedDivider(margin: EdgeInsets.zero),
              toolbar!,
            ],
            if (expand) Expanded(child: body) else Flexible(child: body),
            ?statusBar,
          ],
        ),
      ),
    );
  }
}

/// Status bar made of shallow sunken panels.
class RetroStatusBar extends StatelessWidget {
  const RetroStatusBar({super.key, required this.panels});
  final List<Widget> panels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          for (var i = 0; i < panels.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Flexible(
              fit: i == panels.length - 1 ? FlexFit.tight : FlexFit.loose,
              child: Bevel(
                style: BevelStyle.shallow,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: DefaultTextStyle(
                  style: Retro.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: panels[i],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Etched frame with a caption, used to group form fields.
class GroupBox extends StatelessWidget {
  const GroupBox({super.key, required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 9),
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
          decoration: BoxDecoration(
            border: Border.all(color: Retro.dark),
            boxShadow: const [
              BoxShadow(color: Retro.light, offset: Offset(1, 1)),
            ],
            color: Retro.face,
          ),
          child: child,
        ),
        Positioned(
          left: 8,
          top: 0,
          child: Container(
            color: Retro.face,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(label, style: Retro.bodyBold.copyWith(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
