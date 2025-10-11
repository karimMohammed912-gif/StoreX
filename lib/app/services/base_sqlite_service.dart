import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Base class for SQLite services to reduce code duplication
abstract class BaseSqliteService extends GetxService {
  Database? _database;

  /// Database name - must be implemented by subclass
  String get dbName;

  /// Table name - must be implemented by subclass
  String get tableName;

  /// Database version
  int get dbVersion => 1;

  @override
  void onInit() {
    super.onInit();
    initDatabase();
  }

  /// Initialize the database
  Future<void> initDatabase() async {
    _database = await getDatabase();
    await loadData();
  }

  /// Get database instance
  Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    _database = await openDatabase(
      path,
      version: dbVersion,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );

    return _database!;
  }

  /// Create database tables - must be implemented by subclass
  Future<void> onCreate(Database db, int version);

  /// Handle database upgrades
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Override in subclass if needed
  }

  /// Load data from database - must be implemented by subclass
  Future<void> loadData();

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
