import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinkText extends StatelessWidget {
  const LinkText(this.text, {super.key, this.maxLines = 40});

  final String text;
  final int? maxLines;

  static const _addBlank = "()（）";

  @override
  Widget build(BuildContext context) {
    String txt = text;
    for (final c in _addBlank.split("")) {
      txt = txt.replaceAll(c, " $c ");
    }

    final linked = linkify(txt);
    final color = Theme.of(context).colorScheme.primary;
    final bodyMedium = Theme.of(context).textTheme.bodyMedium;
    return RichText(
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
            style: bodyMedium,
            children: linked
                .map(
                  (e) => switch (e) {
                    LinkableElement _ => TextSpan(
                        text: e.text,
                        style: bodyMedium?.copyWith(color: color),
                        recognizer: TapGestureRecognizer()..onTap = () => launchUrlString(e.url),
                      ),
                    _ => TextSpan(text: e.text)
                  },
                )
                .toList()));
  }
}
