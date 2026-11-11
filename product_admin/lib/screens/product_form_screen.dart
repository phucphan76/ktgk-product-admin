
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import '../services/cloudinary_service.dart';
import '../services/product_service.dart';
import '../ui/widgets/retro.dart';
import '../utils/format.dart';
import '../widgets/product_card.dart';

/// Add / edit form. Pops with the saved product name on success.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product, this.maximized = false});
  final Product? product;
  final bool maximized;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _price = TextEditingController(
    text: widget.product == null ? '' : widget.product!.price.toString(),
  );
  late final _qty = TextEditingController(
    text: widget.product == null ? '' : widget.product!.soluong.toString(),
  );

  Uint8List? _bytes;
  String _fileName = 'image.jpg';
  String? _imageError;
  double? _progress;
  bool _saving = false;

  bool get _isEdit => widget.product != null;
  String get _existingImage => widget.product?.image ?? '';

  /// True when any field differs from what the form opened with.
  bool get _dirty =>
      _bytes != null ||
      _name.text.trim() != (widget.product?.name ?? '') ||
      _price.text != (widget.product?.price.toString() ?? '') ||
      _qty.text != (widget.product?.soluong.toString() ?? '');

  @override
  void initState() {
    super.initState();
    // Live "= 150.000 ₫" preview under the price field.
    _price.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  Future<void> _pick(BuildContext anchor) async {
    ImageSource source = ImageSource.gallery;
    if (!kIsWeb) {
      final r = await showRetroMenu<ImageSource>(
        anchor,
        items: const [
          RetroMenuItem('Thư viện ảnh', ImageSource.gallery, icon: PixelIcons.picture),
          RetroMenuItem('Máy ảnh', ImageSource.camera, icon: PixelIcons.computer),
        ],
      );
      if (r == null) return;
      source = r;
    }
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _bytes = bytes;
        _fileName = file.name.isEmpty ? 'image.jpg' : file.name;
        _imageError = null;
      });
    } catch (e) {
      if (!mounted) return;
      await showRetroDialog<void>(
        context,
        title: 'Lỗi chọn ảnh',
        message: 'Không mở được ảnh: $e',
        kind: DialogKind.error,
      );
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final formOk = _formKey.currentState!.validate();
    final hasImage = _bytes != null || _existingImage.isNotEmpty;
    setState(() => _imageError = hasImage ? null : 'Vui lòng chọn hình ảnh');
    if (!formOk || !hasImage) return;

    setState(() => _saving = true);
    try {
      var url = _existingImage;
      if (_bytes != null) {
        setState(() => _progress = 0);
        url = await CloudinaryService.instance.upload(
          _bytes!,
          filename: _fileName,
          onProgress: (v) {
            if (mounted) setState(() => _progress = v);
          },
        );
      }
      setState(() => _progress = null);
      final p = Product(
        id: widget.product?.id,
        name: _name.text.trim(),
        price: int.parse(_price.text),
        soluong: int.parse(_qty.text),
        image: url,
      );
      if (_isEdit) {
        await ProductService.instance.update(p);
      } else {
        await ProductService.instance.add(p);
      }
      if (mounted) Navigator.of(context).pop(p.name);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _progress = null;
      });
      await showRetroDialog<void>(
        context,
        title: 'Lưu thất bại',
        message: e.toString().replaceFirst('Bad state: ', ''),
        kind: DialogKind.error,
      );
    }
  }

  Future<void> _cancel() async {
    if (_saving) return;
    if (_dirty) {
      final leave = await confirmRetro(
        context,
        title: 'Hủy thay đổi',
        message: 'Bạn có muốn đóng cửa sổ và bỏ các thay đổi chưa lưu?',
        kind: DialogKind.warning,
      );
      if (!leave) return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final phone = Retro.isPhone(context);
    final title = _isEdit ? 'Sửa: ${widget.product!.name}' : 'Thêm sản phẩm';

    final imageBox = GroupBox(
      label: 'Hình ảnh',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Bevel(
              style: BevelStyle.sunken,
              color: Retro.field,
              child: _bytes != null
                  ? Image.memory(_bytes!, fit: BoxFit.cover)
                  : _existingImage.isNotEmpty
                      ? ProductImage(url: _existingImage)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const PixelIcon(PixelIcons.picture, size: 40),
                            const SizedBox(height: 6),
                            Text('Chưa có ảnh', style: Retro.label.copyWith(color: Retro.dark)),
                          ],
                        ),
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (ctx) => RetroButton(
              label: _bytes != null || _existingImage.isNotEmpty ? 'Đổi ảnh…' : 'Duyệt…',
              icon: PixelIcons.folder,
              onPressed: _saving ? null : () => _pick(ctx),
            ),
          ),
          if (_imageError != null) ...[
            const SizedBox(height: 4),
            Text(
              '▲ $_imageError',
              style: Retro.pixelStyle.copyWith(fontSize: 18, color: Retro.error),
            ),
          ],
        ],
      ),
    );

    final digits = [FilteringTextInputFormatter.digitsOnly];
    final priceValue = int.tryParse(_price.text);

    final infoBox = GroupBox(
      label: 'Thông tin sản phẩm',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RetroTextFormField(
            controller: _name,
            label: 'Tên sản phẩm (name):',
            hint: 'VD: Áo thun Y2K',
            enabled: !_saving,
            textInputAction: TextInputAction.next,
            autofocus: !phone && !_isEdit,
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'Vui lòng nhập tên sản phẩm';
              if (s.length > 100) return 'Tên tối đa 100 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 10),
          RetroTextFormField(
            controller: _price,
            label: 'Giá (price):',
            hint: 'VD: 150000',
            suffixText: '₫',
            enabled: !_saving,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if ((v ?? '').isEmpty) return 'Vui lòng nhập giá';
              final n = int.tryParse(v!);
              if (n == null) return 'Giá phải là số';
              if (n < 0) return 'Giá không được âm';
              if (n > 1000000000) return 'Giá quá lớn';
              return null;
            },
          ),
          if (priceValue != null && priceValue > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('= ${formatVnd(priceValue)}', style: Retro.label.copyWith(color: Retro.dark)),
            ),
          const SizedBox(height: 10),
          RetroTextFormField(
            controller: _qty,
            label: 'Số lượng (soluong):',
            hint: 'VD: 10',
            enabled: !_saving,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            validator: (v) {
              if ((v ?? '').isEmpty) return 'Vui lòng nhập số lượng';
              final n = int.tryParse(v!);
              if (n == null) return 'Số lượng phải là số nguyên';
              if (n < 0) return 'Số lượng không được âm';
              if (n > 1000000) return 'Số lượng quá lớn';
              return null;
            },
          ),
        ],
      ),
    );

    final status = _saving
        ? Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _progress != null
                      ? 'Đang tải ảnh lên… ${(_progress! * 100).round()}%'
                      : 'Đang lưu vào cơ sở dữ liệu…',
                  style: Retro.label,
                ),
                const SizedBox(height: 4),
                RetroProgressBar(value: _progress, height: 18),
              ],
            ),
          )
        : const SizedBox.shrink();

    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          flex: phone ? 1 : 0,
          child: RetroButton(
            label: 'Lưu',
            icon: PixelIcons.disk,
            isDefault: true,
            onPressed: _saving ? null : _save,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: phone ? 1 : 0,
          child: RetroButton(label: 'Hủy', onPressed: _saving ? null : _cancel),
        ),
      ],
    );

    final form = Form(
      key: _formKey,
      child: phone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                infoBox,
                const SizedBox(height: 8),
                Center(child: SizedBox(width: 240, child: imageBox)),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 230, child: imageBox),
                const SizedBox(width: 12),
                Expanded(child: infoBox),
              ],
            ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: RetroWindow(
        title: title,
        icon: _isEdit ? PixelIcons.pencil : PixelIcons.document,
        expand: widget.maximized,
        onClose: _saving ? null : _cancel,
        child: Column(
          mainAxisSize: widget.maximized ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              fit: widget.maximized ? FlexFit.tight : FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [form, status],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: buttons,
            ),
          ],
        ),
      ),
    );
  }
}
