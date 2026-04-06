import 'package:protobuf/protobuf.dart';
import 'package:time_manager_client/data/types/group.dart';
import 'package:time_manager_client/data/types/task.dart';

class TsData {
  int updateTimestampAt;
  TsData([int? timestamp]) : updateTimestampAt = timestamp ?? DateTime.now().millisecondsSinceEpoch;
  TsData.zero() : updateTimestampAt = 0;
  TsData.loading() : updateTimestampAt = -1;
  TsData.delete() : updateTimestampAt = 9007199254740991;
  // String toJsonString() => "";

  void updateTimestamp() {
    updateTimestampAt = DateTime.now().millisecondsSinceEpoch;
  }

  GeneratedMessage toProto() => throw UnimplementedError();
  factory TsData.fromProto(GeneratedMessage proto) => throw UnimplementedError();
  Map<String, dynamic> toMap() => throw UnimplementedError();
  bool get isDeleted => throw UnimplementedError();

  static T? fromMapNullable<T>(Map<String, dynamic>? map, [Type? t]) {
    if (T == Group || t is Group) return Group.fromMapNullable(map) as T?;
    if (T == Task || t is Task) return Task.fromMapNullable(map) as T?;
    throw Exception("Unknown type");
  }

  static String getTableName<T>() {
    if (T == Group) return 'groups';
    if (T == Task) return 'tasks';
    throw Exception("Unknown type: $T");
  }

  String get tableName => throw UnimplementedError();
}
