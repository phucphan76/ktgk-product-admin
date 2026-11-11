import 'package:flutter/material.dart';

import '../models/product.dart';
import '../ui/widgets/retro.dart';
import '../utils/format.dart';

/// A product shown as a mini-window: name in the title bar, edit/delete caption buttons.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Semantics(
      button: true,
      label: '${p.name}, giá ${formatVnd(p.price)}, số lượng ${p.soluong}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onOpen,
          child: RetroWindow(
            title: p.name,
            icon: PixelIcons.document,
            compact: true,
            expand: true,
            titleActions: [
              CaptionButton(glyph: CaptionGlyph.edit, tooltip: 'Sửa', onPressed: onEdit),
              const SizedBox(width: 2),
              CaptionButton(glyph: CaptionGlyph.close, tooltip: 'Xóa', onPressed: onDelete),
            ],
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Bevel(
                          style: BevelStyle.sunken,
                          color: Retro.field,
                          child: ProductImage(url: p.image),
                        ),
                        if (!p.inStock) const Center(child: SoldOutStamp()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _row('Giá:', formatVnd(p.price), bold: true),
                  _row('SL:', formatInt(p.soluong),
                      color: p.inStock ? Retro.text : Retro.accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v, {bool bold = false, Color color = Retro.text}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: Row(
          children: [
            SizedBox(width: 36, child: Text(k, style: Retro.label.copyWith(color: Retro.dark))),
            Expanded(
              child: Text(
                v,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (bold ? Retro.bodyBold : Retro.body).copyWith(color: color),
              ),
            ),
          ],
        ),
      );
}

/// Network image with pixel hourglass while loading and a picture icon on error.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover});
  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Center(child: PixelIcon(PixelIcons.picture, size: 40));
    }
    return Image.network(
      url,
      fit: fit,
      // Hourglass until the first frame arrives, then a short fade-in.
      frameBuilder: (context, child, frame, wasSync) {
        if (wasSync) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (frame == null)
              const Center(child: PixelIcon(PixelIcons.hourglass, size: 32)),
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 150),
              child: child,
            ),
          ],
        );
      },
      errorBuilder: (_, _, _) => const Center(
        child: PixelIcon(PixelIcons.picture, size: 40, semanticLabel: 'Không tải được ảnh'),
      ),
    );
  }
}

class SoldOutStamp extends StatelessWidget {
  const SoldOutStamp({super.key, this.size = 26});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xDDFFFFFF),
          border: Border.all(color: Retro.accent, width: 2),
        ),
        child: Text(
          'HẾT HÀNG',
          style: Retro.pixelStyle.copyWith(color: Retro.accent, fontSize: size, letterSpacing: 2),
        ),
      ),
    );
  }
}
