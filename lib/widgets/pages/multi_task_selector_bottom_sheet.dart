import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/helper/helper.dart';

class MultiTaskSelectorBottomSheet extends StatelessWidget {
  const MultiTaskSelectorBottomSheet({super.key, required this.tasks, this.onSelected, this.title, this.subTitle, this.info});

  final String? title;
  final String? subTitle;
  final String? info;
  final List<Task> tasks;
  final void Function(Task)? onSelected;

  // static Future<Task?> show(BuildContext context, List<Task> tasks, {void Function(Task)? onSelected}) =>
  //     Helper.showModalBottomSheetWithTextField<Task>(context, MultiTaskSelectorBottomSheet(tasks: tasks, onSelected: onSelected));
  Future<Task?> show(BuildContext context) async => Helper.showModalBottomSheetSimple<Task>(context, this);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 32,
          child: Center(
            child: Container(
              width: 128,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(120),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (title != null) Text(title!, style: Theme.of(context).textTheme.titleLarge),
        if (subTitle != null) Text(subTitle!, style: Theme.of(context).textTheme.bodyMedium),
        if (info != null)
          Text(
            info!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          ),
        if (title != null || subTitle != null || info != null) Divider(),
        // Expanded(
        //     child: Column(
        //   mainAxisSize: MainAxisSize.min,
        // ))
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) => ListTile(
              leading: Text(
                (index + 1).toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              title: Text(tasks[index].title),
              subtitle: Text(tasks[index].summary ?? ""),
              onTap: () {
                if (onSelected == null) {
                  Get.back(result: tasks[index]);
                } else {
                  onSelected?.call(tasks[index]);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
