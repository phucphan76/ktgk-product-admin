import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_admin/ui/widgets/retro.dart';

void main() {
  testWidgets('retro menu renders items', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(MaterialApp(
      theme: Retro.theme(),
      home: Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: RetroButton(
              label: 'Open',
              onPressed: () => showRetroMenu<String>(ctx, items: const [
                RetroMenuItem('Thêm mới', 'add', icon: PixelIcons.document),
                RetroMenuItem.separator(),
                RetroMenuItem('Đăng xuất', 'logout'),
              ]),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Thêm mới'), findsOneWidget);
  });
}
