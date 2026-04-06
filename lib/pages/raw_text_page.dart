import 'package:flutter/material.dart';

class RawTextPage extends StatelessWidget {
  const RawTextPage({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: SelectableText(content),
    );
  }
}
