import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:time_manager_client/data/repository/logger.dart';
import 'package:time_manager_client/pages/calendar_page.dart';
import 'package:time_manager_client/pages/fitness_page.dart';
import 'package:time_manager_client/pages/web_crawler_page.dart';
import 'package:time_manager_client/widgets/desktop_pet.dart';
import 'package:time_manager_client/widgets/pages/add_task_from_text_widget.dart';
import 'package:time_manager_client/widgets/pages/agent_dialog.dart';
import 'package:time_manager_client/widgets/pages/ai_chat_dialog.dart';
import 'package:time_manager_client/widgets/pages/assistant_dialog.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';

import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/pages/edit_group_page.dart';
import 'package:time_manager_client/pages/four_quadrant_page.dart';
import 'package:time_manager_client/pages/list_page.dart';
import 'package:time_manager_client/pages/qr_scanner_page.dart';
import 'package:time_manager_client/pages/setting_page.dart';
import 'package:time_manager_client/widgets/pages/add_task_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化天气数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DataController.to.initWeather();
    });
  }

  final pages = [
    (Icons.list, "列表", ListPage()),
    (Icons.dangerous, "四象限", FourQuadrantPage()),
    (Icons.calendar_month, "日历", CalendarPage()),
    (Icons.fitness_center, "健身", FitnessPage()),
    (Icons.settings, "设置", SettingPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Row(
              children: [
                Expanded(child: buildGroupSwitcher()),
                SizedBox(width: 8),
                buildWeatherWidget(),
              ],
            ),
            centerTitle: true,
            actions: [
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                IconButton(
                  icon: Icon(Icons.qr_code_scanner_rounded),
                  onPressed: () {
                    Get.to(QrScannerPage());
                  },
                ),
              if (!Platform.isAndroid && !Platform.isIOS)
                IconButton(
                  onPressed: () async {
                    await DataController.to.syncAll();
                    logger.t("ddd fin");
                    // RemoteDb.instance.submitTask(7, 1, Task(title: "HEl==="));
                  },
                  icon: Icon(Icons.refresh),
                ),
              // IconButton(
              //     onPressed: () {
              //       Get.to(() => RawTextPage(title: "测试", content: "${Env.dsApiKey.length};${Env.supaUrl.length};${Env.supaAnon.length}"));
              //     },
              //     icon: Icon(Icons.deblur))
            ],
          ),
          bottomNavigationBar: Helper.if_(isPortrait, buildBottomNavigationBar()),
          floatingActionButton: buildFAB(),

          // floatingActionButtonLocation: Helper.if_(isPortrait, FloatingActionButtonLocation.centerDocked),
          floatingActionButtonLocation: ExpandableFab.location,
          body: Stack(
            children: [
              buildBody(orientation),
              // 桌宠组件
              const DesktopPet(),
            ],
          ),
        );
      },
    );
  }

  Widget buildFAB() => ExpandableFab(
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: _addTask,
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: _addTaskFromText,
            child: Icon(Icons.input_rounded),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: _addTaskFromWeb,
            child: Icon(Icons.web_outlined),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: _showAiChat,
            child: Text('🐱', style: TextStyle(fontSize: 24)),
          ),
        ],
      );

  Widget buildBody(Orientation orientation) => orientation == Orientation.landscape ? buildLandscapeRow() : pages[_currentIndex].$3;

  Widget buildWeatherWidget() {
    return GetBuilder<DataController>(
      init: DataController.to,
      builder: (controller) {
        final weather = controller.weatherInfo;
        final loading = controller.weatherLoading;
        
        if (loading) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('加载天气...'),
            ],
          );
        }
        
        if (weather == null) {
          return InkWell(
            onTap: () => controller.refreshWeather(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 20),
                SizedBox(width: 4),
                Text('获取天气', style: TextStyle(fontSize: 14)),
              ],
            ),
          );
        }
        
        return InkWell(
          onTap: () {
            // 显示天气详情和建议
            _showWeatherDialog(controller);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weather.getWeatherIcon(),
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 6),
              Text(
                '${weather.city} ${weather.temp.toStringAsFixed(0)}°',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(width: 4),
              Text(
                weather.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeatherDialog(DataController controller) {
    final weather = controller.weatherInfo;
    final suggestion = controller.weatherSuggestion;
    
    if (weather == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(weather.getWeatherIcon(), style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('${weather.city} 天气'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeatherInfoRow('温度', '${weather.temp.toStringAsFixed(1)}℃'),
            _buildWeatherInfoRow('体感温度', '${weather.feelsLike.toStringAsFixed(1)}℃'),
            _buildWeatherInfoRow('最低温度', '${weather.tempMin.toStringAsFixed(1)}℃'),
            _buildWeatherInfoRow('最高温度', '${weather.tempMax.toStringAsFixed(1)}℃'),
            _buildWeatherInfoRow('湿度', '${weather.humidity}%'),
            _buildWeatherInfoRow('风速', '${weather.windSpeed.toStringAsFixed(1)}m/s'),
            _buildWeatherInfoRow('天气状况', weather.description),
            Divider(),
            if (suggestion != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await controller.getWeatherSuggestionWithTasks();
                _showWeatherDialog(controller);
              },
              icon: Icon(Icons.auto_awesome),
              label: Text('获取智能建议'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Row buildLandscapeRow() {
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: Column(
            children: [
              for (int i = 0; i < pages.length; i++)
                ListTile(
                  leading: Icon(pages[i].$1),
                  title: Text(pages[i].$2),
                  onTap: () {
                    _currentIndex = i;
                    setState(() {});
                  },
                ),
              Expanded(child: SizedBox()),
              Divider(),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      showDialog(context: context, builder: (context) => AssistantDialog());
                    },
                    icon: Icon(Icons.lightbulb_outline_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(context: context, builder: (context) => AgentDialog());
                    },
                    icon: Icon(Icons.smart_toy_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
        VerticalDivider(),
        Expanded(child: pages[_currentIndex].$3),
      ],
    );
  }

  late double _startDragY = MediaQuery.of(context).size.height;
  Widget buildBottomNavigationBar() {
    return GestureDetector(
      onVerticalDragStart: (details) {
        _startDragY = details.globalPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        final y = details.globalPosition.dy;
        if (_startDragY - y > 300) {
          showDialog(context: context, builder: (context) => AssistantDialog());
        }
      },
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          _currentIndex = index;
          setState(() {});
        },
        items: [
          for (int i = 0; i < pages.length; i++)
            BottomNavigationBarItem(
              icon: Icon(pages[i].$1),
              label: pages[i].$2,
            ),
        ],
        // ]..insert(2, BottomNavigationBarItem(icon: SizedBox(), label: "")),
      ),
    );
  }

  Widget buildGroupSwitcher() {
    return InkWell(
      onTap: bSwitchGroup,
      child: GetBuilder<DataController>(
        init: DataController.to,
        builder: (c) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(c.currentGroup.icon),
              const SizedBox(width: 4),
              Text(c.currentGroup.title),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down_rounded),
            ],
          );
        },
      ),
    );
  }

  void bSwitchGroup() {
    showDialog(
      context: context,
      builder: (context) {
        return GetBuilder<DataController>(
          init: DataController.to,
          builder: (c) {
            return SimpleDialog(
              title: Text("选择分组"),
              children: [
                for (final group in c.groups)
                  if (group == c.currentGroup)
                    SimpleDialogOption(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: group.iconAndTitle),
                        TextSpan(text: "  "),
                        TextSpan(text: "[当前]", style: TextStyle(color: Colors.green)),
                      ])),
                    )
                  else
                    SimpleDialogOption(
                      onPressed: () {
                        c.changeCurrentGroup(group);
                        Get.back();
                      },
                      child: Text(group.iconAndTitle),
                    ),
                SimpleDialogOption(
                  onPressed: () {
                    Get.off(() => EditGroupPage());
                  },
                  child: Text("编辑分组"),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _addTask() {
    AddTaskWidget.show(context);
  }

  void _addTaskFromText() {
    AddTaskFromTextWidget.show(context);
  }

  void _addTaskFromWeb() {
    Get.to(() => WebCrawlerPage());
    // AddTaskFromTextWidget.show(context);
  }

  void _showAiChat() {
    showDialog(
      context: context,
      builder: (context) => const AiChatDialog(),
    );
  }
}
