import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/repository/remote_db.dart';
import 'package:time_manager_client/data/types/web_crawler_web.dart';
import 'package:time_manager_client/widgets/pages/web_crawler_tasks_bottom_sheet.dart'; // 添加导入

class WebCrawlerPage extends StatefulWidget {
  const WebCrawlerPage({super.key});

  @override
  State<WebCrawlerPage> createState() => _WebCrawlerPageState();
}

class _WebCrawlerPageState extends State<WebCrawlerPage> {
  List<WebCrawlerWeb> _crawlerWebs = [];
  Map<int, int> _relevance = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCrawlerData();
  }

  Future<void> _loadCrawlerData() async {
    try {
      final controller = Get.find<DataController>();
      // 使用DataController中实际存在的方法
      final (webs, relevance) = await controller.getWebCrawlerWebsAndRelvance();
      setState(() {
        _crawlerWebs = webs;
        _relevance = relevance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('错误', '加载爬虫数据失败: $e');
    }
  }

  Future<void> _startCrawler(WebCrawlerWeb web) async {
    try {
      print("🚀 启动爬虫配置: ID=${web.id}, 名称=${web.name}");

      Get.dialog(
        AlertDialog(
          title: Text('启动爬虫'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在启动 ${web.name} 爬虫...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final controller = Get.find<DataController>();
      final remoteDb = RemoteDb.instance;

      // 调用RemoteDb中的方法启动爬虫
      final result = await remoteDb.startCrawler(web.id);

      Get.back(); // 关闭对话框

      if (result) {
        Get.snackbar('成功', '爬虫启动成功');
        // 爬虫启动成功后，自动加载并显示任务
        _showCrawlerTasks(web);
      } else {
        Get.snackbar('失败', '爬虫启动失败');
      }
    } catch (e) {
      Get.back(); // 关闭对话框
      Get.snackbar('错误', '启动爬虫失败: $e');
    }
  }

  // 显示爬虫任务列表
  Future<void> _showCrawlerTasks(WebCrawlerWeb web) async {
    try {
      final remoteDb = RemoteDb.instance;
      final tasks = await remoteDb.getWebCrawlerTasks(web.id);

      if (tasks.isNotEmpty) {
        // 使用现有的BottomSheet组件显示任务列表
        await WebCrawlerTasksBottomSheet(web, tasks).show(context);
      } else {
        Get.snackbar('提示', '该爬虫配置还没有任务数据');
      }
    } catch (e) {
      Get.snackbar('错误', '加载爬虫任务失败: $e');
    }
  }

  // 查看爬虫任务详情
  void _viewCrawlerTasks(WebCrawlerWeb web) {
    _showCrawlerTasks(web);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("网页爬虫导入"),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => WebCrawlerAddPage());
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _crawlerWebs.length,
              itemBuilder: (context, index) {
                // 安全检查防止RangeError
                if (index < 0 || index >= _crawlerWebs.length) {
                  return SizedBox.shrink(); // 返回空组件
                }
                final web = _crawlerWebs[index];
                return ListTile(
                  title: Text(web.name),
                  subtitle: Text(web.summary),
                  onTap: () {
                    // 点击配置项查看任务
                    _viewCrawlerTasks(web);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: () => _viewCrawlerTasks(web),
                        tooltip: '查看任务',
                      ),
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () => _startCrawler(web),
                        tooltip: '启动爬虫',
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// 添加爬虫配置页面
class WebCrawlerAddPage extends StatefulWidget {
  const WebCrawlerAddPage({super.key});

  @override
  State<WebCrawlerAddPage> createState() => _WebCrawlerAddPageState();
}

class _WebCrawlerAddPageState extends State<WebCrawlerAddPage> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _summaryController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _summaryController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCrawler() async {
    if (_nameController.text.isEmpty || _codeController.text.isEmpty) {
      Get.snackbar('错误', '请填写名称和代码');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final controller = Get.find<DataController>();
      await controller.submitWebCrawler(
        _nameController.text,
        _summaryController.text,
        _codeController.text,
      );

      Get.back(); // 关闭页面
      Get.snackbar('成功', '爬虫配置提交成功');
    } catch (e) {
      Get.snackbar('错误', '提交失败: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加爬虫配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSubmitting ? null : _submitCrawler,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '网站名称',
                  hintText: '例如：南京工业大学教务处',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: '网站URL',
                  hintText: '例如：https://jwc.njtech.edu.cn',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  hintText: '网站功能描述',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('爬虫代码:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    hintText: '请输入Python爬虫代码...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  maxLines: 10,
                ),
              ),
              const SizedBox(height: 16),
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
