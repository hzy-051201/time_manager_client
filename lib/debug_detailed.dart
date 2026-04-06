import 'package:time_manager_client/data/repository/remote_db.dart';

void main() async {
  print('🔍 详细调试Flutter应用中的null值错误');
  print('=' * 60);

  try {
    // 初始化数据库连接
    await RemoteDb.instance.init();
    print('✅ 数据库初始化成功');

    // 测试获取爬虫配置
    print('\n1. 测试获取爬虫配置...');
    final webs = await RemoteDb.instance.getWebCrawlerWebs();
    print('   爬虫配置数量: ${webs.length}');

    // 测试获取爬虫任务
    if (webs.isNotEmpty) {
      print('\n2. 测试获取爬虫任务...');
      for (final web in webs) {
        print('   获取网站ID ${web.id} 的任务...');
        try {
          final tasks = await RemoteDb.instance.getWebCrawlerTasks(web.id);
          print('   任务数量: ${tasks.length}');

          for (final task in tasks) {
            print('     任务ID: ${task.id}, 标题: ${task.title}');

            // 测试任务列表
            print('     任务列表长度: ${task.tasks.length}');
            for (final subTask in task.tasks) {
              print('       子任务标题: ${subTask.title}');
              print('       子任务摘要: ${subTask.summary}');
            }

            // 测试思维导图属性
            print('     思维导图文本长度: ${task.mindmapText.length}');
            final outline = task.mindmapOutline;
            print('     思维导图大纲: ${outline.$1}');
          }
        } catch (e) {
          print('   ❌ 获取任务失败: $e');
          print('   🔍 错误堆栈:');
          print(e.toString());
        }
      }
    }
  } catch (e) {
    print('❌ 调试失败: $e');
    print('🔍 错误堆栈:');
    print(e.toString());
  }

  print('\n✅ 调试完成');
  print('=' * 60);
}
