import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get loading => 'loading';

  @override
  String get deleting => 'deleting';

  @override
  String get executing => 'executing';

  @override
  String get processing => 'processing';

  @override
  String errorOccurred(Object action) {
    return 'An error occurred while $action the task.';
  }

  @override
  String get tasks => 'Tasks';

  @override
  String get logout => 'Logout';

  @override
  String get retry => 'Retry';

  @override
  String get unknown => 'Unknown';

  @override
  String get executeNow => 'Execute Now';

  @override
  String get editTask => 'Edit Task';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String deleteTaskConfirmation(Object taskName) {
    return 'Are you sure you want to delete $taskName?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get never => 'never';

  @override
  String get addedTracks => 'Added Tracks';

  @override
  String get trackingArtists => 'Tracking Artists';

  @override
  String get lastExecuted => 'Last Executed';

  @override
  String get checkFrom => 'Check From';

  @override
  String get executionInterval => 'Execution Interval';

  @override
  String everyDays(Object days) {
    return 'Every $days days';
  }

  @override
  String get updateTask => 'Update Task';

  @override
  String get createTask => 'Create Task';

  @override
  String get name => 'Name';

  @override
  String get executionIntervalDays => 'Execution Interval Days';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get executionIntervalPositive => 'Execution interval must be a positive number';

  @override
  String get selectArtists => 'Select Artists';

  @override
  String get searchArtists => 'Search artists...';

  @override
  String get loadingFailed => 'Loading failed';

  @override
  String get loginWithSpotify => 'Login with Spotify';
}
