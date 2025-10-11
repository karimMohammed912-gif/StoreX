import 'dart:convert';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/cart_model/cart_item.dart';
import '../data/models/home_model/product.dart';
import 'base_sqlite_service.dart';

class SqliteCartService extends BaseSqliteService {
  @override
  String get dbName => 'store_x_cart.db';
  
  @override
  String get tableName => 'cart_items';

  final RxList<CartItem> cartItems = <CartItem>[].obs;

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        product_id INTEGER UNIQUE NOT NULL,
        product_data TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        added_at INTEGER NOT NULL
      )
    ''');
  }

  @override
  Future<void> loadData() async {
    try {
      final db = await getDatabase();
      final maps = await db.query(tableName, orderBy: 'added_at DESC');

      cartItems.clear();
      for (final map in maps) {
        try {
          final productData = jsonDecode(map['product_data'] as String);
          final product = Product.fromJson(productData);
          final cartItem = CartItem(
            id: map['id'] as String,
            product: product,
            quantity: map['quantity'] as int,
            addedAt: DateTime.fromMillisecondsSinceEpoch(map['added_at'] as int),
          );
          cartItems.add(cartItem);
        } catch (e) {
          print('Error parsing cart item: $e');
          await _removeCartItemById(map['id'] as String);
        }
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    try {
      if (product.id == null) return false;

      final db = await getDatabase();
      final existing = await db.query(
        tableName,
        where: 'product_id = ?',
        whereArgs: [product.id],
      );

      if (existing.isNotEmpty) {
        final currentQty = existing.first['quantity'] as int;
        return await updateQuantity(product.id!, currentQty + quantity);
      }

      final cartItemId = '${product.id}_${DateTime.now().millisecondsSinceEpoch}';
      final addedAt = DateTime.now().millisecondsSinceEpoch;

      await db.insert(tableName, {
        'id': cartItemId,
        'product_id': product.id,
        'product_data': jsonEncode(product.toJson()),
        'quantity': quantity,
        'added_at': addedAt,
      });

      cartItems.insert(0, CartItem(
        id: cartItemId,
        product: product,
        quantity: quantity,
        addedAt: DateTime.fromMillisecondsSinceEpoch(addedAt),
      ));
      cartItems.refresh();
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  Future<bool> removeFromCart(int productId) async {
    try {
      final db = await getDatabase();
      final result = await db.delete(
        tableName,
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      if (result > 0) {
        cartItems.removeWhere((item) => item.product.id == productId);
        cartItems.refresh();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  Future<void> _removeCartItemById(String cartItemId) async {
    try {
      final db = await getDatabase();
      await db.delete(tableName, where: 'id = ?', whereArgs: [cartItemId]);
    } catch (e) {
      print('Error removing cart item: $e');
    }
  }

  Future<bool> updateQuantity(int productId, int newQuantity) async {
    try {
      if (newQuantity <= 0) return await removeFromCart(productId);

      final db = await getDatabase();
      final result = await db.update(
        tableName,
        {'quantity': newQuantity},
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      if (result > 0) {
        final index = cartItems.indexWhere((item) => item.product.id == productId);
        if (index != -1) {
          cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
          cartItems.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  Future<bool> incrementQuantity(int productId) async {
    final item = cartItems.firstWhereOrNull((item) => item.product.id == productId);
    return item != null ? await updateQuantity(productId, item.quantity + 1) : false;
  }

  Future<bool> decrementQuantity(int productId) async {
    final item = cartItems.firstWhereOrNull((item) => item.product.id == productId);
    return item != null ? await updateQuantity(productId, item.quantity - 1) : false;
  }

  bool isInCart(int productId) => cartItems.any((item) => item.product.id == productId);

  CartItem? getCartItem(int productId) {
    return cartItems.firstWhereOrNull((item) => item.product.id == productId);
  }

  int getCartItemQuantity(int productId) => getCartItem(productId)?.quantity ?? 0;

  List<CartItem> getCartItems() => List.from(cartItems);

  int get itemCount => cartItems.length;

  int get totalQuantity => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) {
      final price = item.product.price ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  double get totalDiscount {
    return cartItems.fold(0.0, (sum, item) {
      final price = item.product.price ?? 0.0;
      final discount = item.product.discountPercentage ?? 0.0;
      return sum + ((price * discount / 100) * item.quantity);
    });
  }

  double get total => subtotal - totalDiscount;

  Future<bool> clearCart() async {
    try {
      final db = await getDatabase();
      await db.delete(tableName);
      cartItems.clear();
      cartItems.refresh();
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  Future<void> resetForNewUser() async {
    await clearCart();
    await loadData();
  }
}
