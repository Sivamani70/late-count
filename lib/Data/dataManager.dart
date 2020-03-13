import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StudentDataModel {
  final String rollNo;
  Database _dataBase;
  final String tableName = 'student_Late_Count';
  int count = 0, status = 0;
  StudentDataModel({this.rollNo});

  Future<void> openDataBaseCon() async {
    _dataBase = await openDatabase(
      join(await getDatabasesPath(), 'db_late_on.db'),
      version: 1,
      onCreate: (Database db, int newVersion) async {
        return await db.execute(
          "CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, rollNum TEXT NOT NULL , lateCount INTEGER DEFAULT 0)",
        );
      },
    );
  }

  Future<List<int>> insertData({Database database}) async {
    count++;
    final Database db = _dataBase;
    status = await db.rawInsert(
        'INSERT INTO $tableName(rollNum , lateCount) VALUES($rollNo , $count)');
    await closeDatabase(db);
    return [status, count];
  }

  Future<List<int>> retriveData() async {
    final Database db = _dataBase;
    List<Map> list =
        await db.rawQuery('select *from $tableName where rollnum = $rollNo');
    if (list.isEmpty) {
      final resList = await insertData(database: db);
      return resList;
    } else {
      int exisitingCount = list[0]['lateCount'];
      exisitingCount++;
      status = await db.rawUpdate(
          'UPDATE $tableName SET lateCount = $exisitingCount WHERE  rollnum = $rollNo');
      await closeDatabase(db);
      return [status, exisitingCount];
    }
  }

  Future<List> dispalayData() async {
    List<Map> dataList;
    await openDataBaseCon();
    Database _db = _dataBase;
    dataList =
        await _db.rawQuery('select *from $tableName ORDER BY lateCount DESC');
    await closeDatabase(_db);
    return dataList;
  }

  Future<void> deleteData() async {
    await openDataBaseCon();
    Database _db = _dataBase;
    await _db.delete('$tableName');
    await closeDatabase(_db);
  }

  Future<void> closeDatabase(Database db) async {
    await db.close();
    await _dataBase.close();
  }

  Future<void> dispose() async {
    if (_dataBase != null) {
      _dataBase.close();
    }
  }
}
