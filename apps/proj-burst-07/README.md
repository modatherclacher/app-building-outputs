# Random Picker

A small Flutter app that picks N random names from an editable list with no repeats.
Add, rename, or delete names, choose how many to draw with the stepper, and tap Pick —
each draw never repeats a name because picked names are removed from the working pool.
All state is in-memory (a ChangeNotifier), so the list resets when the app restarts.

Run it with `flutter run` from this directory. Run the tests with `flutter test`.
