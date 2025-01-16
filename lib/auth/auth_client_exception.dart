class AuthClientException implements Exception {
  final String message;
  AuthClientException(this.message);

  @override
  String toString() => message;
}
