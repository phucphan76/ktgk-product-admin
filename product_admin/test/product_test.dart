import 'package:flutter_test/flutter_test.dart';
import 'package:product_admin/models/product.dart';
import 'package:product_admin/utils/format.dart';

void main() {
  test('Product.toMap only contains the 4 allowed fields', () {
    const p = Product(id: 'abc', name: 'Áo thun', price: 150000, soluong: 8, image: 'https://x/y.jpg');
    expect(p.toMap().keys.toSet(), {'name', 'price', 'soluong', 'image'});
    expect(p.toMap().containsKey('id'), isFalse);
  });

  test('foldVi strips Vietnamese diacritics for search', () {
    expect(foldVi('Giày Sneaker Bạc'), 'giay sneaker bac');
    expect(foldVi('Đồng hồ'), 'dong ho');
  });

  test('formatVnd uses Vietnamese grouping', () {
    expect(formatVnd(150000).replaceAll(' ', ' '), '150.000 ₫');
  });
}
