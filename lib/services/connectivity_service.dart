import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _debounce;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((results) {
      // إلغاء المؤقت السابق
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        final hasConnection = results.any((r) => r != ConnectivityResult.none);
        _controller.add(hasConnection);
      });
    });
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _debounce?.cancel();
    _controller.close();
  }
}