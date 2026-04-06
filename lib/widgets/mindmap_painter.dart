import 'package:flutter/material.dart';
import 'dart:math'; // 引入数学库

class MindmapPainter extends StatelessWidget {
  final String parentNode;
  final List<String> childNodes;

  const MindmapPainter(this.parentNode, this.childNodes, {super.key});

  @override
  Widget build(BuildContext context) {
    List<String> childs = childNodes;
    if (childs.length > 3) {
      childs = childs.sublist(0, 3);
      childs.add("...");
    }
    return CustomPaint(
      painter: _MindMapPainter(
        parentNode: parentNode,
        childNodes: childs,
        lineColor: Theme.of(context).colorScheme.inversePrimary,
        textStyle: Theme.of(context).textTheme.bodyMedium!,
        radius: 8.0,
        padding: 4.0,
        curveHeight: 50.0, // 默认弧度高度
        bendFactor: 0.33, // 默认弯曲分布系数
      ),
    );
  }
}

class _MindMapPainter extends CustomPainter {
  final String parentNode;
  final List<String> childNodes;
  final Color lineColor;
  final TextStyle textStyle;
  final double radius;
  final double padding;
  final double curveHeight; // 曲线最大弧度高度
  final double bendFactor; // 弯曲分布系数

  _MindMapPainter({
    required this.parentNode,
    required this.childNodes,
    required this.lineColor,
    required this.textStyle,
    this.radius = 8.0,
    this.padding = 2.0,
    this.curveHeight = 50.0,
    this.bendFactor = 0.33,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final painter = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 计算可用宽度和最大宽度限制
    final availableWidth = size.width;
    final maxWidthParent = availableWidth * 0.35;
    final maxWidthChild = availableWidth * 0.45;

    // 父节点文本测量
    TextSpan parentSpan = TextSpan(text: parentNode, style: textStyle);
    TextPainter parentTextPainter = TextPainter(
      text: parentSpan,
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '...',
    )..layout(maxWidth: maxWidthParent);

    final parentWidth = parentTextPainter.width + padding * 2;
    final parentHeight = parentTextPainter.height + padding * 2;

    // 父节点居中显示
    final parentX = availableWidth * 0.02;
    final parentY = size.height / 2;

    // 子节点最大宽度和高度计算
    double maxChildWidth = 0;
    double childHeight = 0;
    for (String child in childNodes) {
      TextSpan childSpan = TextSpan(text: child, style: textStyle);
      TextPainter childTextPainter = TextPainter(
        text: childSpan,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: maxWidthChild);

      if (childTextPainter.width + padding * 2 > maxChildWidth) {
        maxChildWidth = childTextPainter.width + padding * 2;
      }
      childHeight = childTextPainter.height + padding * 2;
    }
    maxChildWidth = min(maxChildWidth, maxWidthChild + padding * 2);

    // 父节点位置计算
    final parentRect = Rect.fromLTWH(
      parentX,
      parentY - parentHeight / 2,
      parentWidth,
      parentHeight,
    );
    final parentRRect = RRect.fromRectAndCorners(
      parentRect,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );

    // 绘制父节点圆角矩形和文本
    canvas.drawRRect(parentRRect, painter);
    parentTextPainter.paint(
      canvas,
      Offset(parentRRect.left + padding, parentRRect.top + padding),
    );

    // 子节点布局参数
    const verticalSpacing = 4.0;
    final count = childNodes.length;
    final childX = parentX + parentWidth + 40;

    List<RRect> childRRects = [];
    List<Offset> childCenters = [];
    for (int i = 0; i < count; i++) {
      final childY = parentY + (i - (count ~/ 2)) * (childHeight + verticalSpacing);
      final rect = Rect.fromLTWH(childX, childY, maxChildWidth, childHeight);
      final childRRect = RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
      childRRects.add(childRRect);

      // 绘制子节点圆角矩形和文本
      canvas.drawRRect(childRRect, painter);
      TextSpan childSpan = TextSpan(text: childNodes[i], style: textStyle);
      TextPainter childPainter = TextPainter(
        text: childSpan,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: maxWidthChild);
      childPainter.paint(
        canvas,
        Offset(childRRect.left + padding, childRRect.top + padding),
      );

      // 计算子节点中心点
      final centerX = childRRect.center.dx;
      final centerY = childRRect.center.dy;
      childCenters.add(Offset(centerX, centerY));
    }

    // 绘制曲线连接线
    final parentCenterY = parentY;
    for (int i = 0; i < childRRects.length; i++) {
      final childCenter = childCenters[i];
      final childRRect = childRRects[i];

      final startPoint = Offset(parentRRect.right, parentCenterY);
      final endPoint = Offset(childRRect.left, childCenter.dy);

      // 计算路径向量
      final dx = endPoint.dx - startPoint.dx;
      final dy = endPoint.dy - startPoint.dy;

      // 控制点位置（距离父节点bendFactor处）
      final controlPointX = startPoint.dx + dx * bendFactor;
      final controlPointY = startPoint.dy + dy * bendFactor;

      // 动态弧度高度计算
      final distance = sqrt(dx * dx + dy * dy);
      final scaledCurveHeight = curveHeight * (distance / 200.0).clamp(0.25, 2.0);

      // 根据垂直方向调整偏移方向
      final direction = dy > 0 ? 1 : -1;

      // 最终控制点位置
      final controlY = controlPointY + scaledCurveHeight * direction;
      final controlPoint = Offset(controlPointX, controlY);

      // 使用二次贝塞尔曲线
      Path path = Path()
        ..moveTo(startPoint.dx, startPoint.dy)
        ..quadraticBezierTo(
          controlPoint.dx,
          controlY,
          endPoint.dx,
          endPoint.dy,
        );
      canvas.drawPath(path, painter);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
