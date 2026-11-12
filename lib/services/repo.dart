import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/channel.dart';
import 'm3u_parser.dart';

const String _rawBase =
    'https://raw.githubusercontent.com/abhijeet620380/freetvgarden-data-v2/main';
const String iptvM3uUrl = '$_rawBase/iptv/index.m3u';
const String radioM3uUrl = '$_rawBase/radio/index.m3u';
const String webcamM3uUrl = '$_rawBase/webcams/index.m3u';

class Repo {
  Directory? _cacheDir;

  Future<Directory> _getDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/ftg_cache');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    _cacheDir = d;
    return d;
  }

  Future<void> clearCache() async {
    try {
      final d = await _getDir();
      if (await d.exists()) {
        final files = d.listSync();
        for (final f in files) {
          if (f is File) await f.delete();
        }
      }
    } catch (_) {}
  }

  Future<String> _fetchM3u(String url, String cacheFileName, bool force) async {
    final d = await _getDir();
    final file = File('${d.path}/$cacheFileName');

    if (!force && await file.exists()) {
      final len = await file.length();
      if (len > 0) {
        return await file.readAsString();
      }
    }

    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FreeTvGarden-Android/1.0'},
      ).timeout(const Duration(seconds: 35));

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        await file.writeAsString(res.body);
        return res.body;
      }
    } catch (e) {
      if (await file.exists() && await file.length() > 0) {
        return await file.readAsString();
      }
      rethrow;
    }

    if (await file.exists() && await file.length() > 0) {
      return await file.readAsString();
    }
    throw Exception('Failed to load playlist: $url');
  }

  Future<List<Channel>> tvChannels({bool force = false}) async {
    final text = await _fetchM3u(iptvM3uUrl, 'iptv.m3u', force);
    return parseM3u(text, MediaType.tv);
  }

  Future<List<Channel>> radioChannels({bool force = false}) async {
    final text = await _fetchM3u(radioM3uUrl, 'radio.m3u', force);
    return parseM3u(text, MediaType.radio);
  }

  Future<List<Channel>> webcamChannels({bool force = false}) async {
    final text = await _fetchM3u(webcamM3uUrl, 'webcams.m3u', force);
    return parseM3u(text, MediaType.webcam);
  }
}
