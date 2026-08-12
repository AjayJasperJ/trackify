class ModelParse {
  static String toStr(dynamic v) => (v?.toString() ?? "").trim();

  static int toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is bool) return v ? 1 : 0;
    return int.tryParse(v?.toString() ?? "") ?? 0;
  }

  static double toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is bool) return v ? 1.0 : 0.0;
    return double.tryParse(v?.toString() ?? "") ?? 0.0;
  }

  static bool toBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is double) return v == 1.0;
    final s = v?.toString().toLowerCase().trim();
    return s == "true" || s == "1" || s == "yes" || s == "y";
  }

  static DateTime? toDateNull(dynamic v) {
    if (v is DateTime) return v;
    if (v == null || v.toString().trim().isEmpty) return null;

    String s = v.toString().trim();
    try {
      return DateTime.parse(s);
    } catch (_) {}

    try {
      // Separate date and time if there's a space or 'T'
      String datePart = s;
      String timePart = "00:00:00";
      final splitMatch = RegExp(r'[\sT]').firstMatch(s);
      if (splitMatch != null) {
        datePart = s.substring(0, splitMatch.start);
        timePart = s.substring(splitMatch.start + 1).trim();
      }
      final normalizedDate = datePart.replaceAll(RegExp(r'[/.\\]'), '-');
      final dateParts = normalizedDate.split('-');
      if (dateParts.length >= 3) {
        int p1 = int.parse(dateParts[0]);
        int p2 = int.parse(dateParts[1]);
        int p3 = int.parse(dateParts[2]);
        int y = 0, m = 0, d = 0;
        if (dateParts[0].length == 4) {
          y = p1;
          if (p2 > 12) {
            d = p2;
            m = p3;
          } else {
            m = p2;
            d = p3;
          }
        } else if (dateParts[2].length >= 4) {
          y = p3;
          if (p1 > 12) {
            d = p1;
            m = p2;
          } else if (p2 > 12) {
            m = p1;
            d = p2;
          } else {
            d = p1;
            m = p2;
          }
        }
        if (y > 0 && m > 0 && m <= 12 && d > 0 && d <= 31) {
          int hour = 0, minute = 0, second = 0, millisecond = 0;
          final timeParts = timePart.split(RegExp(r'[:.]'));
          if (timeParts.isNotEmpty) hour = int.tryParse(timeParts[0]) ?? 0;
          if (timeParts.length > 1) minute = int.tryParse(timeParts[1]) ?? 0;
          if (timeParts.length > 2) second = int.tryParse(timeParts[2]) ?? 0;
          if (timeParts.length > 3) {
            millisecond = int.tryParse(timeParts[3]) ?? 0;
          }
          return DateTime(y, m, d, hour, minute, second, millisecond);
        }
      }
    } catch (_) {}

    return null;
  }

  static DateTime toDate(dynamic v) {
    return toDateNull(v) ?? DateTime.now();
  }

  static List<String> toStrList(dynamic v) {
    if (v == null || v is! List) return [];
    return v.map((e) => toStr(e)).toList();
  }

  static List<int> toIntList(dynamic v) {
    if (v == null || v is! List) return [];
    return v.map((e) => toInt(e)).toList();
  }

  static List<double> toDoubleList(dynamic v) {
    if (v == null || v is! List) return [];
    return v.map((e) => toDouble(e)).toList();
  }

  static List<bool> toBoolList(dynamic v) {
    if (v == null || v is! List) return [];
    return v.map((e) => toBool(e)).toList();
  }

  static List<DateTime> toDateList(dynamic v) {
    if (v == null || v is! List) return [];
    return v.map((e) => toDate(e)).toList();
  }

  static T? toModel<T>(dynamic v, T Function(Map<String, dynamic>) fromJson) {
    if (v == null || v is! Map<String, dynamic>) return null;
    try {
      return fromJson(v);
    } catch (_) {
      return null;
    }
  }

  static List<T> toModelList<T>(
    dynamic v,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (v == null || v is! List) return [];
    return v
        .whereType<Map<String, dynamic>>()
        .map((e) {
          try {
            return fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<T>()
        .toList();
  }
}
