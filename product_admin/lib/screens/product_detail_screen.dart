import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../ui/widgets/retro.dart';
import '../utils/format.dart';
import '../widgets/product_card.dart';

/// "Properties" window showing all product information (live-updating).
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.initial,
    required this.onEdit,
    required this.onDelete,
    this.maximized = false,
  });

  final String productId;
  final Product initial;
  final Future<void> Function(Product p) onEdit;
  final Future<bool> Function(Product p) onDelete;
  final bool maximized;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final Stream<Product?> _stream = ProductService.instance.watch(widget.productId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Product?>(
      stream: _stream,
      initialData: widget.initial,
      builder: (context, snap) {
        final p = snap.data ?? widget.initial;
        final phone = Retro.isPhone(context);

        final image = Stack(
          fit: StackFit.expand,
          children: [
            Bevel(
              style: BevelStyle.sunken,
              color: Retro.field,
              child: ProductImage(url: p.image, fit: BoxFit.contain),
            ),
            if (!p.inStock) const Center(child: SoldOutStamp(size: 34)),
          ],
        );

        final panel = Bevel(
          style: BevelStyle.raised,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const PixelIcon(PixelIcons.document, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(p.name, style: Retro.bodyBold.copyWith(fontSize: 16)),
                  ),
                ],
              ),
              const EtchedDivider(margin: EdgeInsets.symmetric(vertical: 10)),
              SizedBox(height: phone ? 240 : 260, child: image),
              const EtchedDivider(margin: EdgeInsets.symmetric(vertical: 10)),
              _row('Tên sản phẩm:', p.name),
              _row('Giá:', formatVnd(p.price), bold: true),
              _row('Số lượng:', formatInt(p.soluong)),
              _row(
                'Tình trạng:',
                p.inStock ? 'Còn hàng' : 'Hết hàng',
                color: p.inStock ? const Color(0xFF1F7A3A) : Retro.accent,
              ),
              _row('Mã tài liệu:', p.id ?? '', small: true),
            ],
          ),
        );

        // Classic single tab above the property sheet.
        final tab = Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: const BoxDecoration(
              color: Retro.face,
              border: Border(
                top: BorderSide(color: Retro.light),
                left: BorderSide(color: Retro.light),
                right: BorderSide(color: Retro.shadow),
              ),
            ),
            child: Text('Chung', style: Retro.body),
          ),
        );

        final buttons = Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            RetroButton(
              label: 'Sửa',
              icon: PixelIcons.pencil,
              onPressed: () => widget.onEdit(p),
            ),
            RetroButton(
              label: 'Xóa',
              icon: PixelIcons.trash,
              onPressed: () async {
                final deleted = await widget.onDelete(p);
                if (deleted && context.mounted) Navigator.of(context).pop();
              },
            ),
            RetroButton(
              label: 'Đóng',
              isDefault: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );

        return RetroWindow(
          title: 'Thuộc tính sản phẩm',
          icon: PixelIcons.info,
          expand: widget.maximized,
          onClose: () => Navigator.of(context).pop(),
          child: Column(
            mainAxisSize: widget.maximized ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                fit: widget.maximized ? FlexFit.tight : FlexFit.loose,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [tab, panel],
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 10), child: buttons),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String k, String v, {bool bold = false, bool small = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(k, style: Retro.body.copyWith(color: Retro.dark))),
          Expanded(
            child: SelectableText(
              v,
              style: (bold ? Retro.bodyBold : Retro.body).copyWith(
                fontSize: small ? 11 : 14,
                color: color ?? Retro.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
