// import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';
// import '../models/mosque.dart';
// ...

class IsarService {
  /*
  static Isar? _isar;
  static Future<Isar> get isar async {
    if (_isar == null || !_isar!.isOpen) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open([ ... ], directory: dir.path);
    }
    return _isar!;
  }
  */

  static Future<dynamic> get isar async {
    // TODO: Isar frozen – dummy
    return null;
  }
}