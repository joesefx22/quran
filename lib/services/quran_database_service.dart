import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class QuranDatabaseService {
  static final QuranDatabaseService _instance = QuranDatabaseService._internal();
  factory QuranDatabaseService() => _instance;
  QuranDatabaseService._internal();

  Database? _database;
  Future<Database>? _initDbFuture;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _initDbFuture ??= _initDatabase();
    _database = await _initDbFuture;
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite غير مدعوم على الويب مباشرة');
    }

    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'quran.db');

    final exists = await databaseExists(dbPath);
    if (!exists) {
      try {
        final data = await rootBundle.load('assets/quran.db');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await databaseFactory.writeDatabaseBytes(dbPath, Uint8List.fromList(bytes));
      } catch (e) {
        throw Exception('فشل نسخ قاعدة بيانات القرآن من assets: $e');
      }
    }

    return await openDatabase(dbPath, readOnly: true);
  }

  /// التحقق من جاهزية قاعدة البيانات قبل الاستخدام
  Future<bool> isDatabaseReady() async {
    try {
      await database;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getSurahs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT sora, sora_name_ar, COUNT(*) AS ayah_count
      FROM mytable
      GROUP BY sora
      ORDER BY sora
    ''');
  }

  Future<List<Map<String, dynamic>>> getAyahs(int surahId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT aya_no, page FROM mytable
      WHERE sora = ?
      ORDER BY aya_no
    ''', [surahId]);
  }

  Future<List<int>> getPages({
    required int suraStart,
    required int ayaStart,
    required int suraEnd,
    required int ayaEnd,
  }) async {
    final db = await database;

    if (suraStart == suraEnd) {
      final result = await db.rawQuery('''
        SELECT DISTINCT page FROM mytable
        WHERE sora = ? AND aya_no >= ? AND aya_no <= ?
        ORDER BY page
      ''', [suraStart, ayaStart, ayaEnd]);
      return result.map<int>((r) => r['page'] as int).toList();
    } else {
      final result = await db.rawQuery('''
        SELECT DISTINCT page FROM mytable
        WHERE
          (sora = ? AND aya_no >= ?)
          OR (sora > ? AND sora < ?)
          OR (sora = ? AND aya_no <= ?)
        ORDER BY page
      ''', [
        suraStart, ayaStart,
        suraStart, suraEnd,
        suraEnd, ayaEnd,
      ]);
      return result.map<int>((r) => r['page'] as int).toList();
    }
  }

  /// حساب عدد الصفحات مع معالجة الأخطاء – لا يرجع صفرًا بل يرمي استثناءً
  Future<double> calculatePages({
    required int suraStart,
    required int ayaStart,
    required int suraEnd,
    required int ayaEnd,
  }) async {
    try {
      final pages = await getPages(
        suraStart: suraStart,
        ayaStart: ayaStart,
        suraEnd: suraEnd,
        ayaEnd: ayaEnd,
      );
      return pages.length.toDouble();
    } catch (e) {
      throw Exception('قاعدة بيانات القرآن غير متاحة حالياً، تأكد من تثبيت التطبيق بشكل صحيح');
    }
  }
}