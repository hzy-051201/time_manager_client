import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/repository/logger.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/helper/extension.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/pages/edit_task_page.dart';
import 'package:time_manager_client/widgets/link_text.dart';
import 'package:time_manager_client/widgets/pages/multi_task_selector_bottom_sheet.dart';
import 'package:time_manager_client/widgets/pages/simple_text_bottom_sheet.dart';

class ViewTaskWidget extends StatelessWidget {
  const ViewTaskWidget({super.key, required this.task});

  final Task task;

  static void show(BuildContext context, Task task) =>
      Helper.showModalBottomSheetWithTextField(
          context, ViewTaskWidget(task: task));

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.inversePrimary;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMain(context, iconColor),
          TextButton(
              onPressed: () {
                SimpleTextBottomSheet().show(context);
              },
              child: Text("识别不准确？点我反馈"))
        ],
      ),
    );
  }

  Padding _buildMain(BuildContext context, Color iconColor) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: null,
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.off(() => EditTaskPage(old: task));
                },
                icon: Icon(Icons.edit),
              ),
            ],
          ),

          if (task.summary != null) Text(task.summary!),
          if (task.content != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 32,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("原文"),
                          content: LinkText(task.content ?? "无"),
                        ),
                      );
                    },
                    child: Text(
                      "查看原文",
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodySmall?.fontSize),
                    ),
                  ),
                ),
              ],
            ),
          Divider(),
          // 日期和重要性
          Wrap(
            children: [
              if (task.startTime != null)
                InkWell(
                  onTap: task.onDateTimeClick,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.date_range, color: iconColor),
                      SizedBox(width: 8),
                      Text(task.startTimeWithPrecision),
                      if (task.endTime != null) Text(" ~ "),
                      if (task.endTime != null) Text(task.endTimeWithPrecision),
                      Icon(Icons.open_in_new_rounded,
                          size: 16, color: iconColor),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  task.importance ?? 0,
                  (_) => Icon(Icons.star_rounded, color: Colors.amber),
                ),
              ),
            ],
          ),
          // 标签 tags
          if (task.tags.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.tag_rounded, color: iconColor),
                SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 24,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final dti = Task.defaultTags.indexOf(task.tags[index]);
                        return InkWell(
                          onTap: () {
                            final t = task.tags[index];
                            final ts = DataController.to.tasks
                                .where((o) => o.tags.contains(t))
                                .toList();
                            MultiTaskSelectorBottomSheet(
                                    tasks: ts, title: "标签为 $t 的任务")
                                .show(context)
                                .then((tt) {
                              if (tt != null) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  ViewTaskWidget.show(context, tt);
                                });
                              }
                            });
                          },
                          child: Center(
                              child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (dti != -1)
                                Icon(Task.defaultTagIcons[dti], size: 12),
                              Text(task.tags[index]),
                            ],
                          )),
                        );
                      },
                      separatorBuilder: (context, index) => Text("、"),
                      itemCount: task.tags.length,
                    ),
                  ),
                ),
                // for (final t in task.tags)
                //   InkWell(
                //     onTap: () {
                //       final ts = DataController.to.tasks.where((o) => o.tags.contains(t)).toList();
                //       MultiTaskSelectorBottomSheet(tasks: ts, title: "标签为 $t 的任务").show(context).then((tt) {
                //         if (tt != null) {
                //           WidgetsBinding.instance.addPostFrameCallback((_) {
                //             ViewTaskWidget.show(context, tt);
                //           });
                //         }
                //       });
                //     },
                //     child: Text(t),
                //   )
              ],
            ),
          // 提醒
          if (task.noticeTimes.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications, color: iconColor),
                SizedBox(width: 8),
                Text(task.noticeTimes
                    .map((d) => d.formatWithPrecision(5))
                    .join(" ")),
              ],
            ),

          // 其他文本信息
          for (final pi in task.paramAndInfo().sublist(2))
            if (pi.$3?.isNotEmpty ?? false) buildInfoRow(task, pi, iconColor),
        ],
      ),
    );
  }

  Row buildInfoRow(Task task, (String, IconData, String?, void Function()?) pi,
      Color iconColor) {
    return Row(
      children: [
        Icon(pi.$2, color: iconColor),
        SizedBox(width: 8),
        if (pi.$4 == null)
          Expanded(child: Text(pi.$3!))
        else
          Expanded(
              child: InkWell(
            onTap: pi.$4,
            child: Row(children: [
              Text(pi.$3!),
              Icon(Icons.open_in_new_rounded, size: 16, color: iconColor),
              SizedBox(width: 16),
              if (pi.$1 == "地点")
                FutureBuilder(
                  future: DataController.to.getTaskDistance(task),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) logger.e(snapshot.error);
                      if (snapshot.data != null) {
                        return Text("${snapshot.data!.toStringAsFixed(1)}千米");
                      } else {
                        return SizedBox();
                      }
                    }
                    return Helper.cardLoading(
                        context: context, height: 24, width: 45);
                    // return Text("${}");
                  },
                )
            ]),
          ))
      ],
    );
  }
}
