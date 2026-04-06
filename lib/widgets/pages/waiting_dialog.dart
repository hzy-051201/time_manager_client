import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/repository/logger.dart';

class WaitingDialog<T> extends StatelessWidget {
  const WaitingDialog(this.future, {super.key});

  final Future<T> future;

  Future<T?> show(BuildContext context) => showDialog<T>(
        context: context,
        builder: (context) => this,
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("加载中..."),
      content: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            logger.d("message: ${snapshot.data}");
            if (snapshot.hasData) {
              Get.back(result: snapshot.data);
            }
            if (snapshot.hasError) {
              logger.e(snapshot.error);
              logger.e(snapshot.stackTrace);
            }

            return SizedBox(
              height: 64,
              child: Center(child: CircularProgressIndicator()),
            );
          }),
    );
  }
}
