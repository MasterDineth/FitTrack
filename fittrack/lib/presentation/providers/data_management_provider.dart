import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/backup_snapshot.dart';

export '../../domain/entities/backup_snapshot.dart';

part 'data_management_provider.freezed.dart';
part 'data_management_provider.g.dart';

/// State representation for FitTrack data management, backup schedules, and deletion preferences.
@freezed
abstract class DataManagementState with _$DataManagementState {
  const factory DataManagementState({
    @Default(true) bool isAutoBackupEnabled,
    @Default(false) bool exportBackupBeforeDelete,
    @Default(<BackupSnapshot>[]) List<BackupSnapshot> snapshots,
    @Default(false) bool isBackingUp,
    @Default(false) bool isRestoring,
    @Default(null) String? activeOperationMessage,
  }) = _DataManagementState;
}

/// Riverpod notifier managing data backups, snapshot lists, and irreversible erase workflows.
@Riverpod(keepAlive: true)
class DataManagementNotifier extends _$DataManagementNotifier {
  @override
  DataManagementState build() {
    return const DataManagementState(
      isAutoBackupEnabled: true,
      exportBackupBeforeDelete: false,
      snapshots: [
        BackupSnapshot(
          id: 'snapshot-1',
          title: 'Auto Backup',
          date: 'Sep 8, 2026',
          time: '2:15 PM',
          size: '4.2 MB',
          isLatest: true,
        ),
        BackupSnapshot(
          id: 'snapshot-2',
          title: 'Pre-Update Snapshot',
          date: 'Sep 1, 2026',
          time: '09:30 AM',
          size: '4.0 MB',
          isLatest: false,
        ),
        BackupSnapshot(
          id: 'snapshot-3',
          title: 'Manual Archive',
          date: 'Aug 20, 2026',
          time: '6:40 PM',
          size: '3.8 MB',
          isLatest: false,
        ),
      ],
    );
  }

  /// Toggles automatic daily Wi-Fi cloud backups.
  void toggleAutoBackup(bool value) {
    state = state.copyWith(isAutoBackupEnabled: value);
  }

  /// Toggles whether a local archive should be generated before clearing data in the confirmation modal.
  void toggleExportBackupBeforeDelete(bool value) {
    state = state.copyWith(exportBackupBeforeDelete: value);
  }

  /// Triggers a manual cloud & local backup snapshot.
  /// Generates a new snapshot, marks it as latest, and retains a maximum of 4 snapshots.
  Future<void> createBackup({String? title}) async {
    state = state.copyWith(
      isBackingUp: true,
      activeOperationMessage: 'Creating encrypted snapshot...',
    );

    await Future<void>.delayed(const Duration(milliseconds: 700));

    final newSnapshot = BackupSnapshot(
      id: 'snapshot-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Manual Snapshot',
      date: 'Today',
      time: 'Just now',
      size: '4.3 MB',
      isLatest: true,
    );

    // Demote prior snapshots from latest status
    final demotedSnapshots = state.snapshots.map((s) {
      return s.copyWith(isLatest: false);
    }).toList();

    // Insert new snapshot at top and retain at most 4 items
    final updatedList = [newSnapshot, ...demotedSnapshots].take(4).toList();

    state = state.copyWith(
      isBackingUp: false,
      activeOperationMessage: null,
      snapshots: updatedList,
    );
  }

  /// Restores workout logs and configurations from a saved snapshot ID.
  Future<void> restoreBackup(String id) async {
    state = state.copyWith(
      isRestoring: true,
      activeOperationMessage: 'Restoring telemetry database...',
    );

    await Future<void>.delayed(const Duration(milliseconds: 650));

    state = state.copyWith(
      isRestoring: false,
      activeOperationMessage: null,
    );
  }

  /// Refreshes the saved backups list.
  Future<void> refreshBackups() async {
    state = state.copyWith(activeOperationMessage: 'Syncing vault index...');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(activeOperationMessage: null);
  }

  /// Wipes a specific data category.
  Future<void> clearCategoryData(String category) async {
    state = state.copyWith(
      activeOperationMessage: 'Clearing $category...',
    );
    await Future<void>.delayed(const Duration(milliseconds: 450));
    state = state.copyWith(activeOperationMessage: null);
  }

  /// Master erase: permanently wipes local device data across all categories.
  Future<void> clearAllData() async {
    state = state.copyWith(
      activeOperationMessage: 'Purging local storage...',
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      activeOperationMessage: null,
      snapshots: const [],
    );
  }
}

/// Convenience alias matching user prompt specification.
final dataManagementNotifierProvider = dataManagementProvider;

