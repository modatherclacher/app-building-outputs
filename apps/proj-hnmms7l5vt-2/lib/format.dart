String twoDigits(int n) => n.toString().padLeft(2, '0');

String formatClockDigits(DateTime time) =>
    '${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';

String formatDateLine(DateTime time) =>
    '${weekdayNames[time.weekday - 1]}, ${monthNames[time.month - 1]} ${time.day}';

String formatStopwatch(Duration elapsed) {
  final minutes = elapsed.inMinutes;
  final seconds = twoDigits(elapsed.inSeconds % 60);
  final centiseconds = twoDigits((elapsed.inMilliseconds % 1000) ~/ 10);
  return '$minutes:$seconds.$centiseconds';
}

String formatCountdown(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  return hours > 0
      ? '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}'
      : '${twoDigits(minutes)}:${twoDigits(seconds)}';
}

const List<String> weekdayNames = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
