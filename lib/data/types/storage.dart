import 'package:time_manager_client/data/types/user.dart';
import 'package:time_manager_client/data/types/group.dart';
import 'package:time_manager_client/data/types/task.dart';

class Storage {
  final Map<int, Group> groups;
  final Map<int, Task> tasks;
  final List<int> groupIds;
  final int currentGroup;
  final User? user;

  Storage({
    required this.groups,
    required this.tasks,
    required this.groupIds,
    required this.currentGroup,
    this.user,
  });
}
