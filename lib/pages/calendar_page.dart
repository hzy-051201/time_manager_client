import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/repository/logger.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/helper/extension.dart';
import 'package:time_manager_client/widgets/pages/view_task_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Iterable<Task> _showTaskDay = [];
  Iterable<Task> _showTaskMonth = [];
  Iterable<Task> _showTaskYear = [];
  Iterable<Task> _showTaskUnknown = [];

  Iterable<Task> _taskDay = [];
  Iterable<Task> _taskMonth = [];
  Iterable<Task> _taskYear = [];

  List<(Iterable<Task>, String)> _showTasks() => [
        (_showTaskDay, "本日任务"),
        (_showTaskMonth, "本月任务"),
        (_showTaskYear, "本年任务"),
        (_showTaskUnknown, "未分类任务"),
      ];

  @override
  void initState() {
    super.initState();
    _onSelectedChanged();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DataController>(
      init: DataController.to,
      builder: (c) {
        return Scaffold(
          body: Column(
            children: [
              TableCalendar(
                focusedDay: _focusDay,
                firstDay: DateTime(1950),
                lastDay: DateTime(2500),
                locale: "zh_CN",
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => _selectedDay == day,
                availableCalendarFormats: {
                  CalendarFormat.month: "月视图",
                  CalendarFormat.twoWeeks: "双周视图",
                  CalendarFormat.week: "周视图",
                },
                eventLoader: (day) => c.tasks.where((t) => (t.startTime?.isSameDay(day) ?? false) || (t.endTime?.isSameDay(day) ?? false)).toList(),
                onFormatChanged: (format) {
                  _calendarFormat = format;
                  setState(() {});
                },
                onDaySelected: (selectedDay, focusedDay) {
                  _focusDay = selectedDay;
                  _selectedDay = selectedDay;
                  _onSelectedChanged();
                  setState(() {});
                },
                onPageChanged: (focusedDay) {
                  _focusDay = focusedDay;
                  _selectedDay = focusedDay;
                  _onSelectedChanged();
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final showTask in _showTasks()) ...[
                      if (showTask.$1.isNotEmpty)
                        Text(
                          " ${showTask.$2} >",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      for (final task in showTask.$1) _TaskCard(task: task),
                      // ListTile(
                      //   title: Text(task.title),
                      //   subtitle: Text(task.summary ?? ""),
                      // ),
                    ]
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "calendar_floating_action_button",
            onPressed: () {
              _focusDay = DateTime.now();
              _selectedDay = _focusDay;
              _onSelectedChanged();
              setState(() {});
            },
            child: Text("今", style: TextStyle(fontSize: 20)),
          ),
        );
      },
    );
  }

  void _onSelectedChanged() {
    Iterable<Task> tasks = DataController.to.tasks;
    logger.t("changed: $_selectedDay");

    _taskYear = tasks.where((t) =>
        t.startTime != null &&
        (t.endTime == null ? t.startTime!.year == _selectedDay.year : (t.startTime!.year <= _selectedDay.year && t.endTime!.year >= _selectedDay.year)));
    _taskMonth = _taskYear.where((t) =>
        t.startTime != null &&
        (t.endTime == null ? t.startTime!.month == _selectedDay.month : (t.startTime!.month <= _selectedDay.month && t.endTime!.month >= _selectedDay.month)));
    _taskDay = _taskMonth.where((t) =>
        t.startTime != null &&
        (t.endTime == null ? t.startTime!.day == _selectedDay.day : (t.startTime!.day <= _selectedDay.day && t.endTime!.day >= _selectedDay.day)));

    _showTaskDay = _taskDay;
    _showTaskMonth = _taskMonth.where((t) => !_showTaskDay.contains(t) && (t.endTime?.isAfter(_selectedDay) ?? t.startTime?.isAfter(_selectedDay) ?? true));
    _showTaskYear = _taskYear.where(
        (t) => !_showTaskMonth.contains(t) && !_showTaskDay.contains(t) && (t.endTime?.isAfter(_selectedDay) ?? t.startTime?.isAfter(_selectedDay) ?? true));
    _showTaskUnknown = tasks.where((t) => t.startTime == null && t.endTime == null);
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final startTime = task.startTime?.formatWithPrecision(task.startTimePrecision ?? 5);
    final endTime = task.endTime?.formatWithPrecision(task.endTimePrecision ?? 5);
    final haveTime = startTime != null || endTime != null;

    return SizedBox(
      height: haveTime ? 96 : 64,
      child: InkWell(
        onTap: () {
          ViewTaskWidget.show(context, task);
        },
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Expanded(child: SizedBox()),
                    if (task.importance != null && task.importance! > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(task.importance.toString()),
                        ],
                      )
                  ],
                ),
                if (startTime != null) const SizedBox(height: 4),
                if (haveTime)
                  Row(
                    children: [
                      if (startTime != null) Icon(Icons.calendar_month_rounded, size: 16),
                      SizedBox(width: 4),
                      Text(startTime ?? ""),
                      if (endTime != null) Text(" ~ "),
                      Text(endTime ?? ""),
                      // Text( ?? ""),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
