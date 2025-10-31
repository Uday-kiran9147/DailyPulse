import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../services/db_service.dart';

class MoodProvider with ChangeNotifier {
  List<MoodEntry> _entries = [];
  bool _isInitialized = false;

  List<MoodEntry> get entries => _entries;
  bool get isInitialized => _isInitialized;

  /// Initialize provider and load data from DB
  Future<void> init() async {
    try {
      _entries = await DBService.instance.fetchAll();
      if (_entries.isEmpty) {
        // Optional: Generate dummy data once for first-time app use
        await generateDummyData();
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('MoodProvider init() failed: $e');
    }
    notifyListeners();
  }

  /// Generates dummy data for testing and development for last 30 days
  Future<void> generateDummyData() async {
    final now = DateTime.now();
    final random = Random();
    final emojis = ['😄', '🙂', '😐', '😟', '😭'];

    for (int i = 0; i < 10; i++) {
      final date = now.subtract(Duration(days: i));
      final emoji = emojis[random.nextInt(emojis.length)];
      final score = emojis.indexOf(emoji) + 1;
      final note = 'This is a dummy entry for $emoji mood.';

      final entry = MoodEntry(
        date: date,
        emoji: emoji,
        score: score,
        note: note,
      );

      await addEntry(entry);
    }
  }

  /// Add or update a mood entry for the given day
  Future<void> addEntry(MoodEntry entry) async {
    try {
      final existingIndex = _entries.indexWhere(
        (e) =>
            e.date.year == entry.date.year &&
            e.date.month == entry.date.month &&
            e.date.day == entry.date.day,
      );

      if (existingIndex != -1) {
        // update existing
        final old = _entries[existingIndex];
        final updated = entry.copyWith(id: old.id);
        await DBService.instance.update(updated);
        _entries[existingIndex] = updated;
      } else {
        final inserted = await DBService.instance.insert(entry);
        if (inserted != null) _entries.insert(0, inserted);
      }
    } catch (e) {
      debugPrint('Error adding entry: $e');
    }
    notifyListeners();
  }

  /// Delete a mood entry
  Future<void> deleteEntry(int id) async {
    try {
      await DBService.instance.delete(id);
      _entries.removeWhere((e) => e.id == id);
    } catch (e) {
      debugPrint('Error deleting entry: $e');
    }
    notifyListeners();
  }

  /// Get entry for a specific date
  MoodEntry? entryForDate(DateTime date) {
    try {
      return _entries.firstWhere(
        (e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────── ANALYTICS ───────────────────────────
  int get totalEntries => _entries.length;
  int get positiveDays => _entries.where((e) => e.score >= 4).length;
  int get negativeDays => _entries.where((e) => e.score <= 2).length;

  String get mostCommonMood {
    if (_entries.isEmpty) return '—';
    final counts = <String, int>{};
    for (final e in _entries) {
      counts[e.emoji] = (counts[e.emoji] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  String get mostCommonMoodLabel {
    switch (mostCommonMood) {
      case '😄':
        return 'Joyful';
      case '🙂':
        return 'Good';
      case '😐':
        return 'Stressed';
      case '😟':
        return 'Sad';
      case '😭':
        return 'Very Sad';
      default:
        return '-';
    }
  }
}
