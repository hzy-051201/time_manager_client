import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/types/group.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:time_manager_client/widgets/pages/confirm_dialog.dart';

class EditGroupPage extends StatefulWidget {
  const EditGroupPage({super.key});

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  Group selectedGroup = DataController.to.currentGroup;
  late final controller = TextEditingController(text: selectedGroup.title);
  bool showEmojiPicker = false;

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmojiPicker = false;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("编辑分组"),
      ),
      body: GetBuilder<DataController>(
        init: DataController.to,
        builder: (_) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildGroupChoicer(),
                    SizedBox(height: 24),
                    buildEditBar(),
                  ],
                ),
              ),
              Expanded(child: SizedBox()),
              if (showEmojiPicker)
                EmojiPicker(
                  config: Config(
                    bottomActionBarConfig: BottomActionBarConfig(enabled: false),
                  ),
                  onEmojiSelected: (category, emoji) {
                    DataController.to.changeGroupIcon(selectedGroup, emoji.emoji);
                    setState(() {});
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Wrap buildGroupChoicer() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final group in DataController.to.groups)
          RawChip(
            avatar: Text(group.icon),
            label: Text(group.title),
            selected: selectedGroup == group,
            onPressed: () {
              selectedGroup = group;
              controller.text = selectedGroup.title;
              setState(() {});
            },
          ),
        RawChip(
          avatar: Icon(Icons.add),
          label: Text("新增"),
          onPressed: () {
            selectedGroup = DataController.to.addGroup();
            controller.text = selectedGroup.title;
            setState(() {});
          },
        ),
      ],
    );
  }

  Row buildEditBar() {
    final dc = DataController.to;
    return Row(
      children: [
        IconButton.outlined(
          icon: Text(selectedGroup.icon, style: TextStyle(fontSize: 24)),
          onPressed: () {
            showEmojiPicker = !showEmojiPicker;
            focusNode.unfocus();
            setState(() {});
          },
        ),
        const SizedBox(width: 24),
        Expanded(
          child: TextField(
            focusNode: focusNode,
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "分组名",
              border: OutlineInputBorder(),
              suffixIcon: Helper.if_(
                selectedGroup.title != controller.text,
                IconButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      dc.changeGroupTitle(selectedGroup, controller.text);
                      setState(() {});
                    }
                  },
                  icon: Icon(Icons.check),
                ),
              ),
            ),
            onTap: () {
              showEmojiPicker = false;
              setState(() {});
            },
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        if (selectedGroup != dc.groups.first)
          IconButton(
            onPressed: () async {
              final c = selectedGroup.taskIds.length;
              final r = await ConfirmDialog.show(
                context: context,
                content: c == 0 ? "是否删除 ${selectedGroup.title}" : "该分组 (${selectedGroup.title}) 下还有 $c 个任务，确定删除？",
              );
              if (r == true) {
                final willDelete = selectedGroup;
                selectedGroup = dc.groups.first;
                controller.text = selectedGroup.title;

                dc.deleteGroup(willDelete);
              }
            },
            icon: Icon(Icons.delete),
          ),
      ],
    );
  }
}
