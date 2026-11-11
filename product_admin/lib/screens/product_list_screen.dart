import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/file_saver.dart';
import '../services/product_service.dart';
import '../ui/widgets/retro.dart';
import '../utils/format.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

enum SortMode { name, priceAsc, priceDesc, qtyDesc }

enum StockFilter { all, inStock, outOfStock }

extension on SortMode {
  String get label => switch (this) {
        SortMode.name => 'Tên A → Z',
        SortMode.priceAsc => 'Giá tăng dần',
        SortMode.priceDesc => 'Giá giảm dần',
        SortMode.qtyDesc => 'Số lượng nhiều nhất',
      };
}

extension on StockFilter {
  String get label => switch (this) {
        StockFilter.all => 'Tất cả',
        StockFilter.inStock => 'Còn hàng',
        StockFilter.outOfStock => 'Hết hàng',
      };
}

/// Main admin window: list + search + sort/filter + CRUD actions.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, required this.email});
  final String? email;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  static const _windowTitle = 'Quản lý sản phẩm.exe';

  late Stream<ProductSnapshot> _stream;
  bool _gotFirstSnapshot = false;
  int _retries = 0;
  Timer? _watchdog;

  final _search = TextEditingController();
  String _query = '';
  SortMode _sort = SortMode.name;
  StockFilter _filter = StockFilter.all;
  bool _minimized = false;
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  /// Starts listening; if no first snapshot arrives within 8s, re-subscribes
  /// (up to 3 times) so a stalled listener right after sign-in recovers.
  void _subscribe() {
    _gotFirstSnapshot = false;
    _stream = ProductService.instance.watchAll().map((s) {
      _gotFirstSnapshot = true;
      _watchdog?.cancel();
      return s;
    });
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 8), () {
      if (!mounted || _gotFirstSnapshot || _retries >= 3) return;
      _retries++;
      setState(_subscribe);
    });
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _search.dispose();
    super.dispose();
  }

  // ---------- data ----------

  List<Product> _apply(List<Product> all) {
    final q = foldVi(_query.trim());
    final list = all.where((p) {
      if (q.isNotEmpty && !foldVi(p.name).contains(q)) return false;
      return switch (_filter) {
        StockFilter.all => true,
        StockFilter.inStock => p.soluong > 0,
        StockFilter.outOfStock => p.soluong <= 0,
      };
    }).toList();
    int byName(Product a, Product b) => foldVi(a.name).compareTo(foldVi(b.name));
    list.sort(switch (_sort) {
      SortMode.name => byName,
      SortMode.priceAsc => (a, b) => a.price.compareTo(b.price) != 0 ? a.price.compareTo(b.price) : byName(a, b),
      SortMode.priceDesc => (a, b) => b.price.compareTo(a.price) != 0 ? b.price.compareTo(a.price) : byName(a, b),
      SortMode.qtyDesc => (a, b) => b.soluong.compareTo(a.soluong) != 0 ? b.soluong.compareTo(a.soluong) : byName(a, b),
    });
    return list;
  }

  // ---------- actions ----------

  Future<void> _add() async {
    final saved = await Navigator.of(context).push<String>(
      RetroWindowRoute(builder: (_, max) => ProductFormScreen(maximized: max), maxWidth: 720),
    );
    if (saved != null && mounted) showBalloon(context, 'Đã thêm sản phẩm “$saved”.');
  }

  Future<void> _edit(Product p) async {
    final saved = await Navigator.of(context).push<String>(
      RetroWindowRoute(builder: (_, max) => ProductFormScreen(product: p, maximized: max), maxWidth: 720),
    );
    if (saved != null && mounted) showBalloon(context, 'Đã lưu thay đổi “$saved”.');
  }

  Future<void> _open(Product p) async {
    await Navigator.of(context).push<void>(
      RetroWindowRoute(
        builder: (_, max) => ProductDetailScreen(
          productId: p.id!,
          initial: p,
          maximized: max,
          onEdit: _edit,
          onDelete: (p) => _delete(p, fromDetail: true),
        ),
        maxWidth: 560,
      ),
    );
  }

  /// Returns true when the product was deleted.
  Future<bool> _delete(Product p, {bool fromDetail = false}) async {
    final ok = await confirmRetro(
      context,
      title: 'Xác nhận xóa',
      message: 'Bạn có chắc muốn xóa vĩnh viễn “${p.name}”?\nThao tác này không thể hoàn tác.',
      kind: DialogKind.warning,
    );
    if (!ok || !mounted) return false;
    try {
      await ProductService.instance.delete(p.id!);
      if (mounted) showBalloon(context, 'Đã xóa “${p.name}”.');
      return true;
    } catch (e) {
      if (mounted) {
        await showRetroDialog<void>(context, title: 'Lỗi', message: 'Không xóa được: $e', kind: DialogKind.error);
      }
      return false;
    }
  }

  Future<void> _export() async {
    try {
      final json = await ProductService.instance.exportJson();
      final saved = await saveTextFile('products.json', json);
      if (!mounted) return;
      if (saved) {
        showBalloon(context, 'Đã xuất products.json');
      } else {
        await Clipboard.setData(ClipboardData(text: json));
        if (!mounted) return;
        await showRetroDialog<void>(
          context,
          title: 'Xuất JSON',
          message: 'Đã sao chép dữ liệu JSON (${json.length} ký tự) vào bộ nhớ tạm.',
        );
      }
    } catch (e) {
      if (mounted) {
        await showRetroDialog<void>(context, title: 'Lỗi', message: 'Xuất JSON thất bại: $e', kind: DialogKind.error);
      }
    }
  }

  Future<void> _about() => showRetroDialog<void>(
        context,
        title: 'Giới thiệu',
        message: 'KTGK OS 2000 — Quản lý sản phẩm\n'
            'Flutter · Firebase Firestore · Firebase Auth · Cloudinary\n'
            'CSDL gồm 4 trường: name, price, soluong, image.',
      );

  Future<void> _logout() async {
    final ok = await confirmRetro(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có muốn đăng xuất khỏi ${widget.email ?? 'hệ thống'}?',
    );
    if (ok) await AuthService.instance.signOut();
  }

  Future<void> _startMenu(BuildContext anchor) async {
    final r = await showRetroMenu<String>(
      anchor,
      above: true,
      minWidth: 220,
      items: const [
        RetroMenuItem('Thêm sản phẩm…', 'add', icon: PixelIcons.document),
        RetroMenuItem('Xuất JSON', 'export', icon: PixelIcons.disk),
        RetroMenuItem('Giới thiệu', 'about', icon: PixelIcons.info),
        RetroMenuItem.separator(),
        RetroMenuItem('Đăng xuất…', 'logout', icon: PixelIcons.key),
      ],
    );
    switch (r) {
      case 'add':
        _add();
      case 'export':
        _export();
      case 'about':
        _about();
      case 'logout':
        _logout();
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final phone = Retro.isPhone(context);
    final showIcons = size.width >= 1100;

    final window = _buildWindow(phone);

    return DesktopShell(
      userLabel: widget.email,
      windowTitle: phone ? null : _windowTitle,
      windowActive: !_minimized,
      onWindowButton: () => setState(() => _minimized = !_minimized),
      onStart: _startMenu,
      child: Stack(
        children: [
          if (showIcons || _minimized)
            Positioned(
              left: 12,
              top: 12,
              child: Column(
                children: [
                  DesktopIcon(
                    icon: PixelIcons.folder,
                    label: 'Sản phẩm',
                    onOpen: () => setState(() => _minimized = false),
                  ),
                  const SizedBox(height: 16),
                  DesktopIcon(icon: PixelIcons.document, label: 'Thêm mới', onOpen: _add),
                  const SizedBox(height: 16),
                  DesktopIcon(icon: PixelIcons.disk, label: 'Xuất JSON', onOpen: _export),
                ],
              ),
            ),
          if (!_minimized)
            Positioned.fill(
              left: phone || _maximized ? 0 : (showIcons ? 110 : 20),
              top: phone || _maximized ? 0 : 16,
              right: phone || _maximized ? 0 : 20,
              bottom: phone || _maximized ? 0 : 12,
              child: window,
            ),
        ],
      ),
    );
  }

  Widget _buildWindow(bool phone) {
    return StreamBuilder<ProductSnapshot>(
      stream: _stream,
      builder: (context, snap) {
        final all = snap.data?.products ?? const <Product>[];
        final shown = _apply(all);
        final outCount = all.where((p) => !p.inStock).length;
        final syncing = snap.data?.pending ?? false;
        final offline = snap.data?.fromCache ?? false;

        return RetroWindow(
          title: _windowTitle,
          icon: PixelIcons.folder,
          expand: true,
          onMinimize: phone ? null : () => setState(() => _minimized = true),
          onMaximize: phone ? null : () => setState(() => _maximized = !_maximized),
          maximized: _maximized,
          onClose: _logout,
          menuBar: phone ? null : _menuBar(),
          toolbar: _toolbar(phone),
          statusBar: RetroStatusBar(panels: [
            Text(shown.length == all.length
                ? '${all.length} đối tượng'
                : '${shown.length}/${all.length} đối tượng'),
            Text('$outCount hết hàng'),
            if (!phone) Text('Tồn kho: ${formatInt(all.fold<int>(0, (s, p) => s + p.soluong))}'),
            Text(syncing
                ? 'Đang đồng bộ…'
                : offline
                    ? 'Ngoại tuyến (bộ nhớ đệm)'
                    : 'Đã đồng bộ'),
          ]),
          child: Bevel(
            style: BevelStyle.sunken,
            color: Retro.field,
            child: _content(snap, all, shown, phone),
          ),
        );
      },
    );
  }

  Widget _content(AsyncSnapshot<ProductSnapshot> snap, List<Product> all, List<Product> shown, bool phone) {
    if (snap.hasError) {
      final e = snap.error;
      final msg = e is FirebaseException && e.code == 'permission-denied'
          ? 'Không có quyền đọc dữ liệu. Kiểm tra Firestore Rules và đăng nhập.'
          : 'Không tải được dữ liệu: $e';
      return _centerMessage(PixelIcons.error, msg);
    }
    if (!snap.hasData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PixelIcon(PixelIcons.hourglass, size: 40),
            const SizedBox(height: 10),
            Text('Đang tải dữ liệu…', style: Retro.pixelStyle),
            const SizedBox(height: 10),
            const SizedBox(width: 200, child: RetroProgressBar(height: 16)),
          ],
        ),
      );
    }
    if (all.isEmpty) {
      return _centerMessage(
        PixelIcons.folder,
        'Thư mục trống — nhấn “Thêm mới” để tạo sản phẩm đầu tiên.',
        action: RetroButton(label: 'Thêm mới', icon: PixelIcons.document, onPressed: _add),
      );
    }
    if (shown.isEmpty) {
      return _centerMessage(PixelIcons.question, 'Không tìm thấy sản phẩm phù hợp.');
    }
    return LayoutBuilder(
      builder: (context, c) {
        final SliverGridDelegate delegate = phone
            ? SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: c.maxWidth >= 340 ? 2 : 1,
                mainAxisExtent: 250,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              )
            : const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisExtent: 290,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              );
        return Scrollbar(
          child: GridView.builder(
            padding: EdgeInsets.all(phone ? 8 : 12),
            gridDelegate: delegate,
            itemCount: shown.length,
            itemBuilder: (context, i) {
              final p = shown[i];
              return _PopIn(
                key: ValueKey(p.id),
                index: i,
                child: ProductCard(
                  product: p,
                  onOpen: () => _open(p),
                  onEdit: () => _edit(p),
                  onDelete: () => _delete(p),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _centerMessage(List<String> icon, String text, {Widget? action}) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PixelIcon(icon, size: 48),
              const SizedBox(height: 12),
              Text(text, textAlign: TextAlign.center, style: Retro.body.copyWith(fontSize: 14)),
              if (action != null) ...[const SizedBox(height: 14), action],
            ],
          ),
        ),
      );

  Widget _menuBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          _MenuBarButton(
            label: 'Tệp',
            items: const [
              RetroMenuItem('Thêm mới…', 'add', icon: PixelIcons.document),
              RetroMenuItem('Xuất JSON', 'export', icon: PixelIcons.disk),
              RetroMenuItem.separator(),
              RetroMenuItem('Đăng xuất…', 'logout', icon: PixelIcons.key),
            ],
            onSelected: (v) => switch (v) {
              'add' => _add(),
              'export' => _export(),
              'logout' => _logout(),
              _ => null,
            },
          ),
          _MenuBarButton(
            label: 'Xem',
            items: [
              for (final s in SortMode.values)
                RetroMenuItem('Sắp xếp: ${s.label}', 'sort:${s.name}', checked: _sort == s),
              const RetroMenuItem.separator(),
              for (final f in StockFilter.values)
                RetroMenuItem('Lọc: ${f.label}', 'filter:${f.name}', checked: _filter == f),
            ],
            onSelected: (v) {
              final parts = v.split(':');
              setState(() {
                if (parts[0] == 'sort') _sort = SortMode.values.byName(parts[1]);
                if (parts[0] == 'filter') _filter = StockFilter.values.byName(parts[1]);
              });
            },
          ),
          _MenuBarButton(
            label: 'Trợ giúp',
            items: const [RetroMenuItem('Giới thiệu…', 'about', icon: PixelIcons.info)],
            onSelected: (_) => _about(),
          ),
        ],
      ),
    );
  }

  Widget _toolbar(bool phone) {
    final search = RetroTextFormField(
      controller: _search,
      hint: 'Tìm theo tên…',
      onChanged: (v) => setState(() => _query = v),
      suffix: _query.isEmpty
          ? null
          : CaptionButton(
              glyph: CaptionGlyph.close,
              tooltip: 'Xóa tìm kiếm',
              size: const Size(16, 16),
              onPressed: () => setState(() {
                _search.clear();
                _query = '';
              }),
            ),
    );

    final sortButton = Builder(
      builder: (ctx) => RetroButton(
        label: phone ? _sort.label : 'Sắp xếp: ${_sort.label}',
        minWidth: 0,
        trailing: const Text('▾', style: Retro.body),
        tooltip: 'Sắp xếp',
        onPressed: () async {
          final r = await showRetroMenu<SortMode>(
            ctx,
            items: [
              for (final s in SortMode.values) RetroMenuItem(s.label, s, checked: _sort == s),
            ],
          );
          if (r != null) setState(() => _sort = r);
        },
      ),
    );

    final filters = Wrap(
      children: [
        for (final f in StockFilter.values)
          RetroButton(
            label: f.label,
            minWidth: phone ? 0 : 76,
            selected: _filter == f,
            onPressed: () => setState(() => _filter = f),
          ),
      ],
    );

    final addButton = RetroButton(
      label: 'Thêm mới',
      icon: PixelIcons.document,
      minWidth: 0,
      onPressed: _add,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
      child: phone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [Expanded(child: search), const SizedBox(width: 6), addButton]),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [filters, const SizedBox(width: 6), sortButton]),
                ),
              ],
            )
          : Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                addButton,
                SizedBox(width: 260, child: search),
                sortButton,
                filters,
              ],
            ),
    );
  }
}

class _MenuBarButton extends StatefulWidget {
  const _MenuBarButton({required this.label, required this.items, required this.onSelected});
  final String label;
  final List<RetroMenuItem<String>> items;
  final void Function(String value) onSelected;

  @override
  State<_MenuBarButton> createState() => _MenuBarButtonState();
}

class _MenuBarButtonState extends State<_MenuBarButton> {
  bool _open = false;
  bool _hover = false;

  Future<void> _show() async {
    setState(() => _open = true);
    final r = await showRetroMenu<String>(context, items: widget.items);
    if (mounted) setState(() => _open = false);
    if (r != null) widget.onSelected(r);
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.label.characters.first;
    final rest = widget.label.characters.skip(1).toString();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _show,
        child: Semantics(
          button: true,
          label: widget.label,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: _open
                  ? const Border(
                      top: BorderSide(color: Retro.dark),
                      left: BorderSide(color: Retro.dark),
                      bottom: BorderSide(color: Retro.light),
                      right: BorderSide(color: Retro.light),
                    )
                  : _hover
                      ? const Border(
                          top: BorderSide(color: Retro.light),
                          left: BorderSide(color: Retro.light),
                          bottom: BorderSide(color: Retro.dark),
                          right: BorderSide(color: Retro.dark),
                        )
                      : Border.all(color: Colors.transparent),
            ),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: first, style: const TextStyle(decoration: TextDecoration.underline)),
                TextSpan(text: rest),
              ]),
              style: Retro.body,
            ),
          ),
        ),
      ),
    );
  }
}

/// Short staggered "pop in" for cards, played once per card.
class _PopIn extends StatefulWidget {
  const _PopIn({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> {
  bool _shown = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(Duration(milliseconds: 30 * widget.index.clamp(0, 12)), () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        child: AnimatedScale(
          scale: _shown ? 1 : 0.92,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutBack,
          child: widget.child,
        ),
      );
}
