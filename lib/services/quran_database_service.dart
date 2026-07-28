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
    // منع الـ Race Condition عند طلب القاعدة في نفس اللحظة من أكثر من مكان
    _initDbFuture ??= _initDatabase();
    _database = await _initDbFuture;
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite غير مدعوم على الويب مباشرة بدون sqflite_common_ffi_web.');
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
        throw Exception('فشل نسخ قاعدة البيانات من assets: $e');
      }
    }

    return await openDatabase(dbPath, readOnly: true);
  }

  /// جلب السور (يدعم الويب بداتا وهمية متكاملة للـ 114 سورة)
  Future<List<Map<String, dynamic>>> getSurahs() async {
    if (kIsWeb) {
      return _mockSurahs;
    }

    final db = await database;
    return await db.rawQuery(
      'SELECT sora, sora_name_ar, '
      '(SELECT COUNT(*) FROM quran_index WHERE sora = qi.sora) as ayah_count '
      'FROM quran_index qi GROUP BY sora ORDER BY sora',
    );
  }

  /// جلب أرقام الصفحات بدقة
  Future<List<int>> getPages(
    int suraStart,
    int ayaStart,
    int suraEnd,
    int ayaEnd,
  ) async {
    if (kIsWeb) {
      return [1]; // قيمة افتراضية للويب
    }

    final db = await database;

    if (suraStart == suraEnd) {
      final result = await db.rawQuery('''
        SELECT DISTINCT page FROM quran_index
        WHERE sora = ? AND aya_no >= ? AND aya_no <= ?
        ORDER BY page
      ''', [suraStart, ayaStart, ayaEnd]);

      return result.map<int>((row) => row['page'] as int).toList();
    } else {
      // تصحيح الاستعلام والـ Parameters لتغطية كل السور الواقعة بين البداية والنهاية
      final result = await db.rawQuery('''
        SELECT DISTINCT page FROM quran_index
        WHERE 
          (sora = ? AND aya_no >= ?) OR
          (sora > ? AND sora < ?) OR
          (sora = ? AND aya_no <= ?)
        ORDER BY page
      ''', [
        suraStart, ayaStart, // للسورة الأولى
        suraStart, suraEnd,  // للسور السابقة بينهما
        suraEnd, ayaEnd      // للسورة الأخيرة
      ]);

      return result.map<int>((row) => row['page'] as int).toList();
    }
  }

  /// حساب عدد الصفحات الفعلي المضبوط
  Future<double> calculatePages(
    int suraStart,
    int ayaStart,
    int suraEnd,
    int ayaEnd,
  ) async {
    final pages = await getPages(suraStart, ayaStart, suraEnd, ayaEnd);
    if (pages.isEmpty) return 0.0;
    
    // حساب العدد الفعلي لعدد الصفحات الفريدة المسترجعة
    return pages.length.toDouble();
  }

  // قائمة السور الكاملة للـ Web Mock
  static const List<Map<String, dynamic>> _mockSurahs = [
    {'sora': 1, 'sora_name_ar': 'الفاتحة', 'ayah_count': 7},
    {'sora': 2, 'sora_name_ar': 'البقرة', 'ayah_count': 286},
    {'sora': 3, 'sora_name_ar': 'آل عمران', 'ayah_count': 200},
    {'sora': 4, 'sora_name_ar': 'النساء', 'ayah_count': 176},
    {'sora': 5, 'sora_name_ar': 'المائدة', 'ayah_count': 120},
    {'sora': 6, 'sora_name_ar': 'الأنعام', 'ayah_count': 165},
    {'sora': 7, 'sora_name_ar': 'الأعراف', 'ayah_count': 206},
    {'sora': 8, 'sora_name_ar': 'الأنفال', 'ayah_count': 75},
    {'sora': 9, 'sora_name_ar': 'التوبة', 'ayah_count': 129},
    {'sora': 10, 'sora_name_ar': 'يونس', 'ayah_count': 109},
    {'sora': 11, 'sora_name_ar': 'هود', 'ayah_count': 123},
    {'sora': 12, 'sora_name_ar': 'يوسف', 'ayah_count': 111},
    {'sora': 13, 'sora_name_ar': 'الرعد', 'ayah_count': 43},
    {'sora': 14, 'sora_name_ar': 'إبراهيم', 'ayah_count': 52},
    {'sora': 15, 'sora_name_ar': 'الحجر', 'ayah_count': 99},
    {'sora': 16, 'sora_name_ar': 'النحل', 'ayah_count': 128},
    {'sora': 17, 'sora_name_ar': 'الإسراء', 'ayah_count': 111},
    {'sora': 18, 'sora_name_ar': 'الكهف', 'ayah_count': 110},
    {'sora': 19, 'sora_name_ar': 'مريم', 'ayah_count': 98},
    {'sora': 20, 'sora_name_ar': 'طه', 'ayah_count': 135},
    {'sora': 21, 'sora_name_ar': 'الأنبياء', 'ayah_count': 112},
    {'sora': 22, 'sora_name_ar': 'الحج', 'ayah_count': 78},
    {'sora': 23, 'sora_name_ar': 'المؤمنون', 'ayah_count': 118},
    {'sora': 24, 'sora_name_ar': 'النور', 'ayah_count': 64},
    {'sora': 25, 'sora_name_ar': 'الفرقان', 'ayah_count': 77},
    {'sora': 26, 'sora_name_ar': 'الشعراء', 'ayah_count': 227},
    {'sora': 27, 'sora_name_ar': 'النمل', 'ayah_count': 93},
    {'sora': 28, 'sora_name_ar': 'القصص', 'ayah_count': 88},
    {'sora': 29, 'sora_name_ar': 'العنكبوت', 'ayah_count': 69},
    {'sora': 30, 'sora_name_ar': 'الروم', 'ayah_count': 60},
    {'sora': 31, 'sora_name_ar': 'لقمان', 'ayah_count': 34},
    {'sora': 32, 'sora_name_ar': 'السجدة', 'ayah_count': 30},
    {'sora': 33, 'sora_name_ar': 'الأحزاب', 'ayah_count': 73},
    {'sora': 34, 'sora_name_ar': 'سبأ', 'ayah_count': 54},
    {'sora': 35, 'sora_name_ar': 'فاطر', 'ayah_count': 45},
    {'sora': 36, 'sora_name_ar': 'يس', 'ayah_count': 83},
    {'sora': 37, 'sora_name_ar': 'الصافات', 'ayah_count': 182},
    {'sora': 38, 'sora_name_ar': 'ص', 'ayah_count': 88},
    {'sora': 39, 'sora_name_ar': 'الزمر', 'ayah_count': 75},
    {'sora': 40, 'sora_name_ar': 'غافر', 'ayah_count': 85},
    {'sora': 41, 'sora_name_ar': 'فصلت', 'ayah_count': 54},
    {'sora': 42, 'sora_name_ar': 'الشورى', 'ayah_count': 53},
    {'sora': 43, 'sora_name_ar': 'الزخرف', 'ayah_count': 89},
    {'sora': 44, 'sora_name_ar': 'الدخان', 'ayah_count': 59},
    {'sora': 45, 'sora_name_ar': 'الجاثية', 'ayah_count': 37},
    {'sora': 46, 'sora_name_ar': 'الأحقاف', 'ayah_count': 35},
    {'sora': 47, 'sora_name_ar': 'محمد', 'ayah_count': 38},
    {'sora': 48, 'sora_name_ar': 'الفتح', 'ayah_count': 29},
    {'sora': 49, 'sora_name_ar': 'الحجرات', 'ayah_count': 18},
    {'sora': 50, 'sora_name_ar': 'ق', 'ayah_count': 45},
    {'sora': 51, 'sora_name_ar': 'الذاريات', 'ayah_count': 60},
    {'sora': 52, 'sora_name_ar': 'الطور', 'ayah_count': 49},
    {'sora': 53, 'sora_name_ar': 'النجم', 'ayah_count': 62},
    {'sora': 54, 'sora_name_ar': 'القمر', 'ayah_count': 55},
    {'sora': 55, 'sora_name_ar': 'الرحمن', 'ayah_count': 78},
    {'sora': 56, 'sora_name_ar': 'الواقعة', 'ayah_count': 96},
    {'sora': 57, 'sora_name_ar': 'الحديد', 'ayah_count': 29},
    {'sora': 58, 'sora_name_ar': 'المجادلة', 'ayah_count': 22},
    {'sora': 59, 'sora_name_ar': 'الحشر', 'ayah_count': 24},
    {'sora': 60, 'sora_name_ar': 'الممتحنة', 'ayah_count': 13},
    {'sora': 61, 'sora_name_ar': 'الصف', 'ayah_count': 14},
    {'sora': 62, 'sora_name_ar': 'الجمعة', 'ayah_count': 11},
    {'sora': 63, 'sora_name_ar': 'المنافقون', 'ayah_count': 11},
    {'sora': 64, 'sora_name_ar': 'التغابن', 'ayah_count': 18},
    {'sora': 65, 'sora_name_ar': 'الطلاق', 'ayah_count': 12},
    {'sora': 66, 'sora_name_ar': 'التحريم', 'ayah_count': 12},
    {'sora': 67, 'sora_name_ar': 'الملك', 'ayah_count': 30},
    {'sora': 68, 'sora_name_ar': 'القلم', 'ayah_count': 52},
    {'sora': 69, 'sora_name_ar': 'الحاقة', 'ayah_count': 52},
    {'sora': 70, 'sora_name_ar': 'المعارج', 'ayah_count': 44},
    {'sora': 71, 'sora_name_ar': 'نوح', 'ayah_count': 28},
    {'sora': 72, 'sora_name_ar': 'الجن', 'ayah_count': 28},
    {'sora': 73, 'sora_name_ar': 'المزمل', 'ayah_count': 20},
    {'sora': 74, 'sora_name_ar': 'المدثر', 'ayah_count': 56},
    {'sora': 75, 'sora_name_ar': 'القيامة', 'ayah_count': 40},
    {'sora': 76, 'sora_name_ar': 'الإنسان', 'ayah_count': 31},
    {'sora': 77, 'sora_name_ar': 'المرسلات', 'ayah_count': 50},
    {'sora': 78, 'sora_name_ar': 'النبأ', 'ayah_count': 40},
    {'sora': 79, 'sora_name_ar': 'النازعات', 'ayah_count': 46},
    {'sora': 80, 'sora_name_ar': 'عبس', 'ayah_count': 42},
    {'sora': 81, 'sora_name_ar': 'التكوير', 'ayah_count': 29},
    {'sora': 82, 'sora_name_ar': 'الانفطار', 'ayah_count': 19},
    {'sora': 83, 'sora_name_ar': 'المطففين', 'ayah_count': 36},
    {'sora': 84, 'sora_name_ar': 'الانشقاق', 'ayah_count': 25},
    {'sora': 85, 'sora_name_ar': 'البروج', 'ayah_count': 22},
    {'sora': 86, 'sora_name_ar': 'الطارق', 'ayah_count': 17},
    {'sora': 87, 'sora_name_ar': 'الأعلى', 'ayah_count': 19},
    {'sora': 88, 'sora_name_ar': 'الغاشية', 'ayah_count': 26},
    {'sora': 89, 'sora_name_ar': 'الفجر', 'ayah_count': 30},
    {'sora': 90, 'sora_name_ar': 'البلد', 'ayah_count': 20},
    {'sora': 91, 'sora_name_ar': 'الشمس', 'ayah_count': 15},
    {'sora': 92, 'sora_name_ar': 'الليل', 'ayah_count': 21},
    {'sora': 93, 'sora_name_ar': 'الضحى', 'ayah_count': 11},
    {'sora': 94, 'sora_name_ar': 'الشرح', 'ayah_count': 8},
    {'sora': 95, 'sora_name_ar': 'التين', 'ayah_count': 8},
    {'sora': 96, 'sora_name_ar': 'العلق', 'ayah_count': 19},
    {'sora': 97, 'sora_name_ar': 'القدر', 'ayah_count': 5},
    {'sora': 98, 'sora_name_ar': 'البينة', 'ayah_count': 8},
    {'sora': 99, 'sora_name_ar': 'الزلزلة', 'ayah_count': 8},
    {'sora': 100, 'sora_name_ar': 'العاديات', 'ayah_count': 11},
    {'sora': 101, 'sora_name_ar': 'القارعة', 'ayah_count': 11},
    {'sora': 102, 'sora_name_ar': 'التكاثر', 'ayah_count': 8},
    {'sora': 103, 'sora_name_ar': 'العصر', 'ayah_count': 3},
    {'sora': 104, 'sora_name_ar': 'الهمزة', 'ayah_count': 9},
    {'sora': 105, 'sora_name_ar': 'الفيل', 'ayah_count': 5},
    {'sora': 106, 'sora_name_ar': 'قريش', 'ayah_count': 4},
    {'sora': 107, 'sora_name_ar': 'الماعون', 'ayah_count': 7},
    {'sora': 108, 'sora_name_ar': 'الكوثر', 'ayah_count': 3},
    {'sora': 109, 'sora_name_ar': 'الكافرون', 'ayah_count': 6},
    {'sora': 110, 'sora_name_ar': 'النصر', 'ayah_count': 3},
    {'sora': 111, 'sora_name_ar': 'المسد', 'ayah_count': 5},
    {'sora': 112, 'sora_name_ar': 'الإخلاص', 'ayah_count': 4},
    {'sora': 113, 'sora_name_ar': 'الفلق', 'ayah_count': 5},
    {'sora': 114, 'sora_name_ar': 'الناس', 'ayah_count': 6},
  ];
}