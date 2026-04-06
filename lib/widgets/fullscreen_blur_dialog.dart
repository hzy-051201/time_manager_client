import 'dart:ui';

import 'package:flutter/material.dart';

class FullscreenBlurDialog extends StatelessWidget {
  final Widget child;
  final double availableRatio;

  const FullscreenBlurDialog({super.key, required this.child, this.availableRatio = 0.8});

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Center(
            child: SizedBox.fromSize(size: MediaQuery.of(context).size * availableRatio, child: child),
          ),
        ),
      );
}
