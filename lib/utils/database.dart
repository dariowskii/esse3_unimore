import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB();
    return _database;
  }

  void _updateDB(Batch batch){
    batch.execute('''
        CREATE TABLE orario_settimanale(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          giorno INTEGER,
          inizio TEXT,
          fine TEXT,
          titolo TEXT,
          prof TEXT,
          prof_gen INTEGER,
          view_link INTEGER,
          link TEXT,
          colore TEXT
        )
      ''');
  }

  void _createDBver2(Batch batch){
    batch.execute('''
        CREATE TABLE orario_settimanale(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          giorno INTEGER,
          inizio TEXT,
          fine TEXT,
          titolo TEXT,
          prof TEXT,
          prof_gen INTEGER,
          view_link INTEGER,
          link TEXT,
          colore TEXT
        )
      ''');
    batch.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          nome_studente TEXT,
          matricola TEXT,
          corso_stud TEXT,
          tipo_corso TEXT,
          profilo_studente TEXT,
          anno_corso TEXT,
          data_imm TEXT,
          part_time TEXT,
          text_avatar TEXT
        )
      ''');
  }

  _initDB() async {
    return await openDatabase(
        join(await getDatabasesPath(), 'esse3_unimore.db'),
        onCreate: (db, version) async {
          var batch = db.batch();
        _createDBver2(batch);
        await batch.commit();
    }, onUpgrade: (db, oldVersion, newVersion) async {
      var batch = db.batch();
      _updateDB(batch);
      await batch.commit();
    }, onDowngrade: onDatabaseDowngradeDelete, version: 2,);
  }

  newUser(Map newUser) async {
    final db = await database;

    var res = await db.rawInsert('''
      INSERT INTO users (
        username, 
        nome_studente, 
        matricola, 
        corso_stud, 
        tipo_corso, 
        profilo_studente,
        anno_corso,
        data_imm,
        part_time,
        text_avatar
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      newUser["username"],
      newUser["nome"],
      newUser["matricola"],
      newUser["corso_stud"],
      newUser["tipo_corso"],
      newUser["profilo_studente"],
      newUser["anno_corso"],
      newUser["data_imm"],
      newUser["part_time"],
      newUser["text_avatar"]
    ]);
    print("new $res");
    return res;
  }

  getUser(String username) async {
    final db = await database;
    List<dynamic> args = [username];
    var res = await db.rawQuery(
        'SELECT * FROM users WHERE username = ?', args);

    if (res.isEmpty) return null;
    else return res[0];
  }

  Future checkExistUser(String username) async{
    final db = await database;
    List<dynamic> args = [username];
    var res = await db.rawQuery(
        'SELECT username FROM users WHERE username = ?', args);

    print("check $res");
    if (res.isEmpty) return null;
    else return res[0];
  }
  
  updateUser(Map newUser, String username) async{
    final db = await database;
    
    var res = db.rawUpdate('''
      UPDATE users
      SET username = ?, 
        nome_studente = ?, 
        matricola = ?, 
        corso_stud = ?, 
        tipo_corso = ?, 
        profilo_studente = ?,
        anno_corso = ?,
        data_imm = ?,
        part_time = ?,
        text_avatar = ?
        WHERE username = ?
    ''', [
      newUser["username"],
      newUser["nome"],
      newUser["matricola"],
      newUser["corso_stud"],
      newUser["tipo_corso"],
      newUser["profilo_studente"],
      newUser["anno_corso"],
      newUser["data_imm"],
      newUser["part_time"],
      newUser["text_avatar"],
      newUser["username"],
    ]);

    res.then((data){
      print("update $data");
      return data;
    });
  }
}
