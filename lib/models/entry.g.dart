// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntryAdapter extends TypeAdapter<Entry> {
  @override
  final int typeId = 0;

  @override
  Entry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Entry(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      title: fields[2] as String,
      audioPath: fields[3] as String,
      rawTranscript: fields[4] as String,
      polishedNote: fields[5] as String,
      isSynced: fields[6] as bool,
      durationSeconds: fields[7] as int,
      category: fields[8] as String,
      isFavorite: fields[9] as bool,
      isPinned: fields[10] as bool,
      tags: (fields[11] as List).cast<String>(),
      imageUrls: (fields[12] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Entry obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.audioPath)
      ..writeByte(4)
      ..write(obj.rawTranscript)
      ..writeByte(5)
      ..write(obj.polishedNote)
      ..writeByte(6)
      ..write(obj.isSynced)
      ..writeByte(7)
      ..write(obj.durationSeconds)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.isFavorite)
      ..writeByte(10)
      ..write(obj.isPinned)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.imageUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
