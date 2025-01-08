class Image {
  final String url;
  final int? height;
  final int? width;

  Image({
    required this.url,
    this.height,
    this.width,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      url: json['url'] as String,
      height: json['height'] as int?,
      width: json['width'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'height': height,
      'width': width,
    };
  }

  @override
  String toString() {
    return 'Image(url: $url, height: $height, width: $width)';
  }
}
