import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/environment/constant.dart';
import 'package:time_manager_client/data/repository/remote_db.dart';

class QrLoginRequestDialog extends StatefulWidget {
  const QrLoginRequestDialog({super.key});

  static Future show(BuildContext context) => showDialog(
        context: context,
        builder: (context) => const QrLoginRequestDialog(),
      );

  @override
  State<QrLoginRequestDialog> createState() => _QrLoginRequestDialogState();
}

class _QrLoginRequestDialogState extends State<QrLoginRequestDialog> {
  var qrRequest = RemoteDb.instance.requestQrLoginToken();
  bool listened = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("二维码登陆"),
      content: Column(
        // mainAxisAlignment: MainAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: FutureBuilder(
              future: qrRequest,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (!listened) {
                    DataController.to.loginWithQr(snapshot.data!).then((e) {
                      if (e) {
                        Get.back();
                      } else {
                        Get.snackbar("二维码失效", "请重新扫描二维码");
                        Get.off(() => QrLoginRequestDialog());
                      }
                    });
                    listened = true;
                  }
                  return QrImageView(
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                    ),
                    data: "${Constant.qrLoginPrefix}${snapshot.data}",
                    version: QrVersions.auto,
                    size: 200.0,
                  );
                }
                // if (snapshot.hasError) {
                //   return Text("${snapshot.error}");
                // }

                return Center(child: CircularProgressIndicator());
              },
            ),
          )
        ],
      ),
    );
  }

  // void startListen() {}
}
