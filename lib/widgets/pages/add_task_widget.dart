import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/types/auto_task.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/widgets/pages/add_task_from_text_widget.dart';
import 'package:time_manager_client/widgets/pages/star_rate_widget.dart';

class AddTaskWidget extends StatefulWidget {
  const AddTaskWidget({super.key});

  static void show(BuildContext context) => Helper.showModalBottomSheetWithTextField(context, AddTaskWidget());

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  bool expand = false;
  int? importance;
  DateTime? startDateTime;
  DateTime? endDateTime;
  AutoTask? autoTask;

  bool _lastTaskTitleIsEmpty = true;
  late final _inputList = Task.inputFieldParams.map((e) => (e.$1, e.$2, e.$3, TextEditingController())).toList();

  late final _inputListWidget = [
    for (final ip in _inputList.sublist(2))
      TextField(
        controller: ip.$4,
        keyboardType: TextInputType.text,
        autofocus: true,
        style: Theme.of(context).textTheme.titleSmall,
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints.tightForFinite(),
          prefixIcon: Icon(ip.$2, size: 14),
          hintText: ip.$1,
          border: InputBorder.none,
          isCollapsed: true,
        ),
      )
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _inputList[0].$4,
                keyboardType: TextInputType.text,
                autofocus: true,
                style: Theme.of(context).textTheme.titleMedium,
                decoration: InputDecoration(
                  hintText: "准备做的任务",
                  border: InputBorder.none,
                  isCollapsed: true,
                  prefixIcon: Helper.if_(expand, Icon(Icons.flag_outlined)),
                  prefixIconConstraints: BoxConstraints.tightForFinite(),
                ),
                onChanged: (value) {
                  if (value.isEmpty != _lastTaskTitleIsEmpty) {
                    _lastTaskTitleIsEmpty = value.isEmpty;
                    setState(() {});
                  }
                },
              ),
              TextField(
                controller: _inputList[1].$4,
                keyboardType: TextInputType.text,
                autofocus: true,
                style: Theme.of(context).textTheme.titleSmall,
                decoration: InputDecoration(
                  hintText: "内容概述",
                  border: InputBorder.none,
                  isCollapsed: true,
                  prefixIcon: Helper.if_(expand, Icon(Icons.label_outline, size: 14)),
                  prefixIconConstraints: BoxConstraints.tightForFinite(),
                ),
              ),
              if (expand) ..._inputListWidget,
            ],
          ),
        ),
        buildBottomButtons()
      ],
    );
  }

  Widget buildBottomButtons() {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          IconButton(
            onPressed: bSetDate,
            isSelected: startDateTime != null,
            icon: Icon(endDateTime == null ? Icons.date_range_rounded : Icons.calendar_month_rounded),
          ),
          IconButton(
            onPressed: bStarRate,
            isSelected: importance != null,
            icon: Icon(Icons.star_rounded),
          ),
          IconButton(
            onPressed: bExpand,
            isSelected: expand,
            icon: Icon(Icons.more_horiz_rounded),
          ),
          IconButton(
            onPressed: bToAgent,
            isSelected: autoTask != null,
            icon: Icon(Icons.smart_toy_rounded),
          ),
          Expanded(child: SizedBox()),
          if (_inputList[0].$4.text.isNotEmpty)
            SizedBox(
              height: 30,
              width: 60,
              child: ElevatedButton(
                onPressed: bFinish,
                child: Icon(Icons.send_rounded),
                // isSelected: true,
              ),
            )
          else ...[
            // IconButton(
            //   onPressed: bFromImage,
            //   icon: Icon(Icons.image),
            // ),
            // IconButton(
            //   onPressed: bFromClipboard,
            //   icon: Icon(Icons.copy),
            // ),
          ],
          SizedBox(width: 8),
        ],
      ),
    );
  }

  void bToAgent() async {
    if (autoTask != null) {
      autoTask = null;
      setState(() {});
      return;
    }
    if (startDateTime == null) {
      Get.snackbar("错误", "请在【日期】中设置执行时间");
      return;
    }
    final demand = _inputList[1].$4.text;
    if (demand.isEmpty) {
      Get.snackbar("错误", "请在【内容概述】中描述任务");
      return;
    }
    final at = AutoTask(startDateTime!, demand);
    autoTask = at;
    setState(() {});
    // final at = await NetworkAi.getAutoTaskFromText(demand, startDateTime!);
    // print(at);
  }

  void bFinish() {
    if (_inputList[0].$4.text.isEmpty) return;
    DataController.to.addTask(
      Task.fromController(
        _inputList.map((e) => e.$4).toList(),
        startTime: startDateTime,
        endTime: endDateTime,
        importance: importance,
        autoTask: autoTask,
      ),
    );
    Navigator.of(context).pop();
  }

  void bFromImage() => bFromOther(getTextFromImage());
  void bFromClipboard() => bFromOther(getTextFromClipboard());

  void bFromOther(Future<String?> otherFuture) {
    Get.back();
    AddTaskFromTextWidget.show(context, futureText: otherFuture);
  }

  Future<String?> getTextFromImage() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    final iimage = InputImage.fromFilePath(image.path);
    final rec = TextRecognizer(script: TextRecognitionScript.chinese);
    final res = await rec.processImage(iimage);
    return res.blocks.map((b) => b.text).join("\n\n");
  }

  Future<String?> getTextFromClipboard() async {
    if (!await Clipboard.hasStrings()) return null;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  void bSetDate() async {
    final dts = await Helper.showDateTimeRangePicker(context);
    startDateTime = dts?.$1;
    endDateTime = dts?.$2;
    setState(() {});
  }

  void bStarRate() async {
    importance = await StarRateWidget.show(context, importance);
    setState(() {});
  }

  void bExpand() {
    expand = !expand;
    setState(() {});
  }
}
