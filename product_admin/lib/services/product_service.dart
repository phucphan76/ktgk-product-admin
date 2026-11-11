import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';

class ProductSnapshot {
  const ProductSnapshot(this.products, {required this.pending, required this.fromCache});
  final List<Product> products;
  final bool pending;
  final bool fromCache;
}

/// CRUD for the `products` collection.
class ProductService {
  ProductService._();
  static final instance = ProductService._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('products');

  /// In-memory demo data (used only by lib/main_preview.dart, no Firebase).
  _DemoStore? _demo;
  void enableDemo(List<Product> seed) => _demo = _DemoStore(seed);

  Stream<ProductSnapshot> watchAll() => _demo?.watchAll() ?? _watchFirestore();

  Stream<ProductSnapshot> _watchFirestore() async* {
    // Right after sign-in, make sure the ID token is ready before Firestore
    // starts listening; otherwise the first listener can stall on web.
    try {
      await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (_) {
      // The listener below reports any real auth problem as an error.
    }
    yield* _col.snapshots(includeMetadataChanges: true).map((s) => ProductSnapshot(
          s.docs.map(Product.fromDoc).toList(),
          pending: s.metadata.hasPendingWrites,
          fromCache: s.metadata.isFromCache,
        ));
  }

  Stream<Product?> watch(String id) =>
      _demo?.watch(id) ??
      _col.doc(id).snapshots().map((d) => d.exists ? Product.fromDoc(d) : null);

  Future<String> add(Product p) async =>
      _demo?.add(p) ?? (await _col.add(p.toMap())).id;

  Future<void> update(Product p) async =>
      _demo != null ? _demo!.update(p) : await _col.doc(p.id).set(p.toMap());

  Future<void> delete(String id) async =>
      _demo != null ? _demo!.delete(id) : await _col.doc(id).delete();

  /// Exports the collection as JSON: `{"products": {"docId": {name, price, soluong, image}}}`
  Future<String> exportJson() async {
    final Map<String, Map<String, dynamic>> products;
    if (_demo != null) {
      products = {for (final p in _demo!.items) p.id!: p.toMap()};
    } else {
      final snap = await _col.get();
      products = {for (final d in snap.docs) d.id: Product.fromDoc(d).toMap()};
    }
    final data = {'products': products};
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}

class _DemoStore {
  _DemoStore(List<Product> seed) : items = [...seed];
  final List<Product> items;
  final _changes = StreamController<void>.broadcast();
  int _next = 100;

  ProductSnapshot _snap() => ProductSnapshot(List.of(items), pending: false, fromCache: false);

  Stream<ProductSnapshot> watchAll() async* {
    yield _snap();
    yield* _changes.stream.map((_) => _snap());
  }

  Stream<Product?> watch(String id) async* {
    Product? find() => items.where((p) => p.id == id).firstOrNull;
    yield find();
    yield* _changes.stream.map((_) => find());
  }

  String add(Product p) {
    final id = 'demo${_next++}';
    items.add(Product(id: id, name: p.name, price: p.price, soluong: p.soluong, image: p.image));
    _changes.add(null);
    return id;
  }

  void update(Product p) {
    final i = items.indexWhere((e) => e.id == p.id);
    if (i >= 0) items[i] = p;
    _changes.add(null);
  }

  void delete(String id) {
    items.removeWhere((e) => e.id == id);
    _changes.add(null);
  }
}
