// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OutfitAdapter extends TypeAdapter<Outfit> {
  @override
  final int typeId = 1;

  @override
  Outfit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Outfit(
      id: fields[0] as String,
      itemIds: (fields[1] as List).cast<String>(),
      mood: fields[2] as String?,
      occasion: fields[3] as String?,
      selectedAt: fields[4] as DateTime?,
      liked: fields[5] as bool?,
      rating: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Outfit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemIds)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.occasion)
      ..writeByte(4)
      ..write(obj.selectedAt)
      ..writeByte(5)
      ..write(obj.liked)
      ..writeByte(6)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutfitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
