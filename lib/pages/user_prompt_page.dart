import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/helper/helper.dart';

class UserPromptPage extends StatefulWidget {
  const UserPromptPage({super.key});

  // final List<String> prompts;

  @override
  State<UserPromptPage> createState() => _UserPromptPageState();
}

class _UserPromptPageState extends State<UserPromptPage> {
  // late List<TextEditingController> controllers = widget.prompts.map((p) => TextEditingController(text: p)).toList();
  List<TextEditingController> controllers = [];

  Iterable<TextField> get textFields => List.generate(
        controllers.length,
        (index) => TextField(
          readOnly: index == 0,
          controller: controllers[index],
          decoration: InputDecoration(
            labelText: "用户提示词${index + 1}",
            suffixIcon: index == 0
                ? null
                : IconButton(
                    onPressed: () {
                      controllers.removeAt(index);
                      setState(() {});
                    },
                    icon: Icon(Icons.delete),
                  ),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();

    DataController.to.getUserPrompt(true).then((prompts) {
      if (prompts.isEmpty) return;
      controllers = prompts.map((e) => TextEditingController(text: e)).toList();

      final p = prompts.firstOrNull ?? "";
      for (int i = 0; i < selectBox.length; i++) {
        for (final (oi, o) in Helper.enumerate(selectBox[i].$2)) {
          if (p.contains(o.$1)) {
            selectedIndex[i] = oi;
          }
        }
      }

      if (mounted) setState(() {});
    });
  }

  static const userCareers = [
    ("学生", "🧑‍🎓"),
    ("老师", "🧑‍🏫"),
    ("医生", "🧑‍⚕️"),
    ("其他", "🧑‍💼"),
  ];
  static const userGenders = [
    ("男", "♂️"),
    ("女", "♀️"),
  ];

  static final selectBox = [
    ("身份", userCareers),
    ("性别", userGenders),
  ];
  final List<int> selectedIndex = List.generate(selectBox.length, (_) => -1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("用户提示词"),
        actions: [
          IconButton(
            onPressed: () async {
              await DataController.to.updateUserPrompt(controllers.map((e) => e.text));
              Get.back();
            },
            icon: Icon(Icons.save_rounded),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              for (final (i, s) in Helper.enumerate(selectBox)) buildSelectBox(i, s),
              // Text("用户身份:", style: Theme.of(context).textTheme.titleLarge),
              // SizedBox(height: 128, child: Row(children: userCareers.map((e) => IconButton(onPressed: () {}, icon: Text(e.$2))).toList())),
              ...textFields,
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  controllers.add(TextEditingController());
                  setState(() {});
                },
                label: Text("添加用户提示词"),
                icon: Icon(Icons.add),
              ),
              Text.rich(TextSpan(children: [
                WidgetSpan(child: Icon(Icons.info_outline_rounded, color: Colors.grey)),
                TextSpan(text: "设置适当的用户提示词，在识别文本信息时，更加符合你的需求", style: TextStyle(color: Colors.grey)),
              ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectBox(int index, (String, List<(String, String)>) s) => Row(
        children: [
          Text("${s.$1}:", style: Theme.of(context).textTheme.titleMedium),
          // Expanded(child: child)
          const SizedBox(width: 8),
          for (final (i, c) in Helper.enumerate(s.$2))
            InkWell(
              onTap: () {
                selectedIndex[index] = i;
                setState(() {});
                if (controllers.isEmpty) controllers.add(TextEditingController());
                String t = "用户是一名";
                if (selectedIndex[1] != -1) t += "${selectBox[1].$2[selectedIndex[1]].$1}性";
                if (selectedIndex[0] != -1) t += selectBox[0].$2[selectedIndex[0]].$1;
                controllers.first.text = t;
                // controllers.first.text = ""
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.all(4),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selectedIndex[index] == i ? Theme.of(context).colorScheme.inversePrimary : null,
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                    child: Center(child: Text(c.$2, style: TextStyle(fontSize: 32))),
                  ),
                  Text(c.$1, style: TextStyle(fontSize: 12)),
                ],
              ),
            )
        ],
      );
}
