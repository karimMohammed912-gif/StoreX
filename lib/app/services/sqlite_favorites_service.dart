import 'dart:convert';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/home_model/product.dart';
import 'base_sqlite_service.dart';

class SqliteFavoritesService extends BaseSqliteService {
  @override
  String get dbName => 'store_x_favorites.db';
  
  @override
  String get tableName => 'favorite_products';

  final RxList<Product> favoriteProducts = <Product>[].obs;

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
        product_id INTEGER UNIQUE NOT NULL,
        product_data TEXT NOT NULL,
        added_at INTEGER NOT NULL
      )
    ''');
  }

  @override
  Future<void> loadData() async {
    try {
      final db = await getDatabase();
      final maps = await db.query(tableName, orderBy: 'added_at DESC');

      favoriteProducts.clear();
      for (final map in maps) {
        try {
          final productData = jsonDecode(map['product_data'] as String);
          final product = Product.fromJson(productData);
          favoriteProducts.add(product);
        } catch (e) {
          print('Error parsing favorite: $e');
          await _removeFavoriteById(map['product_id'] as int);
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<bool> addToFavorites(Product product) async {
    try {
      if (product.id == null) return false;

      final db = await getDatabase();
      final existing = await db.query(
        tableName,
        where: 'product_id = ?',
        whereArgs: [product.id],
      );

      if (existing.isNotEmpty) return false;

      await db.insert(tableName, {
        'product_id': product.id,
        'product_data': jsonEncode(product.toJson()),
        'added_at': DateTime.now().millisecondsSinceEpoch,
      });

      favoriteProducts.insert(0, product);
      favoriteProducts.refresh();
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(int productId) async {
    try {
      final db = await getDatabase();
      final result = await db.delete(
        tableName,
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      if (result > 0) {
        favoriteProducts.removeWhere((product) => product.id == productId);
        favoriteProducts.refresh();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  Future<void> _removeFavoriteById(int productId) async {
    try {
      final db = await getDatabase();
      await db.delete(
        tableName,
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<bool> isFavorite(int productId) async {
    try {
      final db = await getDatabase();
      final result = await db.query(
        tableName,
        where: 'product_id = ?',
        whereArgs: [productId],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(Product? product) async {
    if (product == null || product.id == null) return false;

    final isFav = favoriteProducts.any((p) => p.id == product.id);
    return isFav 
        ? await removeFromFavorites(product.id!)
        : await addToFavorites(product);
  }

  List<Product> getFavorites() => List.from(favoriteProducts);

  int get favoriteCount => favoriteProducts.length;

  Future<bool> clearAllFavorites() async {
    try {
      final db = await getDatabase();
      await db.delete(tableName);
      favoriteProducts.clear();
      favoriteProducts.refresh();
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }

  Future<void> resetForNewUser() async {
    await clearAllFavorites();
    await loadData();
  }

  List<Product> searchFavorites(String query) {
    if (query.isEmpty) return getFavorites();

    final q = query.toLowerCase();
    return favoriteProducts.where((product) {
      return (product.title?.toLowerCase().contains(q) ?? false) ||
          (product.description?.toLowerCase().contains(q) ?? false) ||
          (product.brand?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<Product> getFavoritesByCategory(String category) {
    return favoriteProducts
        .where((p) => p.category?.toLowerCase() == category.toLowerCase())
        .toList();
  }

  List<Product> getFavoritesSortedByPrice({bool ascending = true}) {
    final sorted = List<Product>.from(favoriteProducts);
    sorted.sort((a, b) {
      final priceA = a.price ?? 0.0;
      final priceB = b.price ?? 0.0;
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    return sorted;
  }

  List<Product> getFavoritesSortedByRating({bool ascending = false}) {
    final sorted = List<Product>.from(favoriteProducts);
    sorted.sort((a, b) {
      final ratingA = a.rating ?? 0.0;
      final ratingB = b.rating ?? 0.0;
      return ascending ? ratingA.compareTo(ratingB) : ratingB.compareTo(ratingA);
    });
    return sorted;
  }
}
