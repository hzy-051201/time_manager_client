import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_manager_client/widgets/fullscreen_blur_dialog.dart';
import 'package:time_manager_client/widgets/pages/simple_text_bottom_sheet.dart';
import 'package:universal_io/io.dart';

class AideDialog extends StatefulWidget {
  const AideDialog({super.key});

  @override
  State<AideDialog> createState() => _AideDialogState();
}

class _AideDialogState extends State<AideDialog> {
  final picker = ImagePicker();
  final images = ["aide1.gif", "aide2.gif"];
  String showText = "点击此处编辑文字\n单击图片切换样式\n长按图片自己选择";
  int showImageIndex = 0;
  File? showImageFile;

  @override
  Widget build(BuildContext context) {
    return FullscreenBlurDialog(
      availableRatio: 0.95,
      child: Stack(children: [
        Positioned(
          right: 0,
          bottom: 0,
          width: 200,
          height: 200,
          child: GestureDetector(
            onTap: () {
              showImageIndex = (showImageIndex + 1) % images.length;
              setState(() {});
            },
            onLongPress: () async {
              final i = await picker.pickImage(source: ImageSource.gallery);
              if (i == null) return;
              final f = File(i.path);
              if (f.existsSync()) {
                showImageFile = f;
                setState(() {});
              }
            },
            child: showImageFile != null ? Image.file(showImageFile!) : Image.asset("assets/img/${images[showImageIndex]}"),
          ),
        ),
        Positioned(
          bottom: 140,
          right: 140,
          child: GestureDetector(
            onTap: () async {
              final t = await SimpleTextBottomSheet().show(context);
              if (t != null) {
                showText = t;
                setState(() {});
              }
            },
            child: BubbleSpecialTwo(
              text: showText,
              color: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }
}
