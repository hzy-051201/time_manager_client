import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/repository/logger.dart';
import 'package:time_manager_client/data/repository/network_ai.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/widgets/fullscreen_blur_dialog.dart';

class AiChatDialog extends StatefulWidget {
  const AiChatDialog({super.key});

  @override
  State<AiChatDialog> createState() => _AiChatDialogState();
}

class _AiChatDialogState extends State<AiChatDialog> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final DataController _controller;
  final List<ChatMessage> _messages = [];
  final List<ChatMessage> _conversationHistory = []; // 保存对话历史
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _controller = DataController.to;

    // 添加欢迎消息
    _addMessage(
      ChatMessage(
        text: '你好！我是Lia-cat,你的专属时间管理助手\n\n'
            '我可以帮你处理各种任务管理需求：\n'
            '✨ **添加任务**：直接告诉我，如"明天下午3点开会"、"下周去健身房"\n'
            '🔄 **重复任务**：说"每天下午三点打篮球"或"未来一周都要学习"，我会自动创建多个任务\n'
            '📋 **查看任务**：说"查看任务"或"今天有什么安排"\n'
            '✏️ **修改任务**：如"把会议改到明天上午"、"删除健身任务"\n'
            '🤔 **分析建议**：问"帮我分析一下今天的安排"\n\n'
            '支持自然语言，像跟朋友聊天一样跟我说就行！',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 添加用户消息到对话历史和显示
    final userMessage = ChatMessage(text: text, isUser: true);
    _addMessage(userMessage);
    _conversationHistory.add(userMessage);
    _messageController.clear();

    // 显示加载状态
    setState(() {
      _isLoading = true;
    });

    try {
      // 调用AI处理用户消息
      final response = await _processUserMessage(text);

      // 添加AI回复到对话历史和显示
      final aiMessage = ChatMessage(text: response, isUser: false);
      _addMessage(aiMessage);
      _conversationHistory.add(aiMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        text: '抱歉，处理您的请求时出现了错误：$e\n请稍后重试或尝试其他方式表达。',
        isUser: false,
      );
      _addMessage(errorMessage);
      _conversationHistory.add(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _processUserMessage(String userMessage) async {
    // 构建上下文信息，包含对话历史
    final tasks = _controller.tasks.toList();
    final currentTasks = tasks
        .where((t) => t.startTime?.isAfter(DateTime.now()) ?? false)
        .take(5)
        .toList();

    // 构建对话历史文本
    final historyText = _conversationHistory.isEmpty
        ? ''
        : '\n\n对话历史：\n${_conversationHistory.map((msg) => '${msg.isUser ? "用户" : "助手"}: ${msg.text}').join('\n')}';

    final contextInfo = '''当前日期时间：${DateTime.now().toIso8601String()}

用户当前任务列表（最近5个）：
${currentTasks.asMap().entries.map((e) => '${e.key + 1}. ${e.value.title}${e.value.startTime != null ? " (${e.value.startTimeWithPrecision})" : ""}').join('\n')}
$historyText

用户的最新请求：$userMessage
''';

    try {
      // 调用AI分析用户意图
      final analysis = await NetworkAi.askAi(
        contextInfo,
        '''你是一个智能时间管理助手，通过自然语言帮助用户高效管理任务。

你的核心能力：
1. 理解用户模糊、口语化的表达（如"明天晚上去健身房"、"下午三点开会"）
2. 智能提取任务信息（标题、时间、地点、标签等）
3. 根据上下文推断用户的真实意图
4. 提供个性化的任务建议和管理策略
5. 记住之前的对话，提供连贯的交互体验
6. 处理重复任务和长期任务

可执行的操作：
- add: 添加新任务（用户表达要"添加"、"新增"、"创建"、"安排"、"计划"等）
- delete: 删除任务（用户表达要"删除"、"取消"、"不要了"等）
- modify: 修改任务（用户表达要"改"、"改时间"、"换地点"等）
- list: 查看任务（用户表达要"查看"、"看看"、"有哪些"、"列表"等）
- summary: 分析总结（用户表达要"分析"、"总结"、"建议"等）

请严格按照以下JSON格式返回你的分析：
{
  "intent": "意图类型（add/delete/modify/list/summary/other）",
  "confidence": "置信度（high/medium/low）",
  "tasks": [
    {
      "title": "任务标题",
      "description": "任务描述（可选）",
      "startTime": "开始时间（ISO8601格式，如"2026-03-30T15:00:00"）",
      "endTime": "结束时间（ISO8601格式，可选）",
      "location": "地点（可选）",
      "tags": ["标签列表"],
      "importance": "重要程度（1-5，可选）"
    }
  ],
  "targetTaskId": "要操作的任务ID（用于delete/modify，可选）",
  "response": "给用户的友好回复文本，要简洁、自然、有温度"
}

重要规则：
1. 如果时间不明确，尽量根据上下文推断（如"下午三点"推断为今天15:00）
2. 如果用户只说"洗澡"，推断为"洗澡"，时间为当前时间后1小时
3. **重复任务处理**：
   - 如果用户说"每天下午三点打篮球"，返回7个任务（从今天开始，连续7天，每天15:00）
   - 如果用户说"未来一周都要学习"，返回7个任务（每天一个，时间默认为当前时间）
   - 如果用户说"下周一到周五都要开会"，返回5个任务（周一到周五各一个，使用具体日期）
   - 如果用户说"每周二、四都要健身"，返回未来4周的任务（每周二、四各一个）
   - 每个任务都要有具体的startTime（ISO8601格式，如"2026-03-30T15:00:00"）
   - 确保所有时间都是有效的DateTime格式，不能是相对时间
4. 如果用户表达不清楚，confidence设为low，在response中询问细节
5. response要像朋友对话一样自然，避免机械化的"已为您添加..."
6. 如果用户的请求超出任务管理范围，intent设为other，给出合适的回复
7. 利用对话历史理解用户的上下文（如用户先说"我要去健身房"，然后说"改成明天"，应该理解为把健身房任务改到明天）
8. 尽量使用中文输出
9. **时间格式示例**：
   - 今天下午3点：2026-03-30T15:00:00
   - 明天上午9点：2026-03-31T09:00:00
   - 下周一10点：计算下周一的日期，格式为2026-MM-DDT10:00:00''',
        AiModel.deepseekReason, // 使用推理模型获得更智能的响应
      );

      // 解析AI响应并执行操作
      return await _executeAiResponse(analysis ?? '', userMessage);
    } catch (e) {
      // 如果AI解析失败，尝试简单的关键词匹配
      return _handleSimpleMessage(userMessage);
    }
  }

  Future<String> _executeAiResponse(
      String aiResponse, String originalMessage) async {
    try {
      // 尝试提取JSON部分（可能包含在markdown代码块中）
      String jsonStr = aiResponse;

      // 移除markdown代码块标记
      if (aiResponse.contains('```json')) {
        final jsonStart = aiResponse.indexOf('```json') + 7;
        final jsonEnd = aiResponse.lastIndexOf('```');
        if (jsonEnd > jsonStart) {
          jsonStr = aiResponse.substring(jsonStart, jsonEnd).trim();
        }
      } else if (aiResponse.contains('```')) {
        final jsonStart = aiResponse.indexOf('```') + 3;
        final jsonEnd = aiResponse.lastIndexOf('```');
        if (jsonEnd > jsonStart) {
          jsonStr = aiResponse.substring(jsonStart, jsonEnd).trim();
        }
      } else {
        // 尝试找到第一个 { 和最后一个 }
        final jsonStart = aiResponse.indexOf('{');
        final jsonEnd = aiResponse.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          jsonStr = aiResponse.substring(jsonStart, jsonEnd + 1);
        }
      }

      if (jsonStr.isEmpty || !jsonStr.startsWith('{')) {
        // 没有找到有效的JSON，返回原始响应
        return aiResponse.isNotEmpty ? aiResponse : '好的，我来帮你处理这个请求。';
      }

      // 解析JSON
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final intent = data['intent'] as String?;
      final confidence = data['confidence'] as String?;
      final response = data['response'] as String?;
      final taskData = data['task'] as Map<String, dynamic>?; // 单个任务（兼容旧格式）
      final tasksData = data['tasks'] as List<dynamic>?; // 多个任务（新格式）

      // 根据intent执行相应的操作
      String operationResult = '';

      if (intent == 'add') {
        // 添加任务（支持单个或多个任务）
        if (tasksData != null && tasksData.isNotEmpty) {
          // 处理多个任务（重复任务）
          operationResult = await _executeAddMultipleTasks(
            tasksData.cast<Map<String, dynamic>>(),
          );
        } else if (taskData != null) {
          // 处理单个任务（向后兼容）
          operationResult = await _executeAddTask(taskData);
        } else {
          operationResult = '❌ 无法添加任务：任务信息缺失';
        }
      } else if (intent == 'delete') {
        // 删除任务
        final targetId = data['targetTaskId'] as String?;
        operationResult = await _executeDeleteTask(targetId);
      } else if (intent == 'list') {
        // 查看任务
        operationResult = _handleListTasks();
      } else if (intent == 'modify' && taskData != null) {
        // 修改任务
        final targetId = data['targetTaskId'] as String?;
        operationResult = await _executeModifyTask(targetId, taskData);
      } else if (intent == 'summary') {
        // 总结分析
        operationResult = await _executeSummary();
      } else if (intent == 'other') {
        // 其他请求
        operationResult = response ?? '我理解你的意思，但这超出了我的任务管理范围。不过我可以帮你管理任务！';
      }

      // 返回AI的回复或操作结果
      if (response != null &&
          response.isNotEmpty &&
          operationResult.isNotEmpty) {
        // 如果置信度较低，添加提示
        final confidenceWarning =
            confidence == 'low' ? '\n\n（我可能理解有误，如果不对请告诉我）' : '';
        return '$response\n\n$operationResult$confidenceWarning';
      } else if (response != null && response.isNotEmpty) {
        return response;
      } else if (operationResult.isNotEmpty) {
        return operationResult;
      }

      return aiResponse.isNotEmpty ? aiResponse : '好的，我来帮你处理这个请求。';
    } catch (e) {
      // JSON解析失败，回退到简单处理
      logger.e('JSON解析失败: $e');
      return _handleSimpleMessage(originalMessage);
    }
  }

  /// 执行添加多个任务操作（用于重复任务）
  Future<String> _executeAddMultipleTasks(
      List<Map<String, dynamic>> tasksData) async {
    if (tasksData.isEmpty) {
      return '❌ 无法添加任务：任务列表为空';
    }

    int successCount = 0;
    int failCount = 0;
    final List<String> failedTasks = [];

    for (final taskData in tasksData) {
      try {
        final result = await _executeAddTask(taskData);
        if (result.startsWith('✅')) {
          successCount++;
        } else {
          failCount++;
          failedTasks.add(taskData['title']?.toString() ?? '未知任务');
        }
      } catch (e) {
        failCount++;
        failedTasks.add(taskData['title']?.toString() ?? '未知任务');
        logger.e('添加任务失败: $e');
      }
    }

    // 生成结果消息
    if (failCount == 0) {
      return '✅ 成功添加了 $successCount 个任务！';
    } else if (successCount == 0) {
      return '❌ 添加任务失败，所有任务都无法创建。';
    } else {
      return '⚠️ 部分成功：成功添加 $successCount 个任务，失败 $failCount 个任务。\n'
          '失败的任务：${failedTasks.join(', ')}';
    }
  }

  /// 执行添加任务操作
  Future<String> _executeAddTask(Map<String, dynamic> taskData) async {
    try {
      final title = taskData['title'] as String?;
      if (title == null || title.isEmpty) {
        return '无法添加任务：任务标题为空';
      }

      final description = taskData['description'] as String? ?? '';
      final startTimeStr = taskData['startTime'] as String?;
      final endTimeStr = taskData['endTime'] as String?;
      final location = taskData['location'] as String?;
      final tags = (taskData['tags'] as List<dynamic>?)?.cast<String>() ?? [];

      // 解析时间
      DateTime? startTime;
      DateTime? endTime;

      if (startTimeStr != null && startTimeStr.isNotEmpty) {
        try {
          startTime = DateTime.parse(startTimeStr);
        } catch (e) {
          logger.e('解析开始时间失败: $e, 时间字符串: $startTimeStr');
          startTime = null;
        }
      }

      if (endTimeStr != null && endTimeStr.isNotEmpty) {
        try {
          endTime = DateTime.parse(endTimeStr);
        } catch (e) {
          logger.e('解析结束时间失败: $e, 时间字符串: $endTimeStr');
          endTime = null;
        }
      }

      // 创建任务
      final task = Task(
        title: title,
        content: description.isNotEmpty ? description : null,
        startTime: startTime,
        endTime: endTime,
        location: location,
        tags: tags,
      );

      // 添加到数据控制器
      _controller.addTask(task);

      return '✅ 成功添加任务：$title';
    } catch (e) {
      logger.e('添加任务异常: $e');
      return '❌ 添加任务失败：$e';
    }
  }

  /// 执行删除任务操作
  Future<String> _executeDeleteTask(String? targetId) async {
    if (targetId == null || targetId.isEmpty) {
      return '❌ 无法删除任务：未指定任务ID';
    }

    try {
      final id = int.tryParse(targetId);
      // 查找任务
      Task? taskToDelete;
      if (id != null && _controller.rawTask.containsKey(id)) {
        taskToDelete = _controller.rawTask[id];
      }

      if (taskToDelete == null) {
        return '❌ 无法删除任务：任务ID无效或不存在';
      }

      _controller.deleteTask(taskToDelete);

      return '✅ 成功删除任务：${taskToDelete.title}';
    } catch (e) {
      return '❌ 删除任务失败：$e';
    }
  }

  /// 执行修改任务操作
  Future<String> _executeModifyTask(
      String? targetId, Map<String, dynamic> taskData) async {
    if (targetId == null || targetId.isEmpty) {
      return '❌ 无法修改任务：未指定任务ID';
    }

    try {
      final id = int.tryParse(targetId);
      // 查找任务
      Task? oldTask;
      if (id != null && _controller.rawTask.containsKey(id)) {
        oldTask = _controller.rawTask[id];
      }

      if (oldTask == null) {
        return '❌ 无法修改任务：任务ID无效或不存在';
      }
      final title = taskData['title'] as String? ?? oldTask.title;
      final description = taskData['description'] as String?;
      final startTimeStr = taskData['startTime'] as String?;
      final endTimeStr = taskData['endTime'] as String?;
      final location = taskData['location'] as String?;
      final tags = (taskData['tags'] as List<dynamic>?)?.cast<String>();

      // 解析时间
      DateTime? startTime = oldTask.startTime;
      DateTime? endTime = oldTask.endTime;

      if (startTimeStr != null && startTimeStr.isNotEmpty) {
        try {
          startTime = DateTime.parse(startTimeStr);
        } catch (e) {
          // 保持原值
        }
      }

      if (endTimeStr != null && endTimeStr.isNotEmpty) {
        try {
          endTime = DateTime.parse(endTimeStr);
        } catch (e) {
          // 保持原值
        }
      }

      // 创建新任务
      final newTask = Task(
        title: title,
        content: description ?? oldTask.content,
        startTime: startTime,
        endTime: endTime,
        location: location ?? oldTask.location,
        tags: tags ?? oldTask.tags,
        status: oldTask.status,
      );

      // 更新任务
      _controller.editTask(oldTask, newTask);

      return '✅ 成功修改任务：$title';
    } catch (e) {
      return '❌ 修改任务失败：$e';
    }
  }

  /// 执行总结分析操作
  Future<String> _executeSummary() async {
    try {
      final summary = await _controller.getTaskOverallSummary(true);
      if (summary != null && summary.isNotEmpty) {
        return summary;
      }
      return '无法生成任务总结，请稍后再试。';
    } catch (e) {
      return '❌ 生成总结失败：$e';
    }
  }

  Future<String> _handleSimpleMessage(String message) async {
    final lowerMessage = message.toLowerCase();

    // 添加任务
    if (lowerMessage.contains('添加') ||
        lowerMessage.contains('新增') ||
        lowerMessage.contains('创建') ||
        lowerMessage.contains('安排') ||
        lowerMessage.contains('计划') ||
        lowerMessage.contains('add') ||
        lowerMessage.contains('create')) {
      return await _handleAddTask(message);
    }

    // 查看任务
    if (lowerMessage.contains('查看') ||
        lowerMessage.contains('列表') ||
        lowerMessage.contains('看看') ||
        lowerMessage.contains('有哪些') ||
        lowerMessage.contains('show') ||
        lowerMessage.contains('list')) {
      return _handleListTasks();
    }

    // 删除任务
    if (lowerMessage.contains('删除') ||
        lowerMessage.contains('移除') ||
        lowerMessage.contains('取消') ||
        lowerMessage.contains('delete') ||
        lowerMessage.contains('remove')) {
      return await _handleDeleteTask(message);
    }

    // 分析总结
    if (lowerMessage.contains('分析') ||
        lowerMessage.contains('总结') ||
        lowerMessage.contains('建议')) {
      return await _executeSummary();
    }

    // 默认回复
    return '我理解你想做什么，但让我再确认一下：\n\n'
        '📝 **添加任务**：说"添加 + 任务描述"，如"添加明天下午3点开会"\n'
        '📋 **查看任务**：说"查看任务"或"今天有什么安排"\n'
        '✏️ **修改任务**：说"修改 + 任务"，如"把会议改到明天"\n'
        '🗑️ **删除任务**：说"删除 + 任务"，如"删除健身任务"\n'
        '🤔 **分析建议**：问"帮我分析一下"\n\n'
        '你可以直接说"明天晚上去健身房"，我会帮你添加任务的！';
  }

  Future<String> _handleAddTask(String message) async {
    try {
      // 使用现有的AI文本解析功能
      final tasks = await _controller.getTaskFromText(message);

      if (tasks.isEmpty) {
        return '我没有从你的描述中识别出任务信息。可以再详细一点吗？\n'
            '例如："明天上午9点开会" 或 "下午3点去买 groceries"';
      }

      // 添加识别到的任务
      for (final task in tasks) {
        _controller.addTask(task);
      }

      final taskList = tasks.map((t) => '• ${t.title}').join('\n');
      return '太好了！我已经为你添加了以下任务：\n\n$taskList\n\n还有其他需要帮助的吗？';
    } catch (e) {
      return '添加任务时遇到了问题：$e\n请尝试用更清晰的方式描述任务。';
    }
  }

  String _handleListTasks() {
    final tasks = _controller.tasks.toList();

    if (tasks.isEmpty) {
      return '你目前还没有任何任务安排。\n\n想要添加一个新任务吗？只需告诉我："添加任务：[任务描述]"';
    }

    // 分类任务
    final today = DateTime.now();
    final todayTasks = tasks.where((t) {
      if (t.startTime == null) return false;
      final taskDate =
          DateTime(t.startTime!.year, t.startTime!.month, t.startTime!.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      return taskDate.isAtSameMomentAs(todayDate);
    }).toList();

    final futureTasks = tasks
        .where((t) => t.startTime != null && t.startTime!.isAfter(today))
        .toList();

    final overdueTasks = tasks
        .where((t) =>
            t.startTime != null &&
            t.startTime!.isBefore(today) &&
            t.status != TaskStatus.finished)
        .toList();

    final response = <String>[];

    if (todayTasks.isNotEmpty) {
      response.add('📅 **今天的任务** (${todayTasks.length}个)：');
      response.addAll(todayTasks.map((t) =>
          '  • ${t.title}${t.startTime != null ? " (${t.startTimeWithPrecision})" : ""}${t.status == TaskStatus.finished ? " ✓" : ""}'));
      response.add('');
    }

    if (overdueTasks.isNotEmpty) {
      response.add('⚠️ **已过期任务** (${overdueTasks.length}个)：');
      response.addAll(overdueTasks.map((t) =>
          '  • ${t.title}${t.startTime != null ? " (${t.startTimeWithPrecision})" : ""}'));
      response.add('');
    }

    if (futureTasks.isNotEmpty) {
      response.add('📆 **未来的任务** (${futureTasks.length}个)：');
      response.addAll(futureTasks.take(5).map((t) =>
          '  • ${t.title}${t.startTime != null ? " (${t.startTimeWithPrecision})" : ""}'));
      if (futureTasks.length > 5) {
        response.add('  • ... 还有 ${futureTasks.length - 5} 个任务');
      }
    }

    if (response.isEmpty) {
      return '你的任务列表为空。';
    }

    response.add('');
    response.add('总共有 ${tasks.length} 个任务。需要我帮你添加、删除或修改任务吗？');

    return response.join('\n');
  }

  Future<String> _handleDeleteTask(String message) async {
    // 简单实现：提示用户通过任务列表选择
    return '要删除任务，请告诉我你要删除哪个任务。\n\n'
        '你可以：\n'
        '1. 说"查看任务"先查看任务列表\n'
        '2. 然后说"删除第N个任务"\n'
        '3. 或者直接说任务标题，如"删除会议"';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    return FullscreenBlurDialog(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withAlpha(180),
                    Colors.pink.withAlpha(180),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // 猫咪图标
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/img/cat.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lia-cat',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '专属时间管理助手',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // 消息列表
            Expanded(
              child: Column(
                children: [
                  // 快捷操作按钮
                  if (_messages.length <= 1) // 只在第一次对话时显示
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _QuickActionButton(
                            icon: Icons.add_task,
                            label: '添加任务',
                            onTap: () => _handleUserMessage('添加一个新任务'),
                          ),
                          _QuickActionButton(
                            icon: Icons.list_alt,
                            label: '查看任务',
                            onTap: () => _handleUserMessage('查看我的任务'),
                          ),
                          _QuickActionButton(
                            icon: Icons.analytics,
                            label: '分析安排',
                            onTap: () => _handleUserMessage('帮我分析一下今天的安排'),
                          ),
                          _QuickActionButton(
                            icon: Icons.lightbulb,
                            label: '提供建议',
                            onTap: () => _handleUserMessage('给我一些时间管理的建议'),
                          ),
                        ],
                      ),
                    ),
                  // 消息列表
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < _messages.length) {
                            return _MessageBubble(
                              message: _messages[index],
                              textTheme: textTheme,
                            );
                          } else {
                            // 加载指示器
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    '正在思考...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 输入区域
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withAlpha(32),
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(16),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withAlpha(32),
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '输入你的需求...',
                            hintStyle: TextStyle(
                              color: Colors.white.withAlpha(128),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _handleUserMessage,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple,
                            Colors.pink,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _handleUserMessage(
                          _messageController.text,
                        ),
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final TextTheme textTheme;

  const _MessageBubble({
    required this.message,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/img/cat.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.purple.withAlpha(180)
                    : Colors.white.withAlpha(16),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft:
                      message.isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight:
                      message.isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white70, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withAlpha(32),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
