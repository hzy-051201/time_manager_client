import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_star_rating/simple_star_rating.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/helper/extension.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/widgets/link_text.dart';

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({super.key, this.old});

  final Task? old;

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final formKey = GlobalKey<FormState>();
  bool expandTimePrecision = false;

  late int importance = widget.old?.importance ?? 0;
  late final importanceController = TextEditingController(
      text: Helper.if_(importance != 0, importance.toString()));

  late int? startTimePrecision = widget.old?.startTimePrecision;
  late int? endTimePrecision = widget.old?.endTimePrecision;
  late DateTime? startTime = widget.old?.startTime;
  late DateTime? endTime = widget.old?.endTime;
  final dateController = TextEditingController();

  late final controllers = widget.old
          ?.paramAndInfo()
          .map((e) => TextEditingController(text: e.$3))
          .toList() ??
      List.generate(
          Task.inputFieldParams.length, (_) => TextEditingController());
  late final focusNodes = List.generate(controllers.length, (_) => FocusNode());

  late final List<DateTime> noticeTimes = widget.old?.noticeTimes ?? [];
  late final List<String> tags = widget.old?.tags ?? [];

  late final _timePrecisionList = [
    (
      "开始时间精度:",
      () => startTimePrecision,
      (index) => startTimePrecision = index
    ),
    ("结束时间精度:", () => endTimePrecision, (index) => endTimePrecision = index),
  ];

  @override
  void initState() {
    super.initState();
    updateTimePrecision(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double expandTimePrecisionHeight =
        expandTimePrecision && startTime != null
            ? endTime != null
                ? 80
                : 40
            : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("编辑任务"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              DataController.to.deleteTask(widget.old!);
              Get.back();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: buildMain(expandTimePrecisionHeight, theme),
      ),
    );
  }

  Form buildMain(double expandTimePrecisionHeight, ThemeData theme) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final pcf in Helper.zip(
                    Task.inputFieldParams, controllers, focusNodes))
                  buildTextField(pcf),
                buildDateTime(),
                buildDateTimePrecision(expandTimePrecisionHeight, theme),
                buildImportance(),
                buildNoticeTime(),
                buildTags(),
                if (widget.old?.source?.isNotEmpty ?? false) buildSource(),
                if (widget.old?.content?.isNotEmpty ?? false) buildContent(),
                SizedBox(height: 16),
              ],
            ),
          ),
          // 固定底部的提交按钮
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: buildFinish(),
          ),
        ],
      ),
    );
  }

  Widget buildTags() {
    return Row(children: [
      Text("标签: ", style: Theme.of(context).textTheme.titleMedium),
      Expanded(
          child: Wrap(spacing: 2, runSpacing: 2, children: [
        for (final tag in Task.defaultTags)
          RawChip(
            selected: tags.contains(tag),
            label: Text(tag),
            onPressed: () {
              if (tags.contains(tag)) {
                tags.remove(tag);
              } else {
                tags.add(tag);
              }
              setState(() {});
            },
          )
      ])),
    ]);
  }

  ElevatedButton buildFinish() {
    return ElevatedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          final task = Task.fromController(
            controllers,
            startTime: startTime,
            startTimePrecision: startTimePrecision,
            endTime: endTime,
            endTimePrecision: endTimePrecision,
            importance: importance,
            content: widget.old?.content,
            status: widget.old?.status ?? TaskStatus.unfinished,
            noticeTimes: noticeTimes,
            tags: tags,
          );
          if (widget.old == null) {
            DataController.to.addTask(task);
          } else {
            DataController.to.editTask(widget.old!, task);
          }
          Get.back();
        }
      },
      child: Text("完成"),
    );
  }

  Widget buildContent() {
    return Row(
      children: [
        Text("内容: ", style: Theme.of(context).textTheme.titleMedium),
        Expanded(
            child: LinkText(
          widget.old?.content ?? "无",
          maxLines: 1,
        )),
        TextButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("原文"),
              content: LinkText(
                widget.old?.content ?? "无",
              ),
            ),
          ),
          child: Text("更多"),
        ),
      ],
    );
  }

  Widget buildSource() {
    return Row(
      children: [
        Text("来源: ", style: Theme.of(context).textTheme.titleMedium),
        Text(widget.old?.source ?? "无"),
      ],
    );
  }

  TextFormField buildTextField(
      ((String, IconData, bool), TextEditingController, FocusNode?) pcf) {
    return TextFormField(
      keyboardType: TextInputType.text,
      controller: pcf.$2,
      autofocus: true,
      focusNode: pcf.$3,
      decoration: InputDecoration(
        prefixIconConstraints: BoxConstraints.tightForFinite(),
        prefixIcon: Icon(pcf.$1.$2),
        labelText: pcf.$1.$1,
        border: UnderlineInputBorder(),
      ),
      validator: Helper.if_(!pcf.$1.$3,
          (v) => Helper.if_(v == null || v.isEmpty, '请输入${pcf.$1.$1}')),
    );
  }

  SizedBox buildNoticeTime() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Text(
            "提醒时间: ",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          buildNoticeTimeList(),
          IconButton(
            onPressed: () async {
              clearTextFieldFocusNode();
              final r = await Helper.showDateTimePicker(context);
              if (r != null) {
                noticeTimes.add(r);
                setState(() {});
              }
            },
            icon: Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }

  TextFormField buildImportance() => TextFormField(
        autofocus: true,
        controller: importanceController,
        keyboardType:
            TextInputType.numberWithOptions(decimal: false, signed: false),
        onChanged: importanceTextChanged,
        validator: importanceTextValidator,
        decoration: InputDecoration(
            prefixIconConstraints: BoxConstraints.tightForFinite(),
            prefixIcon: Icon(Icons.star_border_rounded),
            labelText: "重要性",
            border: UnderlineInputBorder(),
            suffix: SimpleStarRating(
              isReadOnly: false,
              allowHalfRating: false,
              spacing: 4,
              rating: importance.toDouble(),
              onRated: importanceRateChanged,
            )),
      );

  AnimatedContainer buildDateTimePrecision(
      double expandTimePrecisionHeight, ThemeData theme) {
    return AnimatedContainer(
      duration: Durations.medium1,
      height: expandTimePrecisionHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 4),
          for (final tp
              in _timePrecisionList.sublist(0, endTime != null ? 2 : 1))
            SizedBox(
              height: 34,
              child: Row(
                children: [
                  Text(tp.$1),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: Task.timePricisions.length,
                      separatorBuilder: (context, index) => SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final s = Task.timePricisions[index];
                        return InkWell(
                          onTap: () {
                            tp.$3(index);
                            updateTimePrecision();
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: index == tp.$2()
                                  ? theme.colorScheme.inversePrimary
                                  : null,
                              border:
                                  Border.all(color: theme.colorScheme.primary),
                            ),
                            child: Center(child: Text(s)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  TextFormField buildDateTime() {
    return TextFormField(
      autofocus: true,
      readOnly: true,
      controller: dateController,
      onTap: dateEditClicked,
      decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints.tightForFinite(),
          prefixIcon: Icon(Icons.date_range_outlined),
          labelText: "日期",
          border: UnderlineInputBorder(),
          suffixIcon: Helper.if_(
              startTime != null,
              ExpandIcon(
                isExpanded: expandTimePrecision,
                onPressed: (_) {
                  expandTimePrecision = !expandTimePrecision;
                  setState(() {});
                },
              ))),
    );
  }

  Expanded buildNoticeTimeList() {
    return Expanded(
      child: noticeTimes.isEmpty
          ? Text("未设置")
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: noticeTimes.length,
              separatorBuilder: (context, index) => SizedBox(width: 8),
              itemBuilder: (context, index) => RawChip(
                label: Text(noticeTimes[index].formatWithPrecision(5)),
                onPressed: () async {
                  clearTextFieldFocusNode();
                  final r = await Helper.showDateTimePicker(context,
                      initialDate: noticeTimes[index]);
                  if (r == null) return;
                  noticeTimes[index] = r;
                  setState(() {});
                },
                onDeleted: () {
                  clearTextFieldFocusNode();
                  noticeTimes.removeAt(index);
                  setState(() {});
                },
              ),
            ),
    );
  }

  void clearTextFieldFocusNode() {
    for (var e in focusNodes) {
      e.unfocus();
    }
  }

  void dateEditClicked() {
    Helper.showDateTimeRangePicker(context).then((dts) {
      startTime = dts?.$1;
      endTime = dts?.$2;

      if (startTime == null) {
        startTimePrecision = null;
      } else {
        startTimePrecision = startTimePrecision ?? 5;
      }

      if (endTime == null) {
        endTimePrecision = null;
      } else {
        endTimePrecision = endTimePrecision ?? 5;
      }

      updateTimePrecision();
    });
  }

  void updateTimePrecision([bool refresh = true]) {
    String r = startTime?.formatWithPrecision(startTimePrecision ?? 5) ?? "";
    if (endTime != null) {
      r += " ~ ${endTime?.formatWithPrecision(endTimePrecision ?? 5)}";
    }
    dateController.text = r;
    if (refresh) setState(() {});
  }

  void importanceRateChanged(double? rating) {
    if (rating == null) return;
    importance = rating.toInt();
    importanceController.text = importance.toString();
    setState(() {});
  }

  String? importanceTextValidator(value) {
    if (value != null && value.isNotEmpty) {
      final int rating = int.parse(value);
      if (rating < 1 || rating > 5) return "请输入1~5的整数";
    }
    return null;
  }

  void importanceTextChanged(value) {
    if (value.length > 1) {
      importanceController.text = value[value.length - 1];
    }
    final r = int.tryParse(importanceController.text) ?? 0;
    importance = max(0, r);
    importance = min(5, importance);
    importanceController.text = importance.toString();
    setState(() {});
  }
}
