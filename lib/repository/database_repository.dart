import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

// Repository สำหรับจัดการ SQLite มีฟังก์ชัน insert, query (get), และ delete ครบตามโจทย์
class DatabaseRepository {
  static Database? _database;

  // Getter สำหรับดึง Instance ของฐานข้อมูล (สร้างใหม่ถ้ายังไม่มี)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ฟังก์ชันสร้างไฟล์และตารางในฐานข้อมูล SQLite
  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // คำสั่ง SQL สร้างตาราง 'expenses' เมื่อเปิดแอปครั้งแรก
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // 1. ฟังก์ชัน insert: สำหรับเพิ่มข้อมูลใหม่ลงใน SQLite
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  // 2. ฟังก์ชัน get (query): ดึงข้อมูลทั้งหมดเรียงจากรายการล่าสุด (createdAt DESC) ตามโจทย์
  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'createdAt DESC', // โจทย์บังคับเรียงจากรายการล่าสุด
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // 3. ฟังก์ชัน delete: สำหรับลบข้อมูลออกจาก SQLite ตาม id
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}