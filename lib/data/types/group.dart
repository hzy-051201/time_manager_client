import 'package:time_manager_client/data/types/ts_data.dart';

import 'package:time_manager_client/data/proto.gen/group.pb.dart' as p;
import 'package:time_manager_client/helper/extension.dart';

class Group extends TsData {
  String title;
  String icon;
  List<int> taskIds;

  Group({
    required this.title,
    required this.icon,
    required this.taskIds,
    int? updateTimestamp,
  }) : super(updateTimestamp) {
    if (title.isEmpty) throw ArgumentError("title cannot be empty");
  }

  Group.title(this.title)
      : icon = "📂",
        taskIds = [];

  Group.delete()
      : title = "",
        icon = "",
        taskIds = const [],
        super.delete();

  String get iconAndTitle => "$icon $title";
  @override
  bool get isDeleted => title.isEmpty;

  @override
  String get tableName => "groups";

  @override
  String toString() => "Group($iconAndTitle, $taskIds)";

  @override
  p.Group toProto() => p.Group(
        title: title,
        icon: icon,
        taskIds: taskIds.map((e) => e.toInt64()),
        updateTimestampAt: updateTimestampAt.toInt64(),
      );

  factory Group.fromProto(p.Group g) {
    return Group(
      title: g.title,
      icon: g.icon,
      taskIds: g.taskIds.map((e) => e.toInt()).toList(),
      updateTimestamp: g.updateTimestampAt.toInt(),
    );
  }

  // Map
  @override
  Map<String, dynamic> toMap() => {
        "title": title,
        "icon": icon,
        "taskIds": taskIds,
      };

  Group.fromMap(Map<String, dynamic> map)
      : title = map["title"],
        icon = map["icon"],
        taskIds = map["taskIds"].cast<int>();

  static Group? fromMapNullable(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;
    return Group.fromMap(map);
  }
}
