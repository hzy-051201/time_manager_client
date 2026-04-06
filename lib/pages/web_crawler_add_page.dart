import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';

class WebCrawlerAddPage extends StatelessWidget {
  WebCrawlerAddPage({super.key});

  final nameController = TextEditingController();
  final summaryController = TextEditingController();
  final codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("网页爬虫创建"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "网站名称",
                hintText: "请输入网站名称",
              ),
            ),
            TextField(
              controller: summaryController,
              decoration: InputDecoration(
                labelText: "网站简介",
                hintText: "请输入网站简介",
              ),
            ),
            Expanded(
              child: TextField(
                controller: codeController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  labelText: "爬虫代码",
                  hintText: "请输入爬虫代码",
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final summary = summaryController.text;
                final code = codeController.text;

                if (name.isEmpty || summary.isEmpty || code.isEmpty) {
                  Get.snackbar("错误", "请填写完整信息");
                  return;
                }

                await DataController.to.submitWebCrawler(name, summary, code);
                Get.back();
                Get.snackbar("提交成功", "网页爬虫已提交成功,请等待审核");
              },
              child: Text("提交"),
            ),
          ],
        ),
      ),
    );
  }
}
