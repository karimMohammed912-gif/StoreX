import 'dart:convert';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/models/home_model/product.dart';

class SqliteFavoritesService extends GetxService {
  static Database? _database;
  static const String _tableName = 'favorite_products';
  static const String _dbName = 'store_x_favorites.db';
  static const int _dbVersion = 1;

  // Observable list of favorite products
  final RxList<Product> favoriteProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initDatabase();
  }

  /// Initialize the database
  Future<void> _initDatabase() async {
    _database = await _getDatabase();
    await _loadFavorites();
  }

  /// Get database instance
  Future<Database> _getDatabase() async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY,
        product_id INTEGER UNIQUE NOT NULL,
        product_data TEXT NOT NULL,
        added_at INTEGER NOT NULL
      )
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
    if (oldVersion < 2) {
      // Example: Add new columns or tables for future versions
    }
  }

  /// Load all favorite products from database
  Future<void> _loadFavorites() async {
    try {
      final db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'added_at DESC',
      );

      favoriteProducts.clear();
      for (final map in maps) {
        try {
          final productData = jsonDecode(map['product_data'] as String);
          final product = Product.fromJson(productData);
          favoriteProducts.add(product);
        } catch (e) {
          print('Error parsing product data: $e');
          // Remove corrupted data
          await _removeFavoriteById(map['product_id'] as int);
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  /// Add a product to favorites
  Future<bool> addToFavorites(Product product) async {
    try {
      if (product.id == null) {
        print('Product ID is null, cannot add to favorites');
        return false;
      }

      final db = await _getDatabase();

      // Check if product is already in favorites
      final existing = await db.query(
        _tableName,
        where: 'product_id = ?',
        whereArgs: [product.id],
      );

      if (existing.isNotEmpty) {
        print('Product is already in favorites');
        return false;
      }

      // Insert new favorite
      final productData = jsonEncode(product.toJson());
      final result = await db.insert(_tableName, {
        'product_id': product.id,
        'product_data': productData,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      });

      if (result > 0) {
        favoriteProducts.insert(0, product);
        favoriteProducts.refresh();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove a product from favorites
  Future<bool> removeFromFavorites(int productId) async {
    try {
      final db = await _getDatabase();
      final result = await db.delete(
        _tableName,
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

  /// Remove favorite by database ID (internal use)
  Future<void> _removeFavoriteById(int productId) async {
    try {
      final db = await _getDatabase();
      await db.delete(
        _tableName,
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      print('Error removing favorite by ID: $e');
    }
  }

  /// Check if a product is in favorites
  Future<bool> isFavorite(int productId) async {
    try {
      final db = await _getDatabase();
      final result = await db.query(
        _tableName,
        where: 'product_id = ?',
        whereArgs: [productId],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking if product is favorite: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(Product? product) async {
    if (product == null || product.id == null) return false;

    final isCurrentlyFavorite = favoriteProducts.any((p) => p.id == product.id);

    if (isCurrentlyFavorite) {
      return await removeFromFavorites(product.id!);
    } else {
      return await addToFavorites(product);
    }
  }

  /// Get all favorite products
  List<Product> getFavorites() {
    return List.from(favoriteProducts);
  }

  /// Get favorite count
  int get favoriteCount => favoriteProducts.length;

  /// Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      final db = await _getDatabase();
      final result = await db.delete(_tableName);

      if (result >= 0) {
        favoriteProducts.clear();
        return true;
      }
      return false;
    } catch (e) {
      print('Error clearing all favorites: $e');
      return false;
    }
  }

  /// Search favorites by title or description
  List<Product> searchFavorites(String query) {
    if (query.isEmpty) return getFavorites();

    final lowercaseQuery = query.toLowerCase();
    return favoriteProducts.where((product) {
      return (product.title?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (product.description?.toLowerCase().contains(lowercaseQuery) ??
              false) ||
          (product.brand?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Get favorites by category
  List<Product> getFavoritesByCategory(String category) {
    return favoriteProducts.where((product) {
      return product.category?.toLowerCase() == category.toLowerCase();
    }).toList();
  }

  /// Get favorites sorted by price
  List<Product> getFavoritesSortedByPrice({bool ascending = true}) {
    final sorted = List<Product>.from(favoriteProducts);
    sorted.sort((a, b) {
      final priceA = a.price ?? 0.0;
      final priceB = b.price ?? 0.0;
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    return sorted;
  }

  /// Get favorites sorted by rating
  List<Product> getFavoritesSortedByRating({bool ascending = false}) {
    final sorted = List<Product>.from(favoriteProducts);
    sorted.sort((a, b) {
      final ratingA = a.rating ?? 0.0;
      final ratingB = b.rating ?? 0.0;
      return ascending
          ? ratingA.compareTo(ratingB)
          : ratingB.compareTo(ratingA);
    });
    return sorted;
  }

  /// Close database connection
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  @override
  void onClose() {
    closeDatabase();
    super.onClose();
  }
}
