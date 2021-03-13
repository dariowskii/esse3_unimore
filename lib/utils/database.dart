import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

/// Questa classe si interfaccia come [Database].
class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  /// Ritorna il [_database].
  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB();
    return _database;
  }

  /// Crea il [_database] con le eventuali regole SQL [batch].
  void _createDB(Batch batch) {
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
          text_avatar TEXT,
          profile_pic TEXT
        )
      ''');
  }

  /// Inizializza il [_database].
  Future<Database> _initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'esse3_unimore.db'),
      onCreate: (db, version) async {
        var batch = db.batch();
        _createDB(batch);
        await batch.commit();
      },
      onDowngrade: onDatabaseDowngradeDelete,
      version: 1,
    );
  }

  /// Inserisce un nuovo utente nel [_database].
  Future<int> newUser(Map newUser) async {
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
        text_avatar,
        profile_pic
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      newUser['username'],
      newUser['nome'],
      newUser['matricola'],
      newUser['corso_stud'],
      newUser['tipo_corso'],
      newUser['profilo_studente'],
      newUser['anno_corso'],
      newUser['data_imm'],
      newUser['part_time'],
      newUser['text_avatar'],
      newUser['profile_pic']
    ]);

    return res;
  }

  /// Aggiorna un utente nel [_database].
  Future<int> updateUser(Map newUser) async {
    final db = await database;

    var res = await db.rawUpdate('''
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
        text_avatar = ?,
        profile_pic = ?
        WHERE username = ?
    ''', [
      newUser['username'],
      newUser['nome'],
      newUser['matricola'],
      newUser['corso_stud'],
      newUser['tipo_corso'],
      newUser['profilo_studente'],
      newUser['anno_corso'],
      newUser['data_imm'],
      newUser['part_time'],
      newUser['text_avatar'],
      newUser['profile_pic'],
      newUser['username'],
    ]);

    return res;
  }

  /// Ritorna un utente dal [_database].
  Future<Map<String, dynamic>> getUser(String username) async {
    final db = await database;
    List<Map<String, dynamic>> res =
        await db.rawQuery("SELECT * FROM 'users' WHERE username = $username");

    if (res.isEmpty) {
      return null;
    } else {
      return res[0];
    }
  }

  /// Controlla se un utente esiste già nel [_database] grazie allo [username].
  Future<Map<String, dynamic>> checkExistUser(String username) async {
    final db = await database;
    List<Map<String, dynamic>> res = await db
        .rawQuery("SELECT username FROM 'users' WHERE username = $username");

    if (res.isEmpty) {
      return null;
    } else {
      return res[0];
    }
  }
}
