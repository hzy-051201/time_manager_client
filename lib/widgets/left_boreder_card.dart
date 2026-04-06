import 'package:flutter/material.dart';

class LeftBorederCard extends StatelessWidget {
  const LeftBorederCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.inversePrimary,
              width: 4,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
