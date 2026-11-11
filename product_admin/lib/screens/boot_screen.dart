import 'package:flutter/material.dart';

import '../ui/widgets/retro.dart';

/// Black boot screen with the chrome "KTGK OS 2000" logo.
class BootScreen extends StatelessWidget {
  const BootScreen({super.key, this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    final phone = Retro.isPhone(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PixelIcon(PixelIcons.computer, size: 64),
                  const SizedBox(height: 16),
                  FittedBox(child: ChromeText('KTGK OS 2000', size: phone ? 48 : 64)),
                  const SizedBox(height: 4),
                  Text(
                    'Hệ thống quản lý sản phẩm',
                    style: Retro.pixelStyle.copyWith(color: const Color(0xFF9FB3CF), fontSize: 22),
                  ),
                  const SizedBox(height: 28),
                  if (error == null) ...[
                    const SizedBox(width: 260, child: RetroProgressBar()),
                    const SizedBox(height: 10),
                    Text(
                      'Đang khởi động…',
                      style: Retro.pixelStyle.copyWith(color: Colors.white, fontSize: 20),
                    ),
                  ] else
                    RetroWindow(
                      title: 'Lỗi khởi động',
                      icon: PixelIcons.error,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const PixelIcon(PixelIcons.error, size: 32),
                            const SizedBox(width: 12),
                            Expanded(child: Text(error!, style: Retro.body)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
