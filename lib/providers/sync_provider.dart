import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';

enum SyncStatus { idle, syncing, success, error }

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return SyncStatusNotifier(syncService);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivityService = ref.read(connectivityServiceProvider);
  return SyncService(connectivityService);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  final SyncService _syncService;

  SyncStatusNotifier(this._syncService) : super(SyncStatus.idle);

  Future<void> pullData() async {
    state = SyncStatus.syncing;
    try {
      await _syncService.pullAllData();
      state = SyncStatus.success;
    } catch (_) {
      state = SyncStatus.error;
    }
  }

  Future<void> pushSessions() async {
    state = SyncStatus.syncing;
    try {
      await _syncService.syncPendingSessions();
      state = SyncStatus.success;
    } catch (_) {
      state = SyncStatus.error;
    }
  }
}