extension DurationExt on Duration? {
  String toStringNoMs() {
    if (this == null) {
      return '00:00';
    }

    var microseconds = this!.inMicroseconds;

    var hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);

    if (microseconds < 0) microseconds = -microseconds;

    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

    var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

    var secondsPadding = seconds < 10 ? "0" : "";

    var str = "$minutesPadding$minutes:"
        "$secondsPadding$seconds";
    if (hours > 0) {
      return "$hours:$str";
    }
    return str;
  }
}
