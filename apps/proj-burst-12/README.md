# Streak Days

A compact Flutter (Material 3) day-streak tracker. Tap "Mark today done" each day
to keep your streak alive — the flame indicator grows larger and hotter as your
streak grows, your all-time best streak is recorded automatically, and a week
strip shows the last 7 days of check-ins. Missing a day resets the current streak
(but never the best record); the app-bar action starts a fresh run.

State is in-memory (ChangeNotifier) and follows the system light/dark theme.

Run it: `flutter pub get && flutter run` — or run tests with `flutter test`.
