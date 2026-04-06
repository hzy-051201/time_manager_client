import 'package:time_manager_client/data/environment/constant.dart';
import 'package:time_manager_client/data/types/task.dart';

class WebCrawlerTasks {
  final int id;
  final String title;
  final String url;
  final List<Task> tasks;
  final String? mindmap;

  const WebCrawlerTasks(this.id, this.title, this.url, this.tasks,
      [this.mindmap]);

  String get mindmapText {
    if (mindmap == null || mindmap!.isEmpty) {
      return Constant.mindmapWebCode.replaceFirst("###MINDMAP###", "暂无思维导图");
    }
    return Constant.mindmapWebCode.replaceFirst("###MINDMAP###", mindmap!);
  }

  (String, List<String>) get mindmapOutline {
    if (mindmap == null || mindmap!.isEmpty) {
      return ("暂无思维导图", []);
    }
    final lines = mindmap!.split("\n");
    if (lines.isEmpty) {
      return ("暂无思维导图", []);
    }

    // 安全检查防止索引越界
    String title = "暂无思维导图";
    if (lines.isNotEmpty && lines.first.length >= 2) {
      title = lines.first.substring(2);
    }

    return (
      title,
      lines
          .where((e) => e.startsWith("  - "))
          .map((e) => e.length >= 4 ? e.substring(4) : e)
          .toList()
    );
  }
}
