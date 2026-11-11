import 'package:cloud_firestore/cloud_firestore.dart';

/// A product document in the `products` collection.
///
/// The database stores ONLY four fields: name, price, soluong, image.
/// [id] is the Firestore document ID, not a stored field.
class Product {
  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });

  final String? id;
  final String name;

  /// Price in VND.
  final int price;

  /// Quantity in stock.
  final int soluong;

  /// Cloudinary image URL.
  final String image;

  bool get inStock => soluong > 0;

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Product(
      id: doc.id,
      name: (d['name'] as String?) ?? '',
      price: (d['price'] as num?)?.round() ?? 0,
      soluong: (d['soluong'] as num?)?.toInt() ?? 0,
      image: (d['image'] as String?) ?? '',
    );
  }

  /// Exactly the four allowed fields — nothing else is ever written.
  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'soluong': soluong,
        'image': image,
      };

  Product copyWith({String? name, int? price, int? soluong, String? image}) => Product(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        soluong: soluong ?? this.soluong,
        image: image ?? this.image,
      );
}
