import 'source.dart';

enum MediaType {
  tv,
  radio,
  webcam;

  String get label {
    switch (this) {
      case MediaType.tv:
        return 'TV';
      case MediaType.radio:
        return 'Radio';
      case MediaType.webcam:
        return 'Webcams';
    }
  }

  static MediaType fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'RADIO':
        return MediaType.radio;
      case 'WEBCAM':
        return MediaType.webcam;
      default:
        return MediaType.tv;
    }
  }
}

enum SortOption {
  nameAsc('Name (A–Z)'),
  nameDesc('Name (Z–A)'),
  liveFirst('Live First'),
  hdFirst('Quality (HD First)'),
  countryAsc('Country (A–Z)'),
  languageAsc('Language (A–Z)');

  final String label;
  const SortOption(this.label);
}

class Channel {
  final String id;
  final String name;
  final String quality;
  final String country;
  final String language;
  final List<Source> sources;
  final String logo;
  final String group;
  final String status;
  final MediaType mediaType;

  const Channel({
    required this.id,
    required this.name,
    this.quality = '',
    this.country = '',
    this.language = '',
    required this.sources,
    this.logo = '',
    this.group = '',
    this.status = '',
    this.mediaType = MediaType.tv,
  });

  Channel copyWith({
    String? id,
    String? name,
    String? quality,
    String? country,
    String? language,
    List<Source>? sources,
    String? logo,
    String? group,
    String? status,
    MediaType? mediaType,
  }) =>
      Channel(
        id: id ?? this.id,
        name: name ?? this.name,
        quality: quality ?? this.quality,
        country: country ?? this.country,
        language: language ?? this.language,
        sources: sources ?? this.sources,
        logo: logo ?? this.logo,
        group: group ?? this.group,
        status: status ?? this.status,
        mediaType: mediaType ?? this.mediaType,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'q': quality,
        'c': country,
        'lang': language,
        'logo': logo,
        'group': group,
        'status': status,
        'mt': mediaType.name.toUpperCase(),
        's': sources.map((s) => s.toJson()).toList(),
      };

  factory Channel.fromJson(Map<String, dynamic> json) {
    final rawSrcs = json['s'] as List<dynamic>? ?? [];
    final sources = rawSrcs
        .map((e) => Source.fromJson(e as Map<String, dynamic>))
        .toList();
    return Channel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quality: json['q'] as String? ?? '',
      country: json['c'] as String? ?? '',
      language: json['lang'] as String? ?? '',
      sources: sources,
      logo: json['logo'] as String? ?? '',
      group: json['group'] as String? ?? '',
      status: json['status'] as String? ?? '',
      mediaType: MediaType.fromString(json['mt'] as String?),
    );
  }
}
