import '../services/quran_database_service.dart';

class QuranCalculation {
  final QuranDatabaseService _quranService;
  QuranCalculation(this._quranService);

  Future<double> pagesBetween(int suraStart, int ayaStart, int suraEnd, int ayaEnd) async {
    return await _quranService.calculatePages(suraStart: suraStart, ayaStart: ayaStart, suraEnd: suraEnd, ayaEnd: ayaEnd);
  }
}