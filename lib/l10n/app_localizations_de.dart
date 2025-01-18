import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get helloWorld => 'Hallo Welt!';

  @override
  String get loading => 'laden';

  @override
  String get deleting => 'löschen';

  @override
  String get executing => 'ausführen';

  @override
  String get processing => 'verarbeiten';

  @override
  String errorOccurred(Object action) {
    return 'Ein Fehler ist aufgetreten beim $action der Aufgabe.';
  }

  @override
  String get tasks => 'Aufgaben';

  @override
  String get logout => 'Abmelden';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get executeNow => 'Jetzt ausführen';

  @override
  String get editTask => 'Aufgabe bearbeiten';

  @override
  String get deleteTask => 'Aufgabe löschen';

  @override
  String deleteTaskConfirmation(Object taskName) {
    return 'Sind Sie sicher, dass Sie $taskName löschen möchten?';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get never => 'nie';

  @override
  String get addedTracks => 'Hinzugefügte Titel';

  @override
  String get trackingArtists => 'Künstler verfolgen';

  @override
  String get lastExecuted => 'Zuletzt ausgeführt';

  @override
  String get checkFrom => 'Überprüfen ab';

  @override
  String get executionInterval => 'Ausführungsintervall';

  @override
  String everyDays(Object days) {
    return 'Alle $days Tage';
  }

  @override
  String get updateTask => 'Aufgabe aktualisieren';

  @override
  String get createTask => 'Aufgabe erstellen';

  @override
  String get name => 'Name';

  @override
  String get executionIntervalDays => 'Ausführungsintervall Tage';

  @override
  String get nameRequired => 'Name ist erforderlich';

  @override
  String get executionIntervalPositive => 'Das Ausführungsintervall muss eine positive Zahl sein';

  @override
  String get selectArtists => 'Künstler auswählen';

  @override
  String get searchArtists => 'Künstler suchen...';

  @override
  String get loadingFailed => 'Laden fehlgeschlagen';

  @override
  String get loginWithSpotify => 'Mit Spotify anmelden';
}
