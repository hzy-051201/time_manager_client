import 'dart:io';

void main() async {
  final outputFile = File('debug_pure_dart.txt');
  final sink = outputFile.openWrite();

  sink.writeln('🔍 纯Dart调试脚本 - 测试null值错误');
  sink.writeln('=' * 60);
  sink.writeln('创建时间: ${DateTime.now()}');

  try {
    // 测试基本Dart功能
    sink.writeln('\n1. 测试基本Dart功能...');

    // 测试字符串操作
    String title = '测试标题';
    sink.writeln('   字符串操作: OK');
    sink.writeln('   标题: "$title"');
    sink.writeln('   标题长度: ${title.length}');

    // 测试null值处理
    sink.writeln('\n2. 测试null值处理...');
    String? nullableTitle = null;
    String safeTitle = nullableTitle ?? '默认标题';
    sink.writeln('   Nullable标题: $nullableTitle');
    sink.writeln('   安全标题: "$safeTitle"');

    // 测试列表操作
    sink.writeln('\n3. 测试列表操作...');
    List<String> tasks = ['任务1', '任务2', '任务3'];
    sink.writeln('   任务数量: ${tasks.length}');
    for (int i = 0; i < tasks.length; i++) {
      sink.writeln('     任务${i + 1}: "${tasks[i]}"');
    }

    // 测试Map操作（模拟数据库数据）
    sink.writeln('\n4. 测试Map操作（模拟数据库数据）...');
    Map<String, dynamic> mockTaskData = {
      'id': 1,
      'title': '关于2026年全国高校英语专业八级考试安排的通知',
      'url': 'https://jwc.njtech.edu.cn/info/1157/6598.htm',
      'tasks': [
        {
          'title': '考试时间安排',
          'summary': '2026年3月21日上午08:30-11:00',
          'startTime': 1234567890,
          'importance': 3
        }
      ],
      'mindmap': '- 关于2026年全国高校英语专业八级考试安排的通知'
    };

    sink.writeln('   模拟任务数据:');
    sink.writeln('     ID: ${mockTaskData['id']}');
    sink.writeln('     标题: "${mockTaskData['title']}"');
    sink.writeln('     URL: "${mockTaskData['url']}"');

    // 测试null值处理
    String? testTitle = mockTaskData['title'] as String?;
    String safeTestTitle = testTitle ?? '无标题';
    sink.writeln('     安全标题处理: "$safeTestTitle"');

    // 测试嵌套数据
    List<dynamic>? testTasks = mockTaskData['tasks'] as List<dynamic>?;
    if (testTasks != null && testTasks.isNotEmpty) {
      Map<String, dynamic> firstTask = testTasks.first as Map<String, dynamic>;
      String? taskTitle = firstTask['title'] as String?;
      String safeTaskTitle = taskTitle ?? '无任务标题';
      sink.writeln('     第一个子任务标题: "$safeTaskTitle"');
    }

    sink.writeln('\n✅ 所有Dart功能测试通过');
  } catch (e) {
    sink.writeln('❌ 调试失败: $e');
    sink.writeln('🔍 错误堆栈:');
    sink.writeln(e.toString());
  }

  sink.writeln('\n' + '=' * 60);
  sink.writeln('调试完成');

  await sink.close();
  print('✅ 纯Dart调试完成，结果已保存到 debug_pure_dart.txt');
  print('📋 这个脚本测试了Dart的基本功能，不依赖Flutter');
}
