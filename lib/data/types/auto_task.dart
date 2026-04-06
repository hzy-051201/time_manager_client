import 'package:flutter/material.dart';
import 'package:time_manager_client/data/environment/constant.dart';
import 'package:time_manager_client/data/proto.gen/auto_task.pb.dart' as p;
import 'package:time_manager_client/helper/extension.dart';

class AutoTask {
  DateTime executeAt;
  String demand;
  bool executed;
  bool successed;
  String log;

  AutoTask(this.executeAt, this.demand,
      [this.executed = false, this.successed = false, this.log = ""]);

  factory AutoTask.fromMap(Map<String, dynamic> map) => AutoTask(
        DateTime.fromMillisecondsSinceEpoch(map["executeAt"]),
        map["demand"],
        map["executed"],
        map["successed"],
        map["log"],
      );

  static AutoTask? fromMapNullable(Map<String, dynamic>? map) => (map == null ||
          !map.containsKey("executeAt") ||
          !map.containsKey("demand"))
      ? null
      : AutoTask.fromMap(map);

  Map<String, dynamic> toMap() => {
        "executeAt": executeAt.millisecondsSinceEpoch,
        "demand": demand,
        "executed": executed,
        "successed": successed,
        "log": log,
      };

  p.AutoTask toProto() => p.AutoTask(
        executeAt: executeAt.millisecondsSinceEpoch.toInt64(),
        demand: demand,
        executed: executed,
        successed: successed,
        log: log,
      );

  AutoTask.fromProto(p.AutoTask t)
      : executeAt = DateTime.fromMillisecondsSinceEpoch(t.executeAt.toInt()),
        demand = t.demand,
        executed = t.executed,
        successed = t.successed,
        log = t.log;

  static String get prompt => "";

  AutoTaskState get state => executed
      ? successed
          ? AutoTaskState.done
          : AutoTaskState.fail
      : DateTime.now().difference(executeAt).inHours <= 1
          ? AutoTaskState.wait
          : AutoTaskState.loss;

  AutoTask copy() => AutoTask(executeAt, demand, executed, successed, log);

  bool get executable => DateTime.now().difference(executeAt).inHours <= 1;
  bool get shouldExecute =>
      executable && !executed && DateTime.now().isAfter(executeAt);
  @override
  String toString() =>
      "AutoTask(executeAt: $executeAt, demand: $demand, executed: $executed, successed: $successed, log: $log)";
  String get demandWithCaveat =>
      "$demand\n${Constant.aiSystemPromptForAutoTaskCaveat}";

  // static final RegExp winPathRegex = RegExp(r'[A-Z]:\$?:[^\\/:*?"<>|\r\n]+\$*[^\\/:*?"<>|\r\n]+');
  // static final RegExp unixPathRegex = RegExp(r'\/(?:[^\/\000-\037]+\/)*[^\/\000-\037]+');
  // static final RegExp networkPathRegex = RegExp(r'\\\$^\s\$+(?:\\[^\\/:*?"<>|\r\n]+)*');
  // static final List<RegExp> pathRegexList = [winPathRegex, unixPathRegex, networkPathRegex];
  static final RegExp pathRegex = RegExp(r"""
["']path["']: ["'](?<p>/.+\.[a-z0-9]+)["']
"""
      .trim());
  static const maxLogLength = 1024 * 8;

  Set<String> get filePathFromLog {
    Set<String> paths = {};
    final matches = pathRegex.allMatches(log);
    for (final match in matches) {
      paths.add(match.namedGroup("p")!);
    }
    return paths;
    // for (final regex in pathRegexList) {
    //   final matches = regex.allMatches(log);
    //   for (final match in matches) {
    //     paths.add(match.group(0)!);
    //   }
    // }
    // return paths;
  }
  // static String get prompt => Constant.aiSystemPromptForAutoTask.replaceFirst("###pwd###", "~/Desktop/自动执行/${DateTime.now().formatWithPrecision(5)}");
}

enum AutoTaskState {
  done(Icons.check_circle_outline, "执行成功", Colors.green),
  fail(Icons.cancel_outlined, "执行失败", Colors.red),
  wait(Icons.hourglass_bottom, "等待执行"),
  loss(Icons.block, "已丢弃"),

  running(Icons.smart_toy, "正在执行"),
  ;

  final IconData icon;
  final String text;
  final Color? color;

  const AutoTaskState(this.icon, this.text, [this.color]);

  @override
  String toString() => "AutoTaskState.$name";
}
