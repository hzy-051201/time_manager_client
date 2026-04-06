import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';
import 'package:time_manager_client/data/controller/data_controller.dart';
import 'package:time_manager_client/data/repository/network_ai.dart';
import 'package:time_manager_client/widgets/pages/ai_chat_dialog.dart';

/// 桌宠组件 - 循环播放动画视频
/// 支持双击打开AI助手对话框，可拖拽移动，显示鼓励气泡
class DesktopPet extends StatefulWidget {
  const DesktopPet({super.key});

  @override
  State<DesktopPet> createState() => _DesktopPetState();
}

class _DesktopPetState extends State<DesktopPet> {
  // 桌宠状态
  PetState _currentPetState = PetState.idle;

  // 位置
  Offset _position = const Offset(50, 50);

  // 是否正在拖拽
  bool _isDragging = false;

  // 点击计数（用于双击检测）
  int _clickCount = 0;

  // 视频控制器
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoLoading = true;

  // Widget生命周期标志
  bool _isMounted = true;

  // 加载控制
  bool _isLoading = false;
  Completer<void>? _loadCompleter;

  // 动画循环定时器
  Timer? _animationTimer;

  // 防抖：记录上次切换时间
  DateTime? _lastSwitchTime;

  // 当前加载的路径
  String? _currentLoadedPath;

  // 鼓励气泡相关
  String _encouragementText = '';
  bool _showBubble = false;
  Timer? _bubbleTimer;
  Timer? _encouragementTimer;
  int _encouragementCount = 0;
  final DataController _controller = DataController.to;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadFirstVideo();
    _startAnimationCycle();
    _startEncouragementCycle();
  }

  @override
  void dispose() {
    debugPrint('🗑️ DesktopPet dispose 开始');
    _isMounted = false;

    // 立即取消所有定时器
    _animationTimer?.cancel();
    _animationTimer = null;
    _bubbleTimer?.cancel();
    _bubbleTimer = null;
    _encouragementTimer?.cancel();
    _encouragementTimer = null;

    // 停止加载
    if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
      _loadCompleter!.complete();
    }

    // 立即清理控制器（同步操作）
    final controller = _videoController;
    _videoController = null;
    _isVideoInitialized = false;
    _isVideoLoading = false;

    if (controller != null) {
      try {
        controller.removeListener(() {});
        controller.pause();
        controller.dispose();
        debugPrint('✅ 视频控制器已释放');
      } catch (e) {
        debugPrint('⚠️ 释放视频控制器时出错: $e');
      }
    }

    super.dispose();
    debugPrint('✅ DesktopPet dispose 完成');
  }

  /// 加载第一个视频
  Future<void> _loadFirstVideo() async {
    if (!_isMounted) return;
    await _loadVideo(_currentPetState);
  }

  /// 加载指定状态的视频
  Future<void> _loadVideo(PetState state) async {
    // 检查Widget是否仍然有效
    if (!_isMounted) {
      debugPrint('⚠️ Widget已销毁，停止加载');
      return;
    }

    // 检查是否正在加载
    if (_isLoading && _loadCompleter != null && !_loadCompleter!.isCompleted) {
      debugPrint('⏳ 正在加载中，跳过重复请求');
      await _loadCompleter!.future;
      return;
    }

    // 防抖检查
    final now = DateTime.now();
    if (_lastSwitchTime != null &&
        now.difference(_lastSwitchTime!) < const Duration(seconds: 2)) {
      debugPrint('⏳ 跳过频繁切换');
      return;
    }

    _lastSwitchTime = now;
    _isLoading = true;
    _loadCompleter = Completer<void>();

    // 获取视频路径
    final videoPath = _getVideoPath(state);

    // 检查是否已经加载了相同的视频
    if (_currentLoadedPath == videoPath && _isVideoInitialized) {
      debugPrint('✅ 视频已加载，跳过: $videoPath');
      _isLoading = false;
      _loadCompleter!.complete();
      return;
    }

    // 立即更新UI状态
    if (_isMounted) {
      setState(() {
        _isVideoInitialized = false;
        _isVideoLoading = true;
      });
    } else {
      _isLoading = false;
      _loadCompleter!.complete();
      return;
    }

    debugPrint('🎬 开始加载视频: $videoPath');

    // 释放旧控制器
    await _disposeController();

    // 检查是否在释放后Widget仍然有效
    if (!_isMounted) {
      _isLoading = false;
      _loadCompleter!.complete();
      return;
    }

    // 创建新控制器
    VideoPlayerController? newController;

    try {
      // Windows平台视频播放限制较多，添加超时保护
      newController = VideoPlayerController.asset(videoPath);

      // 设置5秒超时
      await newController.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⏱️ 视频初始化超时');
          throw TimeoutException('视频初始化超时');
        },
      );

      // 添加监听器
      final listener = () {
        if (newController != null && newController.value.hasError) {
          debugPrint('❌ 视频播放错误: ${newController.value.errorDescription}');
        }
      };
      newController.addListener(listener);

      // 初始化视频
      await newController.initialize();

      // 再次检查Widget状态
      if (!_isMounted) {
        try {
          newController.removeListener(listener);
          newController.dispose();
        } catch (e) {
          debugPrint('⚠️ 清理控制器时出错: $e');
        }
        _isLoading = false;
        _loadCompleter!.complete();
        return;
      }

      debugPrint('✅ 视频初始化成功: ${newController.value.size}');

      // 设置循环播放
      await newController.setLooping(true);

      // 开始播放
      await newController.play();

      // 最终检查并更新状态
      if (_isMounted) {
        setState(() {
          _videoController = newController;
          _isVideoInitialized = true;
          _isVideoLoading = false;
          _currentLoadedPath = videoPath;
        });
        debugPrint('✅ 视频播放成功: $videoPath');
      } else {
        try {
          newController.removeListener(listener);
          newController.dispose();
        } catch (e) {
          debugPrint('⚠️ 清理控制器时出错: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ 视频加载失败: $e');
      debugPrint('❌ 视频路径: $videoPath');

      // 清理可能创建的控制器
      if (newController != null) {
        try {
          newController.dispose();
        } catch (disposeError) {
          debugPrint('⚠️ 清理控制器时出错: $disposeError');
        }
      }

      if (_isMounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    } finally {
      _isLoading = false;
      _loadCompleter!.complete();
    }
  }

  /// 释放控制器
  Future<void> _disposeController() async {
    final controller = _videoController;
    _videoController = null;
    _isVideoInitialized = false;
    _currentLoadedPath = null;

    if (controller != null) {
      try {
        controller.removeListener(() {});
        controller.pause();
        await controller.dispose();
        debugPrint('✅ 旧控制器已释放');
      } catch (e) {
        debugPrint('⚠️ 释放控制器时出错（可忽略）: $e');
      }
    }
  }

  /// 获取当前状态的视频路径
  String _getVideoPath(PetState state) {
    switch (state) {
      case PetState.idle:
        return 'assets/animations/idle.mp4';
      case PetState.sleep:
        return 'assets/animations/sleep.mp4';
      case PetState.stretch:
        return 'assets/animations/Stretch.mp4';
    }
  }

  /// 开始动画循环
  void _startAnimationCycle() {
    _animationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // 检查Widget状态
      if (!_isMounted) {
        timer.cancel();
        return;
      }

      // 获取下一个状态
      final nextState = _getNextPetState();

      // 只在状态不同且没有正在加载时切换
      if (nextState != _currentPetState && !_isLoading) {
        // 先更新状态
        if (_isMounted) {
          setState(() {
            _currentPetState = nextState;
          });
        }

        // 使用SchedulerBinding确保在下一帧加载
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          if (_isMounted && !_isLoading) {
            await _loadVideo(_currentPetState);
          }
        });
      }
    });
  }

  /// 开始鼓励循环
  void _startEncouragementCycle() {
    // 每30秒获取一次鼓励
    _encouragementTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isMounted) {
        timer.cancel();
        return;
      }
      _fetchEncouragement();
    });

    // 首次立即获取
    Future.delayed(const Duration(seconds: 3), () {
      if (_isMounted) {
        _fetchEncouragement();
      }
    });
  }

  /// 获取鼓励话语
  Future<void> _fetchEncouragement() async {
    if (!_isMounted) return;

    try {
      // 获取任务完成情况
      final tasks = _controller.tasks.toList();
      final finishedTasks =
          tasks.where((t) => t.status.name == 'finished').length;
      final totalTasks = tasks.length;
      final completionRate =
          totalTasks > 0 ? (finishedTasks / totalTasks * 100).round() : 0;

      // 构建上下文信息
      final context = '''当前时间：${DateTime.now().toString()}

任务完成情况：
- 总任务数：$totalTasks
- 已完成：$finishedTasks
- 完成率：$completionRate%

今日任务：
${tasks.take(5).map((t) => '• ${t.title} - ${t.status.name}').join('\n')}''';

      // 调用DeepSeek获取鼓励话语
      final encouragement = await NetworkAi.askAi(
        context,
        '''你是一个温暖、鼓励人心的助手。根据用户当前的任务完成情况，给出简短、积极、鼓励的话语。

要求：
1. 话语要温暖、友好、真诚
2. 根据完成率调整语气：
   - 0-30%：鼓励开始，不要气馁
   - 30-70%：肯定进步，继续加油
   - 70-100%：表扬努力，庆祝成就
3. 长度控制在15-40字之间
4. 用第一人称，像朋友一样说话
5. 不使用表情符号，只纯文字
6. 给出具体的、个性化的鼓励

示例：
"这次进度稍慢，可你没放弃，已经完成XX%，继续加油就好！"
"多次未完成确实让人失落，没关系，我们一起调整节奏就好！"
"你已完成**%的任务，每一步都扎实有力，再坚持下就圆满收官啦！"
"恭喜你顺利完成任务！你认真坚持、一步步做到最好，真的特别棒。你的努力值得被看见，为你点赞，继续闪闪发光吧"

请直接输出鼓励话语，不要任何其他内容。''',
        AiModel.deepseekChat,
      );

      if (encouragement != null && encouragement.isNotEmpty && _isMounted) {
        setState(() {
          _encouragementText = encouragement.trim();
          _showBubble = true;
        });

        // 5秒后隐藏气泡
        _bubbleTimer?.cancel();
        _bubbleTimer = Timer(const Duration(seconds: 5), () {
          if (_isMounted) {
            setState(() {
              _showBubble = false;
            });
          }
        });

        _encouragementCount++;
        debugPrint('💬 获取鼓励话语 #$_encouragementCount: $_encouragementText');
      }
    } catch (e) {
      debugPrint('⚠️ 获取鼓励话语失败: $e');
    }
  }

  /// 获取下一个宠物状态
  PetState _getNextPetState() {
    final states = PetState.values;
    final currentIndex = states.indexOf(_currentPetState);
    final nextIndex = (currentIndex + 1) % states.length;
    return states[nextIndex];
  }

  /// 处理双击事件
  void _handleDoubleTap() {
    _openAiChat();
  }

  /// 打开AI助手对话框
  void _openAiChat() {
    showDialog(
      context: context,
      builder: (context) => const AiChatDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 如果已经disposed，返回空组件
    if (!_isMounted) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 鼓励气泡
          if (_showBubble)
            Positioned(
              left: 150,
              top: -30,
              child: _buildBubble(),
            ),
          // 桌宠主体
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            onPanStart: (details) {
              if (_isMounted) {
                setState(() {
                  _isDragging = true;
                });
              }
            },
            onPanUpdate: (details) {
              if (_isMounted) {
                setState(() {
                  _position += details.delta;
                  final screenSize = MediaQuery.of(context).size;
                  _position = Offset(
                    _position.dx.clamp(0, screenSize.width - 120),
                    _position.dy.clamp(0, screenSize.height - 120),
                  );
                });
              }
            },
            onPanEnd: (details) {
              if (_isMounted) {
                setState(() {
                  _isDragging = false;
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isDragging
                        ? Colors.purple.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Stack(
                  children: [
                    // 宠物视频/Emoji
                    Center(
                      child: _buildPetContent(),
                    ),
                    // 加载指示器
                    if (_isVideoLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    // 提示文字（点击时显示）
                    if (!_isDragging && !_isVideoLoading)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _clickCount > 0 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '双击打开AI助手',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // 拖拽指示器
                    if (_isDragging)
                      const Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(
                          Icons.drag_indicator,
                          size: 16,
                          color: Colors.purple,
                        ),
                      ),
                    // 状态指示器
                    if (!_isVideoInitialized && !_isVideoLoading)
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '视频加载中',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getVideoPath(_currentPetState),
                                style: const TextStyle(
                                  fontSize: 6,
                                  color: Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ], // Stack子元素结束
      ),
    );
  }

  /// 构建鼓励气泡
  Widget _buildBubble() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        minWidth: 120,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.9),
            Colors.pink.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 鼓励文字
          Text(
            _encouragementText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建宠物内容
  Widget _buildPetContent() {
    // 安全检查
    if (!_isMounted) {
      return _buildEmojiContent();
    }

    final controller = _videoController;

    // 多重安全检查
    if (_isVideoInitialized &&
        controller != null &&
        !controller.value.hasError &&
        controller.value.isInitialized) {
      try {
        // 使用Builder确保在正确的上下文中访问controller
        return Builder(
          builder: (context) {
            try {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: 100,
                  height: 100,
                  key: ValueKey('video_$_currentPetState'),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              );
            } catch (e) {
              debugPrint('⚠️ 渲染视频时出错，显示Emoji: $e');
              return _buildEmojiContent();
            }
          },
        );
      } catch (e) {
        debugPrint('⚠️ 构建视频组件时出错，显示Emoji: $e');
        return _buildEmojiContent();
      }
    } else {
      // 视频未初始化时显示Emoji
      return _buildEmojiContent();
    }
  }

  /// 构建空白内容（视频加载失败时显示）
  Widget _buildEmojiContent() {
    return const SizedBox.shrink();
  }
}

/// 宠物状态枚举
enum PetState {
  /// 闲置状态
  idle,

  /// 睡眠状态
  sleep,

  /// 伸展状态
  stretch,
}
