// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 2;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      preferredMoods: (fields[0] as List).cast<String>(),
      preferredStyles: (fields[1] as List).cast<String>(),
      wearHistory: (fields[2] as List).cast<String>(),
      ratingHistory: (fields[3] as List).cast<Outfit>(),
      darkMode: fields[4] as bool,
      archivedOutfitIds:
          fields[5] == null ? [] : (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.preferredMoods)
      ..writeByte(1)
      ..write(obj.preferredStyles)
      ..writeByte(2)
      ..write(obj.wearHistory)
      ..writeByte(3)
      ..write(obj.ratingHistory)
      ..writeByte(4)
      ..write(obj.darkMode)
      ..writeByte(5)
      ..write(obj.archivedOutfitIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
