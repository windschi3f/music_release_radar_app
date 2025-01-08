import 'package:music_release_radar_app/spotify/model/image.dart';

class SpotifyUser {
  final String id;
  final String displayName;
  final int followerCount;
  final String href;
  final List<Image> images;
  final String type;
  final String uri;

  SpotifyUser({
    required this.id,
    required this.displayName,
    required this.followerCount,
    required this.href,
    required this.images,
    required this.type,
    required this.uri,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    return SpotifyUser(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      followerCount:
          (json['followers'] as Map<String, dynamic>)['total'] as int,
      href: json['href'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => Image.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: json['type'] as String,
      uri: json['uri'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'followers': {'total': followerCount},
      'href': href,
      'images': images.map((e) => e.toJson()).toList(),
      'type': type,
      'uri': uri,
    };
  }
}
