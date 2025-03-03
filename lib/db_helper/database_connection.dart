import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseConnection {
  static Database? _database;
  static const String tableName = 'my_table';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await setDatabase();
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> setDatabase() async {
    var path = join(await getDatabasesPath(), 'kina_crud.db');
    // var path = join(directory.path, 'kina_crud');
    // String path = join(await getDatabasesPath(), 'kina_crud.db');
    // var path = join(directory.path, 'kina_db');
    // print('db directory: $directory');
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
    return database;
  }

  Future<void> _createDatabase(Database database, int version) async {
    String sql =
        "CREATE TABLE kina_transactions (id integer PRIMARY KEY, date VARCHAR, transaction_type VARCHAR, basket VARCHAR, description TEXT, amount DOUBLE, split INTEGER, paid INTEGER)";
    await database.execute(sql);
  }

  Future<void> _upgradeDatabase(
      Database database, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      String sql = "ALTER TABLE kina_transactions ADD COLUMN image_path TEXT";
      await database.execute(sql);
    }
  }
}
