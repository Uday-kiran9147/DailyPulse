class MoodEntry {
  final int? id;
  final DateTime date;
  final String emoji;
  final String note;
  final int score;

  MoodEntry({
    this.id,
    required this.date,
    required this.emoji,
    required this.note,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'emoji': emoji,
      'note': note,
      'score': score,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    try {
      return MoodEntry(
        id: map['id'] as int?,
        date: DateTime.parse(map['date'] as String),
        emoji: map['emoji'] ?? '😐',
        note: map['note'] ?? '',
        score: map['score'] ?? 3,
      );
    } catch (_) {
      return MoodEntry(
        id: map['id'] as int?,
        date: DateTime.now(),
        emoji: '😐',
        note: '',
        score: 3,
      );
    }
  }

  MoodEntry copyWith({
    int? id,
    DateTime? date,
    String? emoji,
    String? note,
    int? score,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      score: score ?? this.score,
    );
  }
}
