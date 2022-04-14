// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryHiveAdapter extends TypeAdapter<InventoryHive> {
  @override
  final int typeId = 1;

  @override
  InventoryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryHive(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      sku: fields[4] as String,
      upc: fields[3] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.upc)
      ..writeByte(4)
      ..write(obj.sku);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
