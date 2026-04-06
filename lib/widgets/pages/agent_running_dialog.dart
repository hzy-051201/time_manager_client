import 'dart:convert';
import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/repository/box.dart';
import 'package:time_manager_client/data/repository/logger.dart';
import 'package:time_manager_client/data/types/auto_task.dart';
import 'package:time_manager_client/data/types/task.dart';
import 'package:time_manager_client/widgets/fullscreen_blur_dialog.dart';
import 'package:xterm/core.dart';
import 'package:xterm/ui.dart';

class AgentRunningDialog extends StatefulWidget {
  final Task task;
  final bool needRun;
  const AgentRunningDialog(this.task, {super.key, this.needRun = false});

  @override
  State<AgentRunningDialog> createState() => _AgentRunningDialogState();
}

class _AgentRunningDialogState extends State<AgentRunningDialog> {
  late final textTheme = Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white);
  final terminal = Terminal();
  Process? process;
  bool isRunning = false;
  bool isPrepare = false;

  AutoTask get _autoTask => widget.task.autoTask!;

  @override
  void initState() {
    super.initState();
    var log = widget.task.autoTask!.log;
    if (log.length > AutoTask.maxLogLength) {
      log = log.substring(log.length - AutoTask.maxLogLength);
    }
    terminal.write(log.replaceAll(RegExp(r"(?<!\r)\n"), "\r\n"));
  }

  @override
  Widget build(BuildContext context) {
    return FullscreenBlurDialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(),
          SizedBox(height: 16),
          buildTask(),
          SizedBox(height: 32),
          Expanded(
            child: TerminalView(
              terminal,
              backgroundOpacity: 0,
              readOnly: true,
              autoResize: true,
            ),
            // child: Placeholder(),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in _autoTask.filePathFromLog)
                  if (File(p).existsSync())
                    GestureDetector(
                      onTap: () async => await OpenFile.open(p),
                      child: Tooltip(
                        message: p,
                        child: Card(
                          child: Row(
                            children: [
                              FileIcon(p),
                              Text(p.split("/").last, style: textTheme.bodyMedium),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildTask() {
    final ws = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.task.title, style: textTheme.titleMedium),
        Text(widget.task.summary!, style: textTheme.bodyMedium),
      ],
    );
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(24),
        borderRadius: BorderRadius.circular(8),
        // gradient: SweepGradient(
        //   colors: Colors.accents,
        //   // startAngle: t
        // ),
      ),
      child: ws,
    );
  }

  Row buildHeader() {
    final state = isRunning ? AutoTaskState.running : widget.task.autoTask!.state;
    return Row(
      children: [
        Icon(state.icon, size: 32),
        SizedBox(width: 16),
        Text(state.text, style: textTheme.headlineMedium),
        Expanded(child: SizedBox()),
        IconButton(
          onPressed: () async {
            if (isPrepare) return;

            if (isRunning) {
              isPrepare = true;
              setState(() {});
              if (!(process?.kill(ProcessSignal.sigkill) == false)) {
                isPrepare = false;
                isRunning = false;
                setState(() {});
              }
              terminal.write("已尝试终止Agent: ${await process?.exitCode}\n");
            } else {
              _autoTask.log = '';

              isPrepare = true;
              setState(() {});
              final s = await startAutoTask();
              if (!s) {
                terminal.write("启动Agent失败");
                return;
              }
              await waitKeywords(["Load environment..."]);
              isPrepare = false;
              isRunning = true;
              setState(() {});

              runAutoTask();
              await waitKeywords(["Session ended", " __main__:cleanup"]);
              bool success = await waitKeywords(["Tool 'terminate' completed its mission!"], timeout: 60);

              isRunning = false;

              var log = terminal.buffer.getText();
              if (log.length > 1024 * 8) {
                log = log.substring(log.length - 2048 * 8);
              }
              widget.task.autoTask!.log = log;
              widget.task.autoTask!.successed = success;
              widget.task.autoTask!.executed = true;
              setState(() {});
              DataController.to.updateTask(widget.task);

              // DataController.to.changeTaskAutoTask(widget.task, widget.task.autoTask!.copy()..demand = terminal.buffer.getText());
            }
          },
          icon: isPrepare
              ? CircularProgressIndicator()
              : isRunning
                  ? Icon(Icons.stop_rounded, size: 32, color: Colors.orange)
                  : Icon(Icons.play_arrow_rounded, size: 32, color: Colors.green),
        ),
      ],
    );
  }

  Future<bool> startAutoTask() async {
    final codePath = await Box.setting.read("agentLocation");
    if (codePath == null || codePath.isEmpty || !Directory(codePath).existsSync()) {
      Get.snackbar("错误", "无法找到Agent");
      return false;
    }

    void Function(List<int>)? processOutFunc;
    if (Platform.isWindows) {
      processOutFunc = handleProcessOutput(handleProcessOutputOnWindows);
    } else if (Platform.isLinux || Platform.isMacOS) {
      processOutFunc = handleProcessOutput(handleProcessOutputOnUnix);
    } else {
      Get.snackbar("错误", "不支持的操作系统");
      return false;
    }

    process = await Process.start("bash", [], workingDirectory: codePath);
    process!.stdout.listen(processOutFunc);
    process!.stderr.listen(processOutFunc);
    process!.stdin.writeln("conda run -n open_manus python -c 'print(\"\"\"Load environment...\"\"\")'");
    return true;
  }

  String handleProcessOutputOnUnix(List<int> cs) => Utf8Decoder().convert(cs).replaceAll("\n", "\r\n");
  String handleProcessOutputOnWindows(List<int> cs) => Utf8Decoder().convert(cs);
  void Function(List<int>) handleProcessOutput(String Function(List<int>) func) => (List<int> cs) {
        final s = func(cs);
        terminal.write(s);
        _autoTask.log += s;
        if (_autoTask.log.length > AutoTask.maxLogLength) {
          _autoTask.log = _autoTask.log.substring(_autoTask.log.length - AutoTask.maxLogLength);
        }
      };

  void runAutoTask() {
    process!.stdin.writeln("conda run -n open_manus --live-stream python ./run_mcp.py -p ${widget.task.autoTask!.demandWithCaveat}");
    // process!.stdin.writeln("conda run -n open_manus --live-stream python -c \"import time;time.sleep(10);print('FIN')\"");
  }

  Future<bool> waitKeywords(List<String> keywords, {int timeout = 900}) async {
    final start = DateTime.now();
    while (true) {
      final now = DateTime.now();
      if (now.difference(start).inSeconds > timeout) {
        return false;
      }

      for (final keyword in keywords) {
        if (_autoTask.log.contains(keyword)) {
          return true;
        }
      }
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  @override
  void dispose() {
    final r = process?.kill(ProcessSignal.sigkill);
    logger.d("Kill terminal: $r");
    super.dispose();
  }
}
