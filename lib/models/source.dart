class Source {
  final String url;
  final String? ua;
  final String? referrer;

  const Source({
    required this.url,
    this.ua,
    this.referrer,
  });

  Map<String, dynamic> toJson() => {
        'u': url,
        if (ua != null) 'ua': ua,
        if (referrer != null) 'r': referrer,
      };

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        url: json['u'] as String? ?? '',
        ua: json['ua'] as String?,
        referrer: json['r'] as String?,
      );
}
