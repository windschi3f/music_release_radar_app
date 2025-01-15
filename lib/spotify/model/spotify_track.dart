import 'package:music_release_radar_app/spotify/model/spotify_album.dart';
import 'package:music_release_radar_app/spotify/model/spotify_artist.dart';

class SpotifyTrack {
  final SpotifyAlbum album;
  final List<SpotifyArtist> artists;
  final List<String> availableMarkets;
  final int discNumber;
  final int durationMs;
  final bool explicit;
  final String href;
  final String id;
  final String name;
  final int popularity;
  final int trackNumber;
  final String type;
  final String uri;
  final bool isLocal;

  SpotifyTrack({
    required this.album,
    required this.artists,
    required this.availableMarkets,
    required this.discNumber,
    required this.durationMs,
    required this.explicit,
    required this.href,
    required this.id,
    required this.name,
    required this.popularity,
    required this.trackNumber,
    required this.type,
    required this.uri,
    required this.isLocal,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      album: SpotifyAlbum.fromJson(json['album']),
      artists: (json['artists'] as List<dynamic>)
          .map((e) => SpotifyArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableMarkets: List<String>.from(json['available_markets']),
      discNumber: json['disc_number'],
      durationMs: json['duration_ms'],
      explicit: json['explicit'],
      href: json['href'],
      id: json['id'],
      name: json['name'],
      popularity: json['popularity'],
      trackNumber: json['track_number'],
      type: json['type'],
      uri: json['uri'],
      isLocal: json['is_local'],
    );
  }
}
