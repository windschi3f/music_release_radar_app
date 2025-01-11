import 'package:music_release_radar_app/spotify/model/image.dart';

class SpotifyPlaylist {
  final String id;
  final String name;
  final String description;
  final List<Image> images;
  final bool isPublic;
  final int trackCount;

  SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.isPublic,
    required this.trackCount,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => Image.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPublic: json['public'] as bool,
      trackCount: json['tracks']['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images.map((e) => e.toJson()).toList(),
      'public': isPublic,
      'tracks': {'total': trackCount},
    };
  }
}
