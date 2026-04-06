import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key, this.autoHandle = true});

  final bool autoHandle;

  @override
  Widget build(BuildContext context) {
    bool submitted = false;
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final l = min(constraints.maxWidth, constraints.maxHeight) / 2;
        return Stack(
          children: [
            MobileScanner(
              onDetect: (barcodes) {
                if (submitted) return;
                Get.back(result: barcodes.barcodes.firstOrNull?.rawValue);
                if (autoHandle && barcodes.barcodes.firstOrNull?.rawValue != null) {
                  DataController.to.handleQrCode(barcodes.barcodes.first.rawValue!);
                }
                submitted = true;
              },
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      color: Colors.white,
                      icon: Icon(Icons.arrow_back),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: l,
                height: l,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
