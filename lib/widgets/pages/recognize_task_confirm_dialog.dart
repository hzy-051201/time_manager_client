import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/pages/edit_task_page.dart';

class RecognizeTaskConfirmDialog extends StatelessWidget {
  final Task task;
  const RecognizeTaskConfirmDialog(this.task, {super.key});

  void show(BuildContext context) => showDialog(context: context, builder: (context) => this);

  @override
  Widget build(BuildContext context) {
    final labelTextTheme = Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.grey);
    final contentTextTheme = Theme.of(context).textTheme.titleMedium;

    final content = [
      ("概述", task.summary),
      ("时间", task.timeString),
      ("地点", task.location),
    ];

    return AlertDialog(
      title: Text(task.title),
      content: RichText(
          text: TextSpan(children: [
        for (final e in content)
          if (e.$2 != null && e.$2!.isNotEmpty)
            TextSpan(text: "${e.$1}: ", style: labelTextTheme, children: [
              TextSpan(text: "${e.$2}\n", style: contentTextTheme),
            ]),
      ])),
      actions: [
        TextButton(
            onPressed: () {
              Get.replace(() => EditTaskPage(old: task));
            },
            child: Text("编辑")),
        ElevatedButton(
            onPressed: () {
              DataController.to.addTask(task);
              Get.back();
            },
            child: Text("完成")),
      ],
      actionsAlignment: MainAxisAlignment.spaceEvenly,
    );
  }
}
