import 'package:music_release_radar_app/spotify/model/image.dart';

class SpotifyArtist {
  final String id;
  final String name;
  final List<Image> images;
  final int popularity;
  final int followerCount;
  final List<String> genres;

  SpotifyArtist({
    required this.id,
    required this.name,
    required this.images,
    required this.popularity,
    required this.followerCount,
    required this.genres,
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    return SpotifyArtist(
      id: json['id'] as String,
      name: json['name'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => Image.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularity: json['popularity'] as int,
      followerCount: json['followers']['total'] as int,
      genres: (json['genres'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': images.map((e) => e.toJson()).toList(),
      'popularity': popularity,
      'followers': {'total': followerCount},
      'genres': genres,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpotifyArtist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
