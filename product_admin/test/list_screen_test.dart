import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_admin/models/product.dart';
import 'package:product_admin/screens/product_list_screen.dart';
import 'package:product_admin/services/product_service.dart';
import 'package:product_admin/ui/widgets/retro.dart';

void main() {
  // Desktop widths. The phone layout is verified on a real device: the test font draws
  // every glyph as a full square, which makes narrow layouts overflow only in tests.
  for (final size in [const Size(1280, 800), const Size(1100, 700), const Size(800, 600)]) {
    testWidgets('list screen renders at $size', (tester) async {
      ProductService.instance.enableDemo(const [
        Product(id: 'a', name: 'Áo thun Y2K', price: 150000, soluong: 10, image: ''),
        Product(id: 'b', name: 'Denim Mini Short', price: 400000, soluong: 5, image: ''),
        Product(id: 'c', name: 'Mắt kính cat-eye', price: 250000, soluong: 5, image: ''),
        Product(id: 'd', name: 'Mũ lưỡi trai wash', price: 130000, soluong: 0, image: ''),
      ]);
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(MaterialApp(
        theme: Retro.theme(),
        home: const ProductListScreen(email: 'admin@ktgk.com'),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      expect(find.text('Áo thun Y2K'), findsWidgets);
      await tester.pump(const Duration(seconds: 9)); // let the watchdog timer pass
    });
  }
}
