import 'package:fixnum/fixnum.dart' as fixnum;

extension DateTimeEx on DateTime {
  String formatWithPrecision(int precision) {
    final l = [year, month, day, hour, minute, second];
    const s = "-- ::x";
    final r = List.generate(precision + 1, (i) => i).map((i) => "${l[i].toString().padLeft(2, "0")}${s[i]}").join();
    return r.substring(0, r.length - 1);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isDayAfter(DateTime other) {
    return year > other.year || (year == other.year && month > other.month) || (year == other.year && month == other.month && day > other.day);
  }
}

extension IntEx on int {
  fixnum.Int64 toInt64() => fixnum.Int64(this);
}

extension Int64Ex on fixnum.Int64 {
  DateTime toDateTime() {
    final milliseconds = toInt();
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}

extension MapEx<K, V> on Map<K, V> {
  void cover(Map<K, V?> m) {
    m.forEach((k, v) {
      if (v != null) {
        this[k] = v;
      } else {
        remove(k);
      }
    });
  }
}

extension IntIterableEx on Iterable<int> {
  int min() => reduce((value, element) => value < element ? value : element);
  int max() => reduce((value, element) => value > element ? value : element);
}
