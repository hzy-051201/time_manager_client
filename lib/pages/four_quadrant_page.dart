import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/helper/extension.dart';
import 'package:time_manager_client/widgets/pages/view_task_widget.dart';

class FourQuadrantPage extends StatefulWidget {
  const FourQuadrantPage({super.key});

  @override
  State<FourQuadrantPage> createState() => _FourQuadrantPageState();
}

class _FourQuadrantPageState extends State<FourQuadrantPage> {
  late List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
  ].map((e) => _getColor(e)).toList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DataController>(
      builder: (s) {
        final tasks = s.currentGroupTasks;
        final fqts = _getTaskFourQuadrant(tasks);
        return Column(children: [
          Expanded(
              child: Row(children: [
            Expanded(child: buildTaskCard("重要且紧急", colors[1], fqts[1])),
            Expanded(child: buildTaskCard("不重要且紧急", colors[0], fqts[0])),
          ])),
          Expanded(
              child: Row(children: [
            Expanded(child: buildTaskCard("重要且不紧急", colors[3], fqts[3])),
            Expanded(child: buildTaskCard("不重要且不紧急", colors[2], fqts[2])),
          ])),
        ]);
      },
    );
  }

  Widget buildTaskCard(String name, Color color, List<Task> tasks) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: buildTasks(tasks),
            ),
          ],
        ),
      ),
    );
  }

  ListView buildTasks(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 24,
          child: InkWell(
            onTap: () {
              ViewTaskWidget.show(context, tasks[index]);
            },
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    DataController.to.changeTaskStatus(tasks[index]);
                    setState(() {});
                  },
                  child: IconTheme.merge(
                    data: IconThemeData(size: 18),
                    child: tasks[index].status.isFinished ? Icon(Icons.check_circle) : Icon(Icons.circle_outlined),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tasks[index].title,
                    overflow: TextOverflow.ellipsis,
                    style: tasks[index].status.isFinished
                        ? TextStyle(
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColor(Color c) => ColorScheme.fromSeed(seedColor: c, brightness: Get.isDarkMode ? Brightness.dark : Brightness.light).inversePrimary;
  bool _imp(Task t) => (t.importance ?? 0) >= 3;
  bool _urg(Task t) =>
      (t.endTime != null ? t.endTime!.difference(DateTime.now()).inDays <= 7 : false) ||
      (t.startTime != null ? t.startTime!.difference(DateTime.now()).inDays <= 7 : false);

  List<List<Task>> _getTaskFourQuadrant(Iterable<Task> tasks) {
    final now = DateTime.now();
    tasks = tasks.where((e) =>
        !(e.status == TaskStatus.finished && ((e.endTime != null && now.isDayAfter(e.endTime!)) || (e.startTime != null && now.isDayAfter(e.startTime!)))));
    List<List<Task>> ims = [[], []]; // 不重要，重要
    List<List<Task>> ius = [[], [], [], []]; // 不重要&紧急，重要&紧急，不重要&不紧急，重要&不紧急

    for (final t in tasks) {
      ims[_imp(t) ? 1 : 0].add(t);
    }

    for (int i = 0; i < 2; i++) {
      for (final t in ims[i]) {
        ius[i + (_urg(t) ? 0 : 2)].add(t);
      }
    }

    return ius;
  }
}
