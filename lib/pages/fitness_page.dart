import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/environment/constant.dart';
import 'package:time_manager_client/data/repository/logger.dart';
import 'package:time_manager_client/data/repository/network_ai.dart';
import 'package:time_manager_client/data/types/task.dart';

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key});

  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  // 表单控制器
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();

  // 偏好运动类型
  final List<String> _exerciseTypes = [
    '跑步',
    '游泳',
    '瑜伽',
    '力量训练',
    '骑行',
    '健身操',
    '普拉提',
    '羽毛球',
    '篮球',
    '乒乓球',
  ];
  String? _selectedExerciseType;

  // 生成的健身计划
  List<Task> _generatedPlan = [];
  bool _isGenerating = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  // 生成健身计划
  Future<void> _generateFitnessPlan() async {
    // 验证输入
    if (_heightController.text.isEmpty) {
      Get.snackbar('提示', '请输入身高');
      return;
    }
    if (_weightController.text.isEmpty) {
      Get.snackbar('提示', '请输入体重');
      return;
    }
    if (_selectedExerciseType == null) {
      Get.snackbar('提示', '请选择偏好运动');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // 构建提示词
      final height = double.tryParse(_heightController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0;
      final bmi = weight / ((height / 100) * (height / 100));

      // 获取当前时间
      final now = DateTime.now();
      final today = now.toIso8601String().split('T')[0]; // YYYY-MM-DD

      final prompt = '''请为我制定一个健身计划。

当前时间：${now.toIso8601String()}

用户信息：
- 身高：${height}cm
- 体重：${weight}kg
- BMI：${bmi.toStringAsFixed(1)}
- 偏好运动：$_selectedExerciseType
${_goalController.text.isNotEmpty ? '- 健身目标：${_goalController.text}' : ''}

计划要求：
1. 为期一周的健身计划，从今天（${today}）开始
2. 每天安排不同的运动内容
3. 运动时间建议每天晚上19:00开始（可根据实际情况调整）
4. 运动时长控制在45-90分钟之间
5. 包含适当的热身和放松
6. 根据我的BMI和偏好运动类型调整强度
7. 所有日期必须使用当前年份（${now.year}）或之后的时间

请按照JSON格式输出健身计划，确保所有时间都是${now.year}年或之后的日期。''';

      // 调用AI生成计划
      final response = await NetworkAi.askAi(
        prompt,
        Constant.aiSystemPromptForFitnessPlan,
        AiModel.deepseekChat,
      );

      if (response == null || response.isEmpty) {
        Get.snackbar('错误', '生成健身计划失败，请重试');
        return;
      }

      // 解析JSON响应
      final jsonStr = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> jsonList = jsonDecode(jsonStr);

      // 转换为Task对象
      final tasks = <Task>[];
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          final task = Task.importFromAiMap(item);
          task.tags = ['健身', '健康'];
          task.importance = 4;
          tasks.add(task);
        }
      }

      setState(() {
        _generatedPlan = tasks;
      });

      if (tasks.isNotEmpty) {
        Get.snackbar('成功', '已生成${tasks.length}天的健身计划');
      } else {
        Get.snackbar('提示', '未生成有效的健身计划');
      }
    } catch (e) {
      logger.e('生成健身计划失败: $e');
      Get.snackbar('错误', '生成健身计划失败：$e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  // 添加所有计划到日程
  void _addAllToSchedule() {
    if (_generatedPlan.isEmpty) {
      Get.snackbar('提示', '请先生成健身计划');
      return;
    }

    for (final task in _generatedPlan) {
      DataController.to.addTask(task);
    }

    Get.snackbar('成功', '已添加${_generatedPlan.length}个健身任务到日程');
  }

  // 添加单个任务到日程
  void _addTaskToSchedule(Task task) {
    DataController.to.addTask(task);
    Get.snackbar('成功', '已添加"${task.title}"到日程');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('健身模式'),
      ),
      body: GetBuilder<DataController>(
        init: DataController.to,
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息输入卡片
                _buildUserInputCard(),
                SizedBox(height: 16),

                // 生成按钮
                if (_generatedPlan.isEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateFitnessPlan,
                      icon: _isGenerating
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.fitness_center),
                      label: Text(_isGenerating ? '生成中...' : '生成健身计划'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // 生成的计划列表
                if (_generatedPlan.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '健身计划',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addAllToSchedule,
                        icon: Icon(Icons.add_circle_outline),
                        label: Text('全部添加到日程'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ...List.generate(
                    _generatedPlan.length,
                    (index) => _buildPlanCard(_generatedPlan[index], index),
                  ),
                  SizedBox(height: 16),
                  // 重新生成按钮
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isGenerating ? null : _generateFitnessPlan,
                      icon: Icon(Icons.refresh),
                      label: Text('重新生成'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInputCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '个人信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // 身高输入
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '身高',
                hintText: '请输入身高（厘米）',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
                suffixText: 'cm',
              ),
            ),
            SizedBox(height: 12),

            // 体重输入
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '体重',
                hintText: '请输入体重（公斤）',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
            ),
            SizedBox(height: 12),

            // 偏好运动选择
            Text(
              '偏好运动',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _exerciseTypes.map((type) {
                final isSelected = _selectedExerciseType == type;
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedExerciseType = selected ? type : null;
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
            ),
            SizedBox(height: 12),

            // 健身目标输入
            TextField(
              controller: _goalController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '健身目标（可选）',
                hintText: '例如：减重、增肌、塑形、提高体能等',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Task task, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (task.summary != null && task.summary!.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          task.summary!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // 时间和地点
            if (task.startTime != null || task.location != null)
              Wrap(
                spacing: 16,
                children: [
                  if (task.startTime != null)
                    _buildInfoChip(
                      Icons.access_time,
                      task.startTimeWithPrecision,
                    ),
                  if (task.location != null)
                    _buildInfoChip(
                      Icons.location_on,
                      task.location!,
                    ),
                ],
              ),
            SizedBox(height: 12),

            // 添加按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addTaskToSchedule(task),
                icon: Icon(Icons.add),
                label: Text('添加到日程'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}