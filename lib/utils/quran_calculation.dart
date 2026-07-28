import '../services/quran_service.dart';

class QuranCalculation {
  final QuranService _quranService;

  QuranCalculation(this._quranService);

  /// حساب عدد الصفحات من آية لأخرى
  Future<double> pagesBetween(int suraStart, int ayaStart, int suraEnd, int ayaEnd) async {
    return await _quranService.calculatePages(suraStart, ayaStart, suraEnd, ayaEnd);
  }

  // دوال حساب النقاط يمكن استدعاؤها من SessionService، لذا هي موجودة هناك.
}