// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingSettingsAdapter extends TypeAdapter<ReadingSettings> {
  @override
  final int typeId = 1;

  @override
  ReadingSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingSettings(
      fontFamily: fields[0] as String,
      fontSize: fields[1] as double,
      lineSpacing: fields[2] as double,
      textAlignmentIndex: fields[3] as int,
      themeIndex: fields[4] as int,
      readingModeIndex: fields[5] as int,
      ttsRate: fields[6] as double,
      ttsVoice: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.fontFamily)
      ..writeByte(1)
      ..write(obj.fontSize)
      ..writeByte(2)
      ..write(obj.lineSpacing)
      ..writeByte(3)
      ..write(obj.textAlignmentIndex)
      ..writeByte(4)
      ..write(obj.themeIndex)
      ..writeByte(5)
      ..write(obj.readingModeIndex)
      ..writeByte(6)
      ..write(obj.ttsRate)
      ..writeByte(7)
      ..write(obj.ttsVoice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
