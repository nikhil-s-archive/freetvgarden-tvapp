import '../models/channel.dart';
import '../models/source.dart';

final RegExp _qualityRx = RegExp(r'\s*\((\d{3,4}[pi])\)\s*$');
final RegExp _idRx = RegExp(r'tvg-id="([^"]*)"');
final RegExp _logoRx = RegExp(r'tvg-logo="([^"]*)"');
final RegExp _countryRx = RegExp(r'tvg-country="([^"]*)"');
final RegExp _languageRx = RegExp(r'tvg-language="([^"]*)"');
final RegExp _groupRx = RegExp(r'group-title="([^"]*)"');
final RegExp _statusRx = RegExp(r'tvg-status="([^"]*)"');
final RegExp _uaRx = RegExp(r'#EXTVLCOPT:http-user-agent=(.+)');
final RegExp _refRx = RegExp(r'#EXTVLCOPT:http-referrer=(.+)');

List<Channel> parseM3u(String text, MediaType type) {
  final Map<String, Channel> map = {};
  String? title;
  String tvgId = '';
  String? ua;
  String? ref;
  String logo = '';
  String country = '';
  String lang = '';
  String group = '';
  String status = '';

  final lines = text.split('\n');

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('#EXTINF')) {
      tvgId = _idRx.firstMatch(line)?.group(1) ?? '';
      logo = _logoRx.firstMatch(line)?.group(1) ?? '';
      country = _countryRx.firstMatch(line)?.group(1) ?? '';
      lang = _languageRx.firstMatch(line)?.group(1) ?? '';
      group = _groupRx.firstMatch(line)?.group(1) ?? '';
      status = _statusRx.firstMatch(line)?.group(1) ?? '';

      final lastQuote = line.lastIndexOf('"');
      final comma = line.indexOf(',', lastQuote > 0 ? lastQuote : 0);
      title = comma >= 0 ? line.substring(comma + 1).trim() : 'Channel';
      ua = null;
      ref = null;
    } else if (line.startsWith('#EXTVLCOPT:http-user-agent=')) {
      ua = _uaRx.firstMatch(line)?.group(1);
    } else if (line.startsWith('#EXTVLCOPT:http-referrer=')) {
      ref = _refRx.firstMatch(line)?.group(1);
    } else if (line.startsWith('#')) {
      // Ignored comment
    } else if (title != null) {
      final qMatch = _qualityRx.firstMatch(title);
      final q = qMatch?.group(1) ?? '';
      final name = title.replaceAll(_qualityRx, '').trim().isEmpty
          ? 'Channel'
          : title.replaceAll(_qualityRx, '').trim();

      final id = tvgId.isNotEmpty ? tvgId : '${type.name}:${name.toLowerCase()}';
      final src = Source(url: line, ua: ua, referrer: ref);

      final existing = map[id];
      if (existing == null) {
        map[id] = Channel(
          id: id,
          name: name,
          quality: q,
          country: country,
          language: lang,
          sources: [src],
          logo: logo,
          group: group,
          status: status,
          mediaType: type,
        );
      } else {
        if (!existing.sources.any((s) => s.url == line)) {
          map[id] = existing.copyWith(
            sources: [...existing.sources, src],
          );
        }
      }
      title = null;
    }
  }

  final result = map.values.toList();
  result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return result;
}
