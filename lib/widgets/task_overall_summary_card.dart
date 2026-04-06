import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/widgets/pages/view_task_widget.dart';

class TaskOverallSummaryCard extends StatefulWidget {
  const TaskOverallSummaryCard({super.key});

  @override
  State<TaskOverallSummaryCard> createState() => _TaskOverallSummaryCardState();
}

class _TaskOverallSummaryCardState extends State<TaskOverallSummaryCard> {
  List<(String, int?)> tip = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    DataController.to.getTaskOverallSummaryWithTask(false).then((r) {
      tip = r;
      if (mounted) setState(() {});
    });
  }

  late final _textColor = Theme.of(context).colorScheme.inversePrimary;
  @override
  Widget build(BuildContext context) {
    final ts = <InlineSpan>[];

    for (final e in tip) {
      if (e.$2 == null) {
        ts.add(TextSpan(text: e.$1));
      } else {
        void tap() {
          final t = DataController.to.rawTask[e.$2];
          if (t == null) return;
          ViewTaskWidget.show(context, t);
        }

        ts.add(TextSpan(text: " "));
        ts.add(
          WidgetSpan(
            child: InkWell(onTap: tap, child: Icon(Icons.task_alt, size: 16, color: _textColor)),
          ),
        );
        ts.add(TextSpan(
          text: e.$1,
          style: TextStyle(color: _textColor),
          recognizer: TapGestureRecognizer()..onTap = tap,
        ));
        ts.add(TextSpan(text: " "));
      }
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("小建议:"),
                IconButton(
                  onPressed: () {
                    if (loading) return;
                    loading = true;
                    setState(() {});
                    DataController.to.getTaskOverallSummaryWithTask(true).then((r) {
                      loading = false;
                      tip = r;
                      if (mounted) setState(() {});
                    });
                  },
                  icon: Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            if (loading)
              buildLoading()
            else
              SelectableText.rich(TextSpan(
                text: "　　",
                children: ts,
                style: Theme.of(context).textTheme.titleMedium,
              )),
          ],
        ),
      ),
    );
  }

  Widget buildLoading() => Column(
        children: [
          for (int i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsets.all(4),
              child: Helper.cardLoading(context: context, height: 24),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 100, 4),
            child: Helper.cardLoading(context: context, height: 24),
          ),
        ],
      );
}
