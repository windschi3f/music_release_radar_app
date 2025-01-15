import 'package:music_release_radar_app/spotify/model/image.dart';
import 'package:music_release_radar_app/spotify/model/spotify_artist.dart';

class SpotifyAlbum {
  final String albumType;
  final int totalTracks;
  final List<String> availableMarkets;
  final String href;
  final String id;
  final List<Image> images;
  final String name;
  final String releaseDate;
  final String releaseDatePrecision;
  final String type;
  final String uri;
  final List<SpotifyArtist> artists;

  SpotifyAlbum({
    required this.albumType,
    required this.totalTracks,
    required this.availableMarkets,
    required this.href,
    required this.id,
    required this.images,
    required this.name,
    required this.releaseDate,
    required this.releaseDatePrecision,
    required this.type,
    required this.uri,
    required this.artists,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    return SpotifyAlbum(
      albumType: json['album_type'],
      totalTracks: json['total_tracks'],
      availableMarkets: List<String>.from(json['available_markets']),
      href: json['href'],
      id: json['id'],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      name: json['name'],
      releaseDate: json['release_date'],
      releaseDatePrecision: json['release_date_precision'],
      type: json['type'],
      uri: json['uri'],
      artists: (json['artists'] as List<dynamic>)
          .map((e) => SpotifyArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
