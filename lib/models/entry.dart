import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 0)
class Entry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String title;

  @HiveField(3)
  String audioPath;

  @HiveField(4)
  String rawTranscript;

  @HiveField(5)
  String polishedNote;

  @HiveField(6)
  bool isSynced;

  @HiveField(7)
  int durationSeconds;

  @HiveField(8)
  String category;

  @HiveField(9)
  bool isFavorite;

  @HiveField(10)
  bool isPinned;

  @HiveField(11)
  List<String> tags;

  @HiveField(12)
  List<String> imageUrls;

  Entry({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.audioPath,
    this.rawTranscript = '',
    this.polishedNote = '',
    this.isSynced = false,
    this.durationSeconds = 0,
    this.category = 'Note',
    this.isFavorite = false,
    this.isPinned = false,
    this.tags = const [],
    this.imageUrls = const [],
  });

  Entry copyWith({
    String? id,
    DateTime? timestamp,
    String? title,
    String? audioPath,
    String? rawTranscript,
    String? polishedNote,
    bool? isSynced,
    int? durationSeconds,
    String? category,
    bool? isFavorite,
    bool? isPinned,
    List<String>? tags,
    List<String>? imageUrls,
  }) {
    return Entry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      audioPath: audioPath ?? this.audioPath,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      polishedNote: polishedNote ?? this.polishedNote,
      isSynced: isSynced ?? this.isSynced,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'audioPath': audioPath,
      'rawTranscript': rawTranscript,
      'polishedNote': polishedNote,
      'isSynced': isSynced,
      'durationSeconds': durationSeconds,
      'category': category,
      'isFavorite': isFavorite,
      'isPinned': isPinned,
      'tags': tags,
      'imageUrls': imageUrls,
    };
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String,
      audioPath: json['audioPath'] as String,
      rawTranscript: json['rawTranscript'] as String? ?? '',
      polishedNote: json['polishedNote'] as String? ?? '',
      isSynced: json['isSynced'] as bool? ?? false,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      category: json['category'] as String? ?? 'Note',
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}
