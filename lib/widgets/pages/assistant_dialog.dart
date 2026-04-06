import 'package:flutter/material.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/helper/coordinate_helper.dart';
import 'package:time_manager_client/helper/extension.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/widgets/fullscreen_blur_dialog.dart';

class AssistantDialog extends StatefulWidget {
  const AssistantDialog({super.key});

  @override
  State<AssistantDialog> createState() => _AssistantDialogState();
}

class _AssistantDialogState extends State<AssistantDialog> {
  late final screenSize = MediaQuery.of(context).size;
  late final textTheme = Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white);
  late final c = DataController.to;
  late final now = DateTime.now();
  late final tasks = c.tasks.where((e) => e.startTime?.isSameDay(now) ?? false).toList();

  @override
  void initState() {
    super.initState();
    tasks.sort((a, b) => a.startTime!.compareTo(b.startTime!));
  }

  @override
  Widget build(BuildContext context) {
    return FullscreenBlurDialog(
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("助手", style: textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text("以下是为您规划的今天的行程。", style: textTheme.bodyMedium),
            const SizedBox(height: 16),
            buildWeatherCard(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: buildTasks(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWeatherCard() {
    final weather = c.weatherInfo;
    final suggestion = c.weatherSuggestion;

    if (weather == null && suggestion == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (weather != null) ...[
                Text(
                  weather.getWeatherIcon(),
                  style: TextStyle(fontSize: 28),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.city} ${weather.temp.toStringAsFixed(0)}°',
                      style: textTheme.titleLarge,
                    ),
                    Text(
                      weather.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Icon(Icons.cloud_outlined, color: Colors.white.withAlpha(128), size: 32),
                SizedBox(width: 12),
                Text(
                  '正在获取天气信息...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(128),
                  ),
                ),
              ],
              const Spacer(),
              InkWell(
                onTap: () => c.refreshWeather(),
                child: Icon(Icons.refresh, color: Colors.white.withAlpha(200), size: 20),
              ),
            ],
          ),
          if (suggestion != null && suggestion.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha(230),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              await c.getWeatherSuggestionWithTasks();
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(16),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                  SizedBox(width: 6),
                  Text(
                    '获取智能建议',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTasks() {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          '今天没有任务安排',
          style: textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(128)),
        ),
      );
    }

    final stackHeight = tasks.length * 100;

    return SizedBox(
      height: stackHeight.toDouble(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 100,
            width: 2,
            top: 0,
            bottom: 0,
            child: VerticalDivider(),
          ),
          for (final (tno, task) in Helper.enumerate(tasks))
            Positioned(
              left: 128,
              right: 0,
              height: 80,
              top: tno * 100,
              child: buildCard(task),
            ),
          for (final (tno, task) in Helper.enumerate(tasks))
            Positioned(
              left: 85,
              top: tno * 100 + 25,
              width: 30,
              height: 30,
              child: buildStatus(task),
            ),
          for (int i = 0; i < tasks.length - 1; i++) buildDetla(i),
        ],
      ),
    );
  }

  Widget buildStatus(Task task) {
    return task.status == TaskStatus.finished
        ? Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 30),
          )
        : Center(child: Icon(Icons.circle, color: Colors.white, size: 28));
  }

  Widget buildCard(Task task) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            task.title,
            style: textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(Icons.location_pin, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.location ?? "未知地点",
                  style: textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.date_range, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.startTimeWithPrecision,
                  style: textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetla(int i) {
    final prev = tasks[i];
    final next = tasks[i + 1];

    String deltaTime = "";
    // logger.d("${prev.startTime} -> ${next.startTime}");
    if (next.startTime != null && prev.startTime != null) {
      int dtm = next.startTime!.difference(prev.startTime!).inMinutes;
      int dth = dtm ~/ 60;
      dtm %= 60;
      if (dth > 0) deltaTime += "${dth}h ";
      deltaTime += "${dtm}min";
    }

    String deltaLocation = "";
    if (next.latLng != null && prev.latLng != null) {
      double distance = CoordinateHelper.calculateDistance(prev.latLng!, next.latLng!);
      deltaLocation = "${distance.toStringAsFixed(2)}km";
    }

    return Positioned(
      top: i * 100 + 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(deltaTime, style: textTheme.bodyMedium),
          Text(deltaLocation, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
