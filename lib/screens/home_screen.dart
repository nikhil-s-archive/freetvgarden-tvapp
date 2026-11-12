import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/repo.dart';
import '../services/store.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/tv_icon.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/flag_badge.dart';
import '../widgets/search_bar.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/spinner.dart';
import 'channel_grid.dart';
import 'country_picker_screen.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final Store store;
  final Repo repo;

  const HomeScreen({
    super.key,
    required this.store,
    required this.repo,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _section;
  late int _subTab;
  late bool _showCountryPicker;

  String _selectedCategory = 'All';
  String _selectedCountry = 'All';
  String _selectedLanguage = 'All';
  String _query = '';

  bool _showSettings = false;
  bool _showFilterDialog = false;

  List<Channel> _tvChannels = [];
  List<Channel> _radioChannels = [];
  List<Channel> _webcamChannels = [];

  bool _loading = true;
  String? _message;
  int? _playIndex;

  @override
  void initState() {
    super.initState();
    final hasFavs = widget.store.favs.isNotEmpty;

    // Active media section: if first favourite is Radio/Webcam, start in that section
    int initialSection = 0;
    if (hasFavs) {
      final first = widget.store.favs.first;
      if (first.mediaType == MediaType.radio) {
        initialSection = 1;
      } else if (first.mediaType == MediaType.webcam) {
        initialSection = 2;
      }
    }

    _section = initialSection;
    _subTab = hasFavs ? 1 : 0;
    _showCountryPicker = !hasFavs;

    _load(false);
  }

  List<Channel> get _currentRawList {
    switch (_section) {
      case 1:
        return _radioChannels;
      case 2:
        return _webcamChannels;
      default:
        return _tvChannels;
    }
  }

  Future<void> _load(bool force) async {
    setState(() {
      _loading = true;
      _message = null;
    });

    if (force) await widget.repo.clearCache();

    try {
      final tv = await widget.repo.tvChannels(force: force);
      if (mounted) setState(() => _tvChannels = tv);
    } catch (_) {
      if (_tvChannels.isEmpty && mounted) {
        setState(() => _message = "Couldn't load TV. Check connection.");
      }
    }

    try {
      final radio = await widget.repo.radioChannels(force: force);
      if (mounted) setState(() => _radioChannels = radio);
    } catch (_) {}

    try {
      final webcams = await widget.repo.webcamChannels(force: force);
      if (mounted) setState(() => _webcamChannels = webcams);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _loading = false;
        if (widget.store.favs.isNotEmpty && !force) {
          _subTab = 1;
          _showCountryPicker = false;
        }
      });
    }
  }

  MediaType _mediaTypeFor(int section) {
    switch (section) {
      case 1:
        return MediaType.radio;
      case 2:
        return MediaType.webcam;
      default:
        return MediaType.tv;
    }
  }

  String _sectionLabel(int section) {
    switch (section) {
      case 1:
        return 'Radio';
      case 2:
        return 'Webcams';
      default:
        return 'TV';
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = _currentRawList;

    // Dynamic Categories
    final categories = ['All'];
    final categoryCounts = <String, int>{};
    for (final c in raw) {
      final g = c.group.trim();
      if (g.isNotEmpty && !g.toLowerCase().contains('general')) {
        categoryCounts[g] = (categoryCounts[g] ?? 0) + 1;
      }
    }
    final sortedCategories = categoryCounts.keys.toList()
      ..sort((a, b) => categoryCounts[b]!.compareTo(categoryCounts[a]!));
    categories.addAll(sortedCategories.take(16));

    // Dynamic Countries
    final countries = ['All'];
    final countryCounts = <String, int>{};
    for (final c in raw) {
      final cnt = c.country.trim().toUpperCase();
      if (cnt.isNotEmpty) {
        countryCounts[cnt] = (countryCounts[cnt] ?? 0) + 1;
      }
    }
    final sortedCountries = countryCounts.keys.toList()
      ..sort((a, b) => countryCounts[b]!.compareTo(countryCounts[a]!));
    countries.addAll(sortedCountries.take(24));

    // Dynamic Languages
    final languages = ['All'];
    final languageCounts = <String, int>{};
    for (final c in raw) {
      final l = c.language.trim();
      if (l.isNotEmpty) {
        languageCounts[l] = (languageCounts[l] ?? 0) + 1;
      }
    }
    final sortedLanguages = languageCounts.keys.toList()
      ..sort((a, b) => languageCounts[b]!.compareTo(languageCounts[a]!));
    languages.addAll(sortedLanguages.take(20));

    // Countries with channel lists
    final Map<String, List<Channel>> countryGroups = {};
    for (final c in raw) {
      final cnt = c.country.trim().toUpperCase();
      if (cnt.isNotEmpty) {
        countryGroups.putIfAbsent(cnt, () => []).add(c);
      }
    }
    final countriesWithChannels = countryGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    // Base List according to subTab
    List<Channel> baseList;
    if (_subTab == 1) {
      baseList = widget.store.favs
          .where((c) => c.mediaType == _mediaTypeFor(_section))
          .toList();
    } else if (_subTab == 2) {
      baseList = widget.store.recents
          .where((c) => c.mediaType == _mediaTypeFor(_section))
          .toList();
    } else {
      baseList = raw;
    }

    // Filter pipeline
    final q = _query.trim().toLowerCase();
    final filteredList = baseList.where((c) {
      final matchesQ = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.group.toLowerCase().contains(q) ||
          c.country.toLowerCase().contains(q) ||
          c.language.toLowerCase().contains(q);
      final matchesCat = _selectedCategory == 'All' ||
          c.group.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesCountry = _selectedCountry == 'All' ||
          c.country.toLowerCase() == _selectedCountry.toLowerCase();
      final matchesLang = _selectedLanguage == 'All' ||
          c.language.toLowerCase() == _selectedLanguage.toLowerCase();
      final matchesOffline = !widget.store.hideOffline || c.status != 'down';

      return matchesQ && matchesCat && matchesCountry && matchesLang && matchesOffline;
    }).toList();

    // Sort pipeline
    switch (widget.store.sortOrder) {
      case 1:
        filteredList.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 2:
        filteredList.sort((a, b) {
          final liveA = a.status == 'live' ? 1 : 0;
          final liveB = b.status == 'live' ? 1 : 0;
          if (liveA != liveB) return liveB.compareTo(liveA);
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case 3:
        filteredList.sort((a, b) {
          final hdA = a.quality.contains('1080') || a.quality.contains('4k') ? 1 : 0;
          final hdB = b.quality.contains('1080') || b.quality.contains('4k') ? 1 : 0;
          if (hdA != hdB) return hdB.compareTo(hdA);
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case 4:
        filteredList.sort((a, b) => a.country.compareTo(b.country));
        break;
      case 5:
        filteredList.sort((a, b) => a.language.compareTo(b.language));
        break;
      default:
        filteredList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    final hasActiveFilters =
        _selectedCategory != 'All' || _selectedCountry != 'All' || _selectedLanguage != 'All';

    return WillPopScope(
      onWillPop: () async {
        if (_playIndex != null) {
          setState(() => _playIndex = null);
          return false;
        }
        if (_showSettings) {
          setState(() => _showSettings = false);
          return false;
        }
        if (_showFilterDialog) {
          setState(() => _showFilterDialog = false);
          return false;
        }
        if (_query.isNotEmpty) {
          setState(() => _query = '');
          return false;
        }
        if (hasActiveFilters) {
          setState(() {
            _selectedCategory = 'All';
            _selectedCountry = 'All';
            _selectedLanguage = 'All';
          });
          return false;
        }
        if (_subTab != 0) {
          setState(() {
            _subTab = 0;
            if (widget.store.favs.isEmpty) _showCountryPicker = true;
          });
          return false;
        }
        if (!_showCountryPicker) {
          setState(() {
            _showCountryPicker = true;
            _selectedCountry = 'All';
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: aestheticDark,
        body: Stack(
          children: [
            // ── Main UI ───────────────────────────────────────────────────────
            if (_loading && raw.isEmpty && widget.store.favs.isEmpty)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Spinner(size: 56),
                    SizedBox(height: 16),
                    T('Loading channels…', size: 16, color: aestheticMuted),
                  ],
                ),
              )
            else if (_showCountryPicker && _playIndex == null)
              CountryPickerScreen(
                countriesWithChannels: countriesWithChannels,
                section: _section,
                onSection: (s) => setState(() {
                  _section = s;
                  _subTab = 0;
                  _selectedCategory = 'All';
                }),
                store: widget.store,
                loading: _loading,
                onSelectCountry: (c) => setState(() {
                  _selectedCountry = c;
                  _showCountryPicker = false;
                  _subTab = 0;
                }),
                onShowAll: () => setState(() {
                  _selectedCountry = 'All';
                  _showCountryPicker = false;
                  _subTab = 0;
                }),
                onShowFavs: () => setState(() {
                  _selectedCountry = 'All';
                  _showCountryPicker = false;
                  _subTab = 1;
                }),
                onOpenSettings: () => setState(() => _showSettings = true),
                onRefresh: () => _load(true),
              )
            else
              Column(
                children: [
                  // ── Top Bar ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(48, 20, 48, 4),
                    child: Row(
                      children: [
                        // Countries Button
                        Glass(
                          borderRadius: BorderRadius.circular(14),
                          solidOnFocus: true,
                          focusScale: 1.06,
                          onClick: () => setState(() => _showCountryPicker = true),
                          builder: (context, focused) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TvIcon(Ico.globe, tint: focused ? Colors.black : iosBlue, size: 16),
                                  const SizedBox(width: 6),
                                  T('Countries', size: 13, weight: FontWeight.w600, color: focused ? Colors.black : Colors.white),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 12),

                        const T('FreeTvGarden', size: 26, weight: FontWeight.bold),

                        const Spacer(),

                        // Section Switcher
                        Container(
                          decoration: BoxDecoration(
                            color: aestheticSurface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: aestheticBorder),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final item in [
                                _SectionItem(0, 'TV', Ico.tv),
                                _SectionItem(1, 'Radio', Ico.radio),
                                _SectionItem(2, 'Webcams', Ico.webcam),
                              ]) ...[
                                Glass(
                                  borderRadius: BorderRadius.circular(20),
                                  solidOnFocus: true,
                                  baseOpacity: _section == item.index ? 0.35 : 0.0,
                                  onClick: () => setState(() {
                                    _section = item.index;
                                    _subTab = 0;
                                    _selectedCategory = 'All';
                                    _query = '';
                                  }),
                                  builder: (context, focused) {
                                    final isCur = _section == item.index;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TvIcon(
                                            item.icon,
                                            tint: focused
                                                ? Colors.black
                                                : (isCur ? iosBlue : Colors.white.withOpacity(0.7)),
                                            size: 15,
                                          ),
                                          const SizedBox(width: 6),
                                          T(
                                            item.label,
                                            size: 13,
                                            weight: isCur ? FontWeight.w600 : FontWeight.w500,
                                            color: focused
                                                ? Colors.black
                                                : Colors.white.withOpacity(isCur ? 1.0 : 0.7),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (item.index != 2) const SizedBox(width: 4),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        // SubTabs: All / Favs / Recents
                        Container(
                          decoration: BoxDecoration(
                            color: aestheticSurface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: aestheticBorder),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final st in [
                                MapEntry(0, 'All'),
                                MapEntry(1, 'Favs'),
                                MapEntry(2, 'Recent'),
                              ]) ...[
                                Glass(
                                  borderRadius: BorderRadius.circular(20),
                                  solidOnFocus: true,
                                  baseOpacity: _subTab == st.key ? 0.35 : 0.0,
                                  onClick: () => setState(() {
                                    _subTab = st.key;
                                    _query = '';
                                  }),
                                  builder: (context, focused) {
                                    final isCur = _subTab == st.key;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      child: T(
                                        st.value,
                                        size: 13,
                                        weight: isCur ? FontWeight.w600 : FontWeight.w500,
                                        color: focused
                                            ? Colors.black
                                            : (isCur ? iosBlue : Colors.white.withOpacity(0.7)),
                                      ),
                                    );
                                  },
                                ),
                                if (st.key != 2) const SizedBox(width: 4),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Settings Button
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Glass(
                            borderRadius: BorderRadius.circular(20),
                            solidOnFocus: true,
                            onClick: () => setState(() => _showSettings = true),
                            builder: (context, focused) => Center(
                              child: TvIcon(
                                Ico.settings,
                                tint: focused ? Colors.black : Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Refresh Button
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Glass(
                            borderRadius: BorderRadius.circular(20),
                            solidOnFocus: true,
                            onClick: () => _load(true),
                            builder: (context, focused) => Center(
                              child: _loading
                                  ? const Spinner(size: 16)
                                  : TvIcon(
                                      Ico.refresh,
                                      tint: focused ? Colors.black : Colors.white,
                                      size: 16,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Search & Filter Controls Row ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 6),
                    child: Row(
                      children: [
                        TvSearchBar(
                          query: _query,
                          onQueryChanged: (val) => setState(() => _query = val),
                          hint: 'Search ${_sectionLabel(_section)}…',
                        ),

                        const SizedBox(width: 16),

                        // Filter Pill
                        Glass(
                          borderRadius: BorderRadius.circular(20),
                          solidOnFocus: true,
                          onClick: () => setState(() => _showFilterDialog = true),
                          builder: (context, focused) {
                            final filterCount = (_selectedCountry != 'All' ? 1 : 0) +
                                (_selectedLanguage != 'All' ? 1 : 0);
                            final text = filterCount > 0 ? 'Filter ($filterCount)' : 'Filter & Sort';
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TvIcon(Ico.filter, tint: focused ? Colors.black : iosBlue, size: 16),
                                  const SizedBox(width: 8),
                                  T(text, size: 14, weight: FontWeight.w600, color: focused ? Colors.black : Colors.white),
                                ],
                              ),
                            );
                          },
                        ),

                        // Active Country Flag Shortcut
                        if (_selectedCountry != 'All') ...[
                          const SizedBox(width: 10),
                          Glass(
                            borderRadius: BorderRadius.circular(20),
                            solidOnFocus: true,
                            onClick: () => setState(() => _showCountryPicker = true),
                            builder: (context, focused) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FlagBadge(countryCode: _selectedCountry, height: 16),
                                    const SizedBox(width: 6),
                                    T(_selectedCountry, size: 13, color: focused ? Colors.black : iosBlue),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],

                        // Reset Filters
                        if (hasActiveFilters) ...[
                          const SizedBox(width: 12),
                          Glass(
                            borderRadius: BorderRadius.circular(20),
                            solidOnFocus: true,
                            onClick: () => setState(() {
                              _selectedCategory = 'All';
                              _selectedCountry = 'All';
                              _selectedLanguage = 'All';
                            }),
                            builder: (context, focused) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TvIcon(Ico.close, tint: focused ? Colors.black : Colors.white, size: 14),
                                    const SizedBox(width: 6),
                                    T('Reset Filters', size: 13, color: focused ? Colors.black : Colors.white),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],

                        const Spacer(),

                        T(
                          '${filteredList.length} channels',
                          size: 13,
                          weight: FontWeight.w500,
                          color: aestheticMuted,
                        ),
                      ],
                    ),
                  ),

                  // ── Category / Genre Horizontal Chips ─────────────────────
                  if (_subTab == 0 && categories.length > 1)
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 6),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = _selectedCategory == cat;
                          return Glass(
                            borderRadius: BorderRadius.circular(16),
                            solidOnFocus: true,
                            baseOpacity: isSelected ? 0.35 : 0.12,
                            onClick: () => setState(() => _selectedCategory = cat),
                            builder: (context, focused) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                color: isSelected && !focused ? const Color(0xFF1B2820) : Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (cat == 'All') ...[
                                      TvIcon(
                                        Ico.category,
                                        tint: focused
                                            ? Colors.black
                                            : (isSelected ? iosBlue : aestheticMuted),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    T(
                                      cat,
                                      size: 13,
                                      weight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: focused
                                          ? Colors.black
                                          : (isSelected ? iosBlue : Colors.white.withOpacity(0.85)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                  // ── Channels Grid & Empty State ───────────────────────────
                  Expanded(
                    child: Stack(
                      children: [
                        ChannelGrid(
                          channels: filteredList,
                          store: widget.store,
                          emptyMessage: _getEmptyMessage(),
                          onPlay: (idx) => setState(() => _playIndex = idx),
                        ),
                        if (_message != null)
                          Positioned(
                            bottom: 24,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: T(_message!, size: 15, color: const Color(0xFFFFB4B4)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

            // ── Overlays: Filter Dialog ───────────────────────────────────────
            if (_showFilterDialog)
              FilterDialog(
                countries: countries,
                languages: languages,
                selectedCountry: _selectedCountry,
                selectedLanguage: _selectedLanguage,
                currentSort: widget.store.sortOrder,
                onSelectCountry: (c) => setState(() {
                  _selectedCountry = c;
                  _showFilterDialog = false;
                }),
                onSelectLanguage: (l) => setState(() {
                  _selectedLanguage = l;
                  _showFilterDialog = false;
                }),
                onSelectSort: (s) => widget.store.setSort(s),
                onClose: () => setState(() => _showFilterDialog = false),
              ),

            // ── Overlays: Settings Dialog ─────────────────────────────────────
            if (_showSettings)
              SettingsDialog(
                store: widget.store,
                tvCount: _tvChannels.length,
                radioCount: _radioChannels.length,
                webcamCount: _webcamChannels.length,
                onClearCache: () {
                  widget.repo.clearCache();
                  _load(true);
                },
                onClose: () => setState(() => _showSettings = false),
              ),

            // ── Overlays: Player Screen ───────────────────────────────────────
            if (_playIndex != null)
              PlayerScreen(
                list: filteredList,
                startIndex: _playIndex!,
                store: widget.store,
                onExit: () => setState(() => _playIndex = null),
              ),
          ],
        ),
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_subTab) {
      case 1:
        return 'No ${_sectionLabel(_section)} favourites yet.\nHold OK on any item to add it.';
      case 2:
        return '${_sectionLabel(_section)} you watch will appear here.';
      default:
        return _currentRawList.isNotEmpty ? 'No channels match current filters.' : '';
    }
  }
}

class _SectionItem {
  final int index;
  final String label;
  final Ico icon;
  _SectionItem(this.index, this.label, this.icon);
}
