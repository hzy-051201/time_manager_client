import 'package:docx_to_text/docx_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/pages/edit_task_page.dart';
import 'package:time_manager_client/widgets/pages/multi_task_selector_bottom_sheet.dart';
import 'package:time_manager_client/widgets/pages/recognize_task_confirm_dialog.dart';

class AddTaskFromTextWidget extends StatefulWidget {
  const AddTaskFromTextWidget({super.key, this.futureText});
  final Future<String?>? futureText;

  static void show(BuildContext context, {Future<String?>? futureText}) => Helper.showModalBottomSheetWithTextField(
      context,
      AddTaskFromTextWidget(
        futureText: futureText,
      ));

  @override
  State<AddTaskFromTextWidget> createState() => _AddTaskFromTextWidgetState();
}

class _AddTaskFromTextWidgetState extends State<AddTaskFromTextWidget> {
  final controller = TextEditingController();

  DateTime? startSendTime;
  bool firstBuild = true;

  bool get enable => startSendTime == null;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.futureText,
        builder: (context, snapshot) {
          if (snapshot.hasData && controller.text.isEmpty && firstBuild) {
            controller.text = snapshot.data!;
            firstBuild = false;
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: snapshot.connectionState == ConnectionState.waiting
                    ? SizedBox(
                        height: 128,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : TextField(
                        controller: controller,
                        autofocus: true,
                        enabled: enable,
                        minLines: 4,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "请在此输入文本，将由AI识别并提取任务信息。",
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
              ),
              if (!enable)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LinearProgressIndicator(),
                ),
              Row(
                children: [
                  IconButton(
                    onPressed: enableBFunc(bFromGallery),
                    icon: Icon(Icons.photo_outlined),
                  ),
                  IconButton(
                    onPressed: enableBFunc(bFromCamera),
                    icon: Icon(Icons.camera_alt_outlined),
                  ),
                  IconButton(
                    onPressed: enableBFunc(bFromClipboard),
                    icon: Icon(Icons.copy_outlined),
                  ),
                  IconButton(
                    onPressed: enableBFunc(bFromFile),
                    icon: Icon(Icons.upload_file_outlined),
                  ),
                  IconButton(
                    onPressed: enableBFunc(() => controller.clear()),
                    icon: Icon(Icons.clear_all_rounded),
                  ),
                  Expanded(child: SizedBox()),
                  ElevatedButton(
                    onPressed: Helper.if_(enable && controller.text.isNotEmpty, bSend),
                    child: Icon(Icons.send_rounded),
                  ),
                ],
              )
            ],
          );
        });
  }

  void Function()? enableBFunc(void Function() func) => enable ? func : null;
  void bFromCamera() => fromImage(ImageSource.camera);
  void bFromGallery() => fromImage(ImageSource.gallery);
  void bFromClipboard() async {
    if (!await Clipboard.hasStrings()) return null;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null) return null;
    controller.text = data.text!;
    setState(() {});
  }

  void bFromFile() async {
    final f = await FilePicker.platform.pickFiles();
    final p = f?.xFiles.firstOrNull;
    if (p == null) return null;

    final d = await p.readAsBytes();
    final r = docxToText(d);
    controller.text = r;
    setState(() {});
  }

  final _picker = ImagePicker();
  void fromImage(ImageSource source) {
    _picker.pickImage(source: source).then((image) async {
      if (image == null) return null;
      final iimage = InputImage.fromFilePath(image.path);
      final rec = TextRecognizer(script: TextRecognitionScript.chinese);
      final res = await rec.processImage(iimage);
      final text = res.blocks.map((b) => b.text).join("\n\n");
      controller.text = text;
      setState(() {});
    });
  }

  void bSend() async {
    if (controller.text.isEmpty) return;
    startSendTime = DateTime.now();
    setState(() {});

    final t = await DataController.to.getTaskFromText(controller.text);
    startSendTime = null;
    if (mounted) setState(() {});

    // if (t.length == 1) Get.to(() => EditTaskPage(old: t.first));
    if (t.length == 1 && mounted) RecognizeTaskConfirmDialog(t.first).show(context);

    if (t.length > 1 && mounted) {
      MultiTaskSelectorBottomSheet(
        tasks: t,
        onSelected: (ta) {
          Get.to(() => EditTaskPage(old: ta));
        },
      ).show(context);
      // await MultiTaskSelectorBottomSheet.show(
      //   context,
      //   t,
      //   onSelected: (ta) {
      //     Get.to(() => EditTaskPage(old: ta));
      //   },
      // );
    }
  }
}
