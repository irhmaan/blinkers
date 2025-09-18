// In this, we get the current time as soon as the app is started.
// After that, create function that checks if 20 min is passed or not.
// if passed, then show alert dialog to the user to shift focus from screen to away.
// weather this dialog should be aggressive or not, will be as per user input.
// On this, if user selects aggressive, then app will not allow user to use the app until user confirms to take break.
// If user selects non-aggressive, then app will show dialog, but user can ignore it and continue using the app or minimize it.

class GetCurrentTime {
  late DateTime? lastBreakTime;
  static String getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    return formattedTime;
  }

  void checkIfBreakNeeded() {
    // get the current time
    // compare it with the last break time
    // if 20 min is passed, then show alert dialog

    DateTime now = DateTime.now();
    if (lastBreakTime == null) {
      lastBreakTime = now;
      return;
    }
    Duration difference = now.difference(lastBreakTime!);
    if (difference.inMinutes >= 20) {
      // show alert dialog
      // if aggressive, then block the app until user confirms to take break
      // if non-aggressive, then show dialog, but user can ignore it and continue using the app or minimize it.
      lastBreakTime = now; // reset the last break time
    }
  }
}
