import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/types/web_crawler_tasks.dart';
import 'package:time_manager_client/pages/edit_task_page.dart';

class WebCrawlerTaskPage extends StatelessWidget {
  final WebCrawlerTasks wct;
  const WebCrawlerTaskPage({super.key, required this.wct});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(wct.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (wct.mindmap != null)
              SizedBox(
                height: 256,
                child: InAppWebView(
                  // preventGestureDelay: true,
                  initialData: InAppWebViewInitialData(data: wct.mindmapText),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: wct.tasks.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(wct.tasks[index].title),
                  subtitle: Text(wct.tasks[index].summary ?? ""),
                  onTap: () => Get.to(() => EditTaskPage(old: wct.tasks[index])),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
