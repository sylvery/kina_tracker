import 'package:kina_tracker/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  late DatabaseConnection _databaseConnection;
  Repository() {
    _databaseConnection = DatabaseConnection();
  }
  static Database? _database;
  Future<Database?> get database async {
    _database = await _databaseConnection.setDatabase();
    return _database;
  }

  insertData(table, data) async {
    try {
      var connection = await database;
      return await connection?.insert(table, data);
    } catch (e) {
      // print('Error inserting data: $e');
      return null;
    }
  }

  readData(table) async {
    var connection = await database;
    return await connection?.query(table, orderBy: 'id DESC');
  }

  readDataById(table, itemId) async {
    var connection = await database;
    return await connection?.query(table, where: 'id=?', whereArgs: [itemId]);
  }

  readUnpaidTransactions(
      table, int? paidStatus, int? splitStatus, String? transactionType) async {
    var connection = await database;
    return await connection?.query(table,
        where: 'paid=? and split=? and transaction_type=?',
        whereArgs: [paidStatus, splitStatus, transactionType],
        orderBy: 'date');
  }

  readUnpaidBankTransactions(
      table, int? paidStatus, int? splitStatus, String? basket) async {
    var connection = await database;
    return await connection?.query(table,
        where: 'paid=? and split=? and basket=?',
        whereArgs: [paidStatus, splitStatus, basket],
        orderBy: 'date');
  }

  updateData(table, data) async {
    var connection = await database;
    return await connection
        ?.update(table, data, where: 'id=?', whereArgs: [data['id']]);
  }

  deleteData(table, itemId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where id=$itemId");
  }
}
