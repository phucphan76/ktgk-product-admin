// UI preview without Firebase: `flutter run -d web-server -t lib/main_preview.dart`
// Uses in-memory sample data so the retro UI can be checked before Firebase is set up.
import 'package:flutter/material.dart';

import 'models/product.dart';
import 'screens/boot_screen.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'ui/widgets/retro.dart';

void main() {
  ProductService.instance.enableDemo(const [
    Product(id: 'demo1', name: 'Áo thun Y2K', price: 150000, soluong: 8, image: 'https://picsum.photos/seed/aothun/500'),
    Product(id: 'demo2', name: 'Giày sneaker bạc', price: 900000, soluong: 0, image: 'https://picsum.photos/seed/giay/500'),
    Product(id: 'demo3', name: 'Mũ bucket hồng', price: 90000, soluong: 3, image: 'https://picsum.photos/seed/mu/500'),
    Product(id: 'demo4', name: 'Kính râm holographic', price: 250000, soluong: 12, image: 'https://picsum.photos/seed/kinh/500'),
    Product(id: 'demo5', name: 'Túi đeo chéo mini', price: 320000, soluong: 5, image: ''),
  ]);
  runApp(const _PreviewApp());
}

class _PreviewApp extends StatefulWidget {
  const _PreviewApp();

  @override
  State<_PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends State<_PreviewApp> {
  /// boot | login | list (switch with ?screen=... in the URL)
  late String _screen = Uri.base.queryParameters['screen'] ?? 'list';

  @override
  void initState() {
    super.initState();
    AuthService.instance.demoSignOut = () => setState(() => _screen = 'login');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KTGK OS 2000 — Xem thử',
      debugShowCheckedModeBanner: false,
      theme: Retro.theme(),
      builder: (context, child) => PointerTracker(child: child!),
      home: switch (_screen) {
        'boot' => const BootScreen(),
        'login' => const LoginScreen(),
        _ => const ProductListScreen(email: 'admin@ktgk.com'),
      },
    );
  }
}
