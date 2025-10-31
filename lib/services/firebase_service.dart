import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';

/// Firestore service for syncing mood entries
class FirestoreService {
  static final FirestoreService instance = FirestoreService._();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  FirestoreService._();

  /// Returns the Firestore collection reference for current user moods
  CollectionReference<Map<String, dynamic>> get _moodsCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not authenticated.");
    }
    return _firestore.collection('users').doc(uid).collection('moods');
  }

  /// Upload or update a mood entry in Firestore
  Future<void> saveMood(MoodEntry entry) async {
    try {
      final docId = _formatDate(entry.date);
      await _moodsCollection.doc(docId).set({
        'date': entry.date.toIso8601String(),
        'emoji': entry.emoji,
        'note': entry.note,
        'score': entry.score,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('🔥 Firestore Save Error: $e');
      rethrow;
    }
  }

  /// Fetch all moods for the current user (sorted by date DESC)
  Future<List<MoodEntry>> fetchAll() async {
    try {
      final snapshot = await _moodsCollection.orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MoodEntry(
          id: doc.id.hashCode,
          date: DateTime.parse(data['date']),
          emoji: data['emoji'],
          note: data['note'],
          score: data['score'],
        );
      }).toList();
    } catch (e) {
      print('🔥 Firestore Fetch Error: $e');
      return [];
    }
  }

  /// Delete a mood by date (document ID)
  Future<void> deleteMood(DateTime date) async {
    try {
      final docId = _formatDate(date);
      await _moodsCollection.doc(docId).delete();
    } catch (e) {
      print('🔥 Firestore Delete Error: $e');
    }
  }

  /// Sync local data (sqflite) → Firestore
  Future<void> syncLocalToCloud(List<MoodEntry> localEntries) async {
    try {
      final batch = _firestore.batch();
      for (final entry in localEntries) {
        final docRef = _moodsCollection.doc(_formatDate(entry.date));
        batch.set(docRef, {
          'date': entry.date.toIso8601String(),
          'emoji': entry.emoji,
          'note': entry.note,
          'score': entry.score,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
      print("✅ Synced ${localEntries.length} entries to Firestore.");
    } catch (e) {
      print('🔥 Firestore Sync Error: $e');
    }
  }

  /// Sync Firestore → local DB
  Future<List<MoodEntry>> syncCloudToLocal() async {
    try {
      final snapshot = await _moodsCollection.orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MoodEntry(
          id: doc.id.hashCode,
          date: DateTime.parse(data['date']),
          emoji: data['emoji'],
          note: data['note'],
          score: data['score'],
        );
      }).toList();
    } catch (e) {
      print('🔥 Firestore Cloud→Local Sync Error: $e');
      return [];
    }
  }

  /// Format date for document ID
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
