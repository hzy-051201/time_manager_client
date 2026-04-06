import 'dart:math';

import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class Helper {
  static T? if_<T>(bool condition, T? thing, [T? other]) => condition ? thing : other;

  static Future<T?> showModalBottomSheetWithTextField<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        // useRootNavigator: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: child,
            ),
          );
        },
      );

  static Future<T?> showModalBottomSheetSimple<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        // useRootNavigator: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        builder: (BuildContext context) => LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: constraints.maxHeight * 3 / 4,
            child: child,
          ),
        ),
      );

  static Future<(DateTime, DateTime?)?> showDateTimeRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final r = await showOmniDateTimeRangePicker(
      context: context,
      is24HourMode: true,
      isShowSeconds: true,
      startInitialDate: now,
      endInitialDate: now,
    );
    if (r == null || r.length != 2) return null;
    if (r[1].difference(r[0]).inSeconds < 2 || r[1].difference(now).inSeconds < 2) return (r[0], null);
    return (r[0], r[1]);
  }

  static Future<DateTime?> showDateTimePicker(BuildContext context, {DateTime? initialDate}) => showOmniDateTimePicker(
        context: context,
        is24HourMode: true,
        isShowSeconds: true,
        initialDate: initialDate,
      );

  static Iterable<(R, S, T?)> zip<R, S, T>(Iterable<R> r, Iterable<S> s, [Iterable<T>? t]) sync* {
    for (int i = 0; i < min(r.length, s.length); i++) {
      yield (r.elementAt(i), s.elementAt(i), t?.elementAt(i));
    }
    return;
  }

  static Iterable<(int, T)> enumerate<T>(Iterable<T> iterable) sync* {
    int i = 0;
    for (final e in iterable) {
      yield (i, e);
      i++;
    }
  }

  static Color? fromHexString(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";

    final r = int.tryParse(hexColor, radix: 16);
    if (r == null) return null;
    return Color(r);
  }

  static final _phoneNumberPrefix = ["+", "86"];
  static int? formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null) return null;

    for (var p in _phoneNumberPrefix) {
      if (phoneNumber!.startsWith(p)) {
        phoneNumber = phoneNumber.substring(p.length);
        return formatPhoneNumber(phoneNumber);
      }
    }

    return int.tryParse(phoneNumber!.trim());
  }

  static const _defaultCardLoadingThemeDark = CardLoadingTheme(
    colorOne: Color.fromARGB(255, 56, 56, 56),
    colorTwo: Color.fromARGB(255, 46, 45, 45),
  );

  static CardLoading cardLoading({
    required BuildContext context,
    required double height,
    double? width,
  }) =>
      CardLoading(
        height: height,
        width: width,
        borderRadius: BorderRadius.circular(8),
        cardLoadingTheme: Theme.of(context).brightness == Brightness.dark ? _defaultCardLoadingThemeDark : CardLoadingTheme.defaultTheme,
      );

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
