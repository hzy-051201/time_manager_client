import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/3rd/check_mark_indicator.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/repository/logger.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/widgets/task_overall_summary_card.dart';
import 'package:time_manager_client/widgets/task_statistics_summary_card.dart';
import 'package:time_manager_client/widgets/pages/view_task_widget.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final taskFinishedTextStyle = TextStyle(
    fontStyle: FontStyle.italic,
    decoration: TextDecoration.lineThrough,
    color: Colors.grey,
  );

  late final Widget _loading = ListTile(
    leading: IconButton(icon: Icon(Icons.circle, color: Colors.grey.withAlpha(40)), onPressed: () {}),
    // title: CardLoading(height: 20, width: 40, borderRadius: BorderRadius.circular(8)),
    title: Helper.cardLoading(context: context, height: 20, width: 40),
  );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DataController>(
      builder: (s) {
        final tasks = s.currentGroupTasks.toList();
        return CheckMarkIndicator(
          onRefresh: s.syncAll,
          child: Column(
            children: [
              SizedBox(
                height: 240,
                child: buildCard(),
              ),
              Expanded(
                child: ListView.separated(
                  reverse: true,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    if (task.isLoading) return _loading;

                    final textStyle = Helper.if_(task.status.isFinished, taskFinishedTextStyle);
                    return ListTile(
                      title: Text(tasks[index].title, style: textStyle),
                      subtitle: (task.summary?.isNotEmpty ?? false)
                          ? Text(
                              task.summary!,
                              style: textStyle,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        ViewTaskWidget.show(context, tasks[index]);
                      },
                      onLongPress: () {
                        logger.d("task: $task\n${DataController.to.getRawIndexNo(task)} ${task.isDeleted}");
                      },
                      leading: IconButton(
                        onPressed: () {
                          DataController.to.changeTaskStatus(tasks[index]);
                          setState(() {});
                        },
                        icon: task.status.isFinished ? Icon(Icons.check_circle) : Icon(Icons.circle_outlined),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 12);
                  },
                  itemCount: tasks.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 720) {
          return Swiper(
            itemBuilder: (BuildContext context, int index) => switch (index) {
              0 => TaskOverallSummaryCard(),
              1 => TaskStatisticsSummaryCard(),
              _ => Placeholder(),
            },
            itemCount: 2,
            pagination: SwiperPagination(),
          );
        } else {
          return ListView(
            scrollDirection: Axis.horizontal,
            children: [TaskOverallSummaryCard(), TaskStatisticsSummaryCard()].map((e) => SizedBox(width: 640, child: e)).toList(),
          );
        }
      },
    );
  }

  // Card buildCardSummary() => Card(
  //       child: Text("sss"),
  //     );
}
