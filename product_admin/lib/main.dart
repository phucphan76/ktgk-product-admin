import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/boot_screen.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'services/auth_service.dart';
import 'ui/widgets/retro.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Release builds swallow framework errors; log them so problems are diagnosable.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}\n${details.stack}');
  };
  // Show the error text instead of a plain grey box when a widget fails to build.
  ErrorWidget.builder = (details) => Material(
        color: Retro.field,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Lỗi hiển thị: ${details.exceptionAsString()}',
            style: Retro.label.copyWith(color: Retro.error),
          ),
        ),
      );
  runApp(const KtgkApp());
}

class KtgkApp extends StatelessWidget {
  const KtgkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KTGK OS 2000 — Quản lý sản phẩm',
      debugShowCheckedModeBanner: false,
      theme: Retro.theme(),
      builder: (context, child) => PointerTracker(child: child!),
      home: const _Bootstrap(),
    );
  }
}

/// Initializes Firebase behind a short boot screen, then hands off to [AuthGate].
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late final Future<void> _init = _start();

  Future<void> _start() async {
    if (!DefaultFirebaseOptions.configured) {
      throw StateError(
        'Chưa cấu hình Firebase. Hãy điền thông số vào lib/firebase_options.dart.',
      );
    }
    await Future.wait([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      Future<void>.delayed(const Duration(milliseconds: 1100)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const BootScreen();
        }
        if (snap.hasError) {
          return BootScreen(error: snap.error.toString().replaceFirst('Bad state: ', ''));
        }
        return const AuthGate();
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const BootScreen();
        }
        final user = snap.data;
        if (user == null) return const LoginScreen();
        return ProductListScreen(key: ValueKey(user.uid), email: user.email);
      },
    );
  }
}
