class TaskClientException implements Exception {
  final String message;
  TaskClientException(this.message);

  @override
  String toString() => message;
}
