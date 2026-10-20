import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/live_workout_snapshot.dart';

/// Persists the live [LiveWorkoutSnapshot] to SharedPreferences so a cold
/// restart can offer a "Resume workout?" sheet.
///
/// Key: `live_workout_snapshot_v1`
/// Retention: snapshots older than [maxAgeHours] are treated as stale.
class LiveSnapshotStore {
  static const _key = 'live_workout_snapshot_v1';
  static const int maxAgeHours = 12;

  final SharedPreferences _prefs;

  const LiveSnapshotStore(this._prefs);

  /// Write [snapshot] to SharedPreferences.
  Future<void> save(LiveWorkoutSnapshot snapshot) async {
    final json = jsonEncode(snapshot.toJson());
    await _prefs.setString(_key, json);
  }

  /// Read the stored snapshot, returning null if absent or stale.
  LiveWorkoutSnapshot? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final snapshot = LiveWorkoutSnapshot.fromJson(map);
      // Treat snapshots older than maxAgeHours as stale.
      final age = DateTime.now().difference(snapshot.updatedAt);
      if (age.inHours >= maxAgeHours) {
        _prefs.remove(_key);
        return null;
      }
      return snapshot;
    } catch (_) {
      _prefs.remove(_key);
      return null;
    }
  }

  /// Delete the stored snapshot (called on discard or finish).
  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  bool get hasSnapshot => _prefs.containsKey(_key);
}
