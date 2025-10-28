import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_dto.dart';
import '../models/order_create_dto.dart';

class CartItemSnap {
  final int id;
  final String? name;
  final double? price;
  final int stock;
  final int companyUserId;
  final String? imageUrl;

  CartItemSnap({
    required this.id,
    this.name,
    this.price,
    required this.stock,
    required this.companyUserId,
    this.imageUrl,
  });

  factory CartItemSnap.fromProduct(ProductDto p) => CartItemSnap(
        id: p.id,
        name: p.name,
        price: p.price,
        stock: p.stock,
        companyUserId: p.companyUserId,
        imageUrl: p.imageUrl,
      );

  factory CartItemSnap.fromJson(Map<String, dynamic> j) => CartItemSnap(
        id: j['id'],
        name: j['name'],
        price: (j['price'] as num?)?.toDouble(),
        stock: j['stock'] ?? 0,
        companyUserId: j['companyUserId'],
        imageUrl: j['imageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'companyUserId': companyUserId,
        'imageUrl': imageUrl,
      };

  ProductDto toProductDto() => ProductDto(
        id: id,
        companyUserId: companyUserId,
        name: name,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        description: null,
        avgRating: 0,
      );
}

class CartEntry {
  CartEntry({required this.snap, required this.quantity});
  final CartItemSnap snap;
  int quantity;

  Map<String, dynamic> toJson() => {
        'snap': snap.toJson(),
        'quantity': quantity,
      };

  factory CartEntry.fromJson(Map<String, dynamic> j) => CartEntry(
        snap: CartItemSnap.fromJson(j['snap']),
        quantity: j['quantity'],
      );
}

class CartService extends ChangeNotifier {
  CartService._();
  static final instance = CartService._();

  static const _storageKey = 'cart_v1';

  // productId -> entry
  final Map<int, CartEntry> _items = {};
  int? _companyUserId;

  Map<int, CartEntry> get items => _items;
  int? get companyUserId => _companyUserId;

  double get total => _items.values.fold(
        0.0,
        (s, e) => s + (e.snap.price ?? 0) * e.quantity,
      );

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_storageKey);
    if (raw == null) return;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    _companyUserId = map['companyUserId'];
    _items.clear();
    final list = (map['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (final m in list) {
      final ce = CartEntry.fromJson(m);
      _items[ce.snap.id] = ce;
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    final data = {
      'companyUserId': _companyUserId,
      'items': _items.values.map((e) => e.toJson()).toList(),
    };
    await sp.setString(_storageKey, jsonEncode(data));
  }

  /// Agrega un producto. Devuelve `true` si se pudo, `false` si fue rechazado
  /// (por mezcla de empresas).
  Future<bool> add(ProductDto p, {int qty = 1}) async {
    _companyUserId ??= p.companyUserId;
    if (_companyUserId != p.companyUserId) {
      return false; // no permitir mezclar empresas
    }

    final snap = CartItemSnap.fromProduct(p);
    final current = _items[p.id] ?? CartEntry(snap: snap, quantity: 0);
    current.quantity = (current.quantity + qty).clamp(1, p.stock);
    _items[p.id] = current;

    await _save();
    notifyListeners();
    return true;
  }

  Future<void> setQuantity(int productId, int qty) async {
    final ce = _items[productId];
    if (ce == null) return;
    ce.quantity = qty.clamp(1, ce.snap.stock);
    await _save();
    notifyListeners();
  }

  Future<void> remove(int productId) async {
    _items.remove(productId);
    if (_items.isEmpty) _companyUserId = null;
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    _companyUserId = null;
    await _save();
    notifyListeners();
  }

  /// Para construir el DTO del pedido
  List<OrderItemReq> toOrderItems() => _items.values
      .map((e) => OrderItemReq(productId: e.snap.id, quantity: e.quantity))
      .toList();
}
