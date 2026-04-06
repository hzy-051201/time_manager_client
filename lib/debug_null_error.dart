import 'dart:io';
import 'package:time_manager_client/data/repository/remote_db.dart';
import 'package:time_manager_client/data/types/web_crawler_tasks.dart';
import 'package:time_manager_client/data/types/task.dart';

void main() async {
  final outputFile = File('debug_output.txt');
  final sink = outputFile.openWrite();

  sink.writeln('🔍 调试null值错误');
  sink.writeln('=' * 60);

  try {
    // 1. 初始化数据库
    sink.writeln('1. 初始化数据库...');
    await RemoteDb.instance.init();
    sink.writeln('   ✅ 数据库初始化成功');

    // 2. 获取爬虫配置
    sink.writeln('\n2. 获取爬虫配置...');
    final webs = await RemoteDb.instance.getWebCrawlerWebs();
    sink.writeln('   ✅ 爬虫配置数量: ${webs.length}');

    if (webs.isEmpty) {
      sink.writeln('   ⚠️  没有爬虫配置，跳过任务测试');
      await sink.close();
      print('✅ 调试完成，结果已保存到 debug_output.txt');
      return;
    }

    // 3. 测试每个网站的任务获取
    sink.writeln('\n3. 测试任务获取...');
    for (final web in webs) {
      sink.writeln('   网站ID ${web.id}: ${web.name}');

      try {
        // 关键测试：获取任务
        final tasks = await RemoteDb.instance.getWebCrawlerTasks(web.id);
        sink.writeln('     任务数量: ${tasks.length}');

        // 测试第一个任务的关键属性
        if (tasks.isNotEmpty) {
          final task = tasks.first;
          sink.writeln('     📝 测试第一个任务:');
          sink.writeln('        标题: "${task.title}"');
          sink.writeln('        URL: "${task.url}"');
          sink.writeln('        子任务数量: ${task.tasks.length}');

          // 测试子任务
          if (task.tasks.isNotEmpty) {
            final subTask = task.tasks.first;
            sink.writeln('        第一个子任务标题: "${subTask.title}"');
          }

          // 测试思维导图属性
          sink.writeln('        思维导图存在: ${task.mindmap != null}');
          sink.writeln('        思维导图文本长度: ${task.mindmapText.length}');
        }

        sink.writeln('     ✅ 任务获取成功');
      } catch (e) {
        sink.writeln('     ❌ 获取任务失败: $e');
        sink.writeln('     🔍 错误堆栈:');
        sink.writeln(e.toString());
      }
    }

    sink.writeln('\n✅ 所有测试通过');
  } catch (e) {
    sink.writeln('❌ 调试失败: $e');
    sink.writeln('🔍 错误堆栈:');
    sink.writeln(e.toString());
  }

  sink.writeln('\n' + '=' * 60);
  sink.writeln('调试完成');

  await sink.close();
  print('✅ 调试完成，结果已保存到 debug_output.txt');
}
