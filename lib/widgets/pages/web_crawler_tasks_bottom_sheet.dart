import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/data/types/web_crawler_tasks.dart';
import 'package:time_manager_client/data/types/web_crawler_web.dart';
import 'package:time_manager_client/helper/extension.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/pages/edit_task_page.dart';
import 'package:time_manager_client/pages/web_crawler_task_page.dart';
import 'package:time_manager_client/widgets/mindmap_painter.dart';
import 'package:time_manager_client/widgets/pages/multi_task_selector_bottom_sheet.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WebCrawlerTasksBottomSheet extends StatelessWidget {
  final WebCrawlerWeb web;
  final List<WebCrawlerTasks> wctasks;
  final Map<int, int> relvance;

  const WebCrawlerTasksBottomSheet(this.web, this.wctasks,
      {super.key, this.relvance = const {}});
  Future<Task?> show(BuildContext context) async =>
      Helper.showModalBottomSheetSimple<Task>(context, this);

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
        Text(web.name, style: Theme.of(context).textTheme.titleLarge),
        Text(web.summary, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          web.lastCrawl.formatWithPrecision(5),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
        ),
        Divider(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final wct in wctasks)
                  if (wct.tasks.isNotEmpty) ...buildWct(wct, context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildWct(WebCrawlerTasks wct, BuildContext context) {
    return [
      Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              wct.title,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (relvance.containsKey(wct.id)) buildRelvanceBox(relvance[wct.id]!),
          SizedBox(width: 4),
          InkWell(
            onTap: () => launchUrlString(wct.url),
            child: Icon(Icons.open_in_new_rounded, size: 16),
          ),
        ],
      ),
      if (wct.mindmap != null) buildMindmapOutline(wct),
      SizedBox(
        height: 96,
        child: Row(children: [
          Expanded(
            child: Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: Icon(Icons.task_alt_sharp),
                title: Text(
                    wct.tasks.isNotEmpty ? wct.tasks.first.title : "无任务",
                    maxLines: 1),
                subtitle: Text(
                    wct.tasks.isNotEmpty ? wct.tasks.first.summary ?? "" : "",
                    maxLines: 2),
                isThreeLine: true,
                onTap: () {
                  if (wct.tasks.isNotEmpty) {
                    Get.to(() => EditTaskPage(old: wct.tasks.first));
                  }
                },
              ),
            ),
          ),
          if (wct.tasks.length > 1)
            SizedBox(
              width: 96,
              height: 96,
              child: InkWell(
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: Center(
                      child: Text("+${wct.tasks.length - 1}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))),
                ),
                onTap: () => MultiTaskSelectorBottomSheet(
                        tasks: wct.tasks,
                        onSelected: (t) => Get.to(() => EditTaskPage(old: t)))
                    .show(context),
              ),
            )
        ]),
      ),
      // SizedBox(height: 1, child: DashedDivider()),
      SizedBox(height: 16),
    ];
  }

  Widget buildMindmapOutline(WebCrawlerTasks wct) {
    final (mot, mos) = wct.mindmapOutline;
    return LayoutBuilder(builder: (context, constraints) {
      return InkWell(
        onTap: () => Get.to(() => WebCrawlerTaskPage(wct: wct)),
        child: Container(
          width: constraints.maxWidth * 0.95,
          decoration: BoxDecoration(
            // color: Colors.grey.withAlpha(32),
            borderRadius: BorderRadius.circular(8),
          ),
          height: 144,
          child: MindmapPainter(mot, mos),
        ),
      );
    });
  }

  static const relvanceTexts = ["无", "极低", "低", "中", "高", "极高"];
  static const relvanceColors = [
    Colors.grey,
    Colors.lightGreen,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red
  ];
  Widget buildRelvanceBox(int relevance) => Container(
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: relevance == 0
              ? Colors.grey.withAlpha(32)
              : Colors.blue.withAlpha(32),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getRelevanceColor(relevance), width: 0.5),
        ),
        child: Text("关联性: ${_getRelevanceText(relevance)}",
            style:
                TextStyle(color: _getRelevanceColor(relevance), fontSize: 10)),
      );

  // 安全获取关联性文本
  String _getRelevanceText(int relevance) {
    if (relevance < 0 || relevance >= relvanceTexts.length) {
      return "未知";
    }
    return relvanceTexts[relevance];
  }

  // 安全获取关联性颜色
  Color _getRelevanceColor(int relevance) {
    if (relevance < 0 || relevance >= relvanceColors.length) {
      return Colors.grey;
    }
    return relvanceColors[relevance];
  }
}
