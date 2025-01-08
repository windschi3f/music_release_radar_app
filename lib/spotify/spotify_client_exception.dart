class SpotifyClientException implements Exception {
  final String message;
  SpotifyClientException(this.message);

  @override
  String toString() => message;
}
