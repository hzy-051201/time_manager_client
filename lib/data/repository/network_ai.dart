import 'package:openai_dart/openai_dart.dart';
import 'package:time_manager_client/data/environment/constant.dart';
import 'package:time_manager_client/data/environment/env.dart';
import 'package:time_manager_client/data/repository/logger.dart';
import 'package:time_manager_client/data/types/auto_task.dart';
import 'package:time_manager_client/data/types/task.dart';

class NetworkAi {
  static const String aiApiKey = Env.dsApiKey;
  static const String aiBasicUrl = "https://dashscope.aliyuncs.com/compatible-mode/v1";

  static final aiClient = OpenAIClient(apiKey: aiApiKey, baseUrl: aiBasicUrl);

  static Future<String?> askAi(String text, String systemPrompt, AiModel model) async {
    logger.t("SEND TEXT TO AI");
    final cccr = await aiClient.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(model.id),
        messages: [
          ChatCompletionMessage.system(content: systemPrompt),
          ChatCompletionMessage.user(content: ChatCompletionUserMessageContent.string(text)),
        ],
        stream: false,
        temperature: 0.7,
        // maxTokens: 1024,
      ),
    );

    var r = cccr.choices.first.message.content;
    logger.t(r);
    return r;
  }

  static Future<List<Task>> getTaskFromText(
    String text, {
    String systemPrompt = Constant.aiSystemPromptForAddTask,
    AiModel model = AiModel.deepseekChat,
  }) async {
    var r = await askAi(text, systemPrompt, model);
    if (r == null) return [];

    r = r.replaceAll("```json", "").replaceAll("```", "").trim();

    final tl = Task.fromAiJsonString(r);
    for (final element in tl) {
      element.content = text;
    }
    logger.t(tl);

    return tl;
  }

  static Future<AutoTask?> getAutoTaskFromText(String text, DateTime executeAt) async {
    final r = await askAi(text, AutoTask.prompt, AiModel.deepseekChat);
    if (r == null || r.contains("无法自动完成")) return null;
    return AutoTask(executeAt, r);
  }

  static Future<String?> getTaskOverallSummary(Map<int, Task> tasks) async {
    var q = "现在是${DateTime.now().toString()}, 我有如下任务: \n\n";
    for (final i in tasks.keys) {
      q += "[$i]: ${tasks[i]!.title}\n";
      if (tasks[i]?.summary != null) q += "概括: ${tasks[i]!.summary}\n";
      if (tasks[i]?.importance != null) q += "重要程度: ${tasks[i]!.importance}/5\n";
      if (tasks[i]?.startTime != null) q += "开始时间: ${tasks[i]!.startTimeWithPrecision}\n";
      if (tasks[i]?.endTime != null) q += "结束时间: ${tasks[i]!.endTimeWithPrecision}\n";
      if (tasks[i]?.location != null) q += "地点: ${tasks[i]!.location}\n";
      q += "\n";
    }
    return await askAi(q, Constant.aiSystemPromptForAnalyzeTasks, AiModel.deepseekChat);
    // var r = await askAi(text, systemPrompt, modelId)
  }
}

enum AiModel {
  deepseekChat("标准", "deepseek-v3"),
  deepseekReason("推理", "deepseek-r1"),
  ;

  final String name;
  final String id;

  const AiModel(this.name, this.id);

  @override
  String toString() => name;
}
