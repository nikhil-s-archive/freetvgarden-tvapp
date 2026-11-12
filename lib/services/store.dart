import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/channel.dart';

class Store extends ChangeNotifier {
  final SharedPreferences _prefs;

  final List<Channel> _favs = [];
  final List<Channel> _recents = [];
  int _sortOrder = 0;
  bool _hideOffline = false;
  int _playerResizeMode = 0; // 0 = Fit, 1 = Zoom, 2 = Fill

  Store(this._prefs) {
    _loadAll();
  }

  List<Channel> get favs => List.unmodifiable(_favs);
  List<Channel> get recents => List.unmodifiable(_recents);
  int get sortOrder => _sortOrder;
  bool get hideOffline => _hideOffline;
  int get playerResizeMode => _playerResizeMode;

  void _loadAll() {
    _sortOrder = _prefs.getInt('sort_order') ?? 0;
    _hideOffline = _prefs.getBool('hide_offline') ?? false;
    _playerResizeMode = _prefs.getInt('resize_mode') ?? 0;

    _favs.clear();
    _favs.addAll(_read('favs'));

    _recents.clear();
    _recents.addAll(_read('recents'));
  }

  List<Channel> _read(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(String key, List<Channel> list) async {
    final raw = jsonEncode(list.map((c) => c.toJson()).toList());
    await _prefs.setString(key, raw);
  }

  bool isFav(Channel c) => _favs.any((item) => item.id == c.id);

  Future<void> toggleFav(Channel c) async {
    final idx = _favs.indexWhere((item) => item.id == c.id);
    if (idx >= 0) {
      _favs.removeAt(idx);
    } else {
      _favs.insert(0, c);
    }
    notifyListeners();
    await _write('favs', _favs);
  }

  Future<void> addRecent(Channel c) async {
    _recents.removeWhere((item) => item.id == c.id);
    _recents.insert(0, c);
    while (_recents.length > 30) {
      _recents.removeLast();
    }
    notifyListeners();
    await _write('recents', _recents);
  }

  Future<void> setSort(int order) async {
    _sortOrder = order;
    notifyListeners();
    await _prefs.setInt('sort_order', order);
  }

  Future<void> toggleHideOffline() async {
    _hideOffline = !_hideOffline;
    notifyListeners();
    await _prefs.setBool('hide_offline', _hideOffline);
  }

  Future<void> setResize(int mode) async {
    _playerResizeMode = mode;
    notifyListeners();
    await _prefs.setInt('resize_mode', mode);
  }
}
