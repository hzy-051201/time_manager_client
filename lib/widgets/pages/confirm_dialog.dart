import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    this.title = "提示",
    required this.content,
  });

  static Future<bool?> show({
    required BuildContext context,
    String title = "提示",
    required String content,
  }) =>
      showDialog<bool>(
        context: context,
        builder: (context) => ConfirmDialog(
          title: title,
          content: content,
        ),
      );

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text("取消"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text("确定"),
        ),
      ],
    );
  }
}
