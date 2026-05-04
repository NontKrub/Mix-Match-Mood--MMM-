// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClothesAdapter extends TypeAdapter<Clothes> {
  @override
  final int typeId = 0;

  @override
  Clothes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Clothes(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      colors: (fields[3] as List).cast<String>(),
      styles: (fields[4] as List).cast<String>(),
      occasions: (fields[5] as List).cast<String>(),
      imagePath: fields[6] as String?,
      detectionConfidence: fields[7] as double?,
      createdAt: fields[8] as DateTime?,
      seasons: fields[9] == null
          ? ['all-season']
          : (fields[9] as List).cast<String>(),
      lastWorn: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Clothes obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.colors)
      ..writeByte(4)
      ..write(obj.styles)
      ..writeByte(5)
      ..write(obj.occasions)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.detectionConfidence)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.seasons)
      ..writeByte(10)
      ..write(obj.lastWorn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
