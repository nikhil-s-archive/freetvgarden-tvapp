import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/country_helper.dart';
import '../services/store.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/tv_icon.dart';
import '../widgets/spinner.dart';

class CountryPickerScreen extends StatefulWidget {
  final List<MapEntry<String, List<Channel>>> countriesWithChannels;
  final int section;
  final ValueChanged<int> onSection;
  final Store store;
  final bool loading;
  final ValueChanged<String> onSelectCountry;
  final VoidCallback onShowAll;
  final VoidCallback onShowFavs;
  final VoidCallback onOpenSettings;
  final VoidCallback onRefresh;

  const CountryPickerScreen({
    super.key,
    required this.countriesWithChannels,
    required this.section,
    required this.onSection,
    required this.store,
    required this.loading,
    required this.onSelectCountry,
    required this.onShowAll,
    required this.onShowFavs,
    required this.onOpenSettings,
    required this.onRefresh,
  });

  @override
  State<CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends State<CountryPickerScreen> {
  final FocusNode _allChannelsFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _allChannelsFocus.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _allChannelsFocus.dispose();
    super.dispose();
  }

  String _sectionLabel(int section) {
    switch (section) {
      case 1:
        return 'radio';
      case 2:
        return 'webcam';
      default:
        return 'tv';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header: Title + Section Switcher + Settings + Refresh ───────────
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 22, 48, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const T('FreeTvGarden', size: 26, weight: FontWeight.bold),
                    const SizedBox(height: 2),
                    T(
                      'Choose a country to browse ${_sectionLabel(widget.section)} channels',
                      size: 13,
                      color: aestheticMuted,
                    ),
                  ],
                ),
              ),

              // Section Switcher: TV / Radio / Webcam
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
                        focusScale: 1.05,
                        baseOpacity: widget.section == item.index ? 0.35 : 0.0,
                        onClick: () => widget.onSection(item.index),
                        builder: (context, focused) {
                          final isCur = widget.section == item.index;
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

              const SizedBox(width: 12),

              // Settings
              SizedBox(
                width: 40,
                height: 40,
                child: Glass(
                  borderRadius: BorderRadius.circular(20),
                  solidOnFocus: true,
                  focusScale: 1.08,
                  onClick: widget.onOpenSettings,
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

              // Refresh
              SizedBox(
                width: 40,
                height: 40,
                child: Glass(
                  borderRadius: BorderRadius.circular(20),
                  solidOnFocus: true,
                  focusScale: 1.08,
                  onClick: widget.onRefresh,
                  builder: (context, focused) => Center(
                    child: widget.loading
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

        // ── Action Shortcuts: All Channels + Favourites ─────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 0, 48, 16),
          child: Row(
            children: [
              // All Channels
              Glass(
                focusNode: _allChannelsFocus,
                borderRadius: BorderRadius.circular(16),
                solidOnFocus: true,
                focusScale: 1.05,
                onClick: widget.onShowAll,
                builder: (context, focused) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TvIcon(Ico.globe, tint: focused ? Colors.black : iosBlue, size: 16),
                        const SizedBox(width: 8),
                        T(
                          'All ${_sectionLabel(widget.section).toUpperCase()} Channels',
                          size: 14,
                          weight: FontWeight.bold,
                          color: focused ? Colors.black : Colors.white,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Favourites Shortcut
              if (widget.store.favs.isNotEmpty) ...[
                const SizedBox(width: 12),
                Glass(
                  borderRadius: BorderRadius.circular(16),
                  solidOnFocus: true,
                  focusScale: 1.05,
                  onClick: widget.onShowFavs,
                  builder: (context, focused) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const TvIcon(Ico.heartFilled, tint: Color(0xFFFF4D6D), size: 16),
                          const SizedBox(width: 8),
                          T(
                            'Favourites (${widget.store.favs.length})',
                            size: 14,
                            weight: FontWeight.bold,
                            color: focused ? Colors.black : Colors.white,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              const Spacer(),

              T(
                '${widget.countriesWithChannels.length} countries available',
                size: 13,
                weight: FontWeight.w500,
                color: aestheticMuted,
              ),
            ],
          ),
        ),

        // ── Countries Grid with Flag Logos ──────────────────────────────────
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.5,
            ),
            itemCount: widget.countriesWithChannels.length,
            itemBuilder: (context, index) {
              final item = widget.countriesWithChannels[index];
              return CountryCard(
                key: ValueKey(item.key),
                country: item.key,
                channels: item.value,
                store: widget.store,
                onClick: () => widget.onSelectCountry(item.key),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionItem {
  final int index;
  final String label;
  final Ico icon;
  _SectionItem(this.index, this.label, this.icon);
}

class CountryCard extends StatelessWidget {
  final String country;
  final List<Channel> channels;
  final Store store;
  final VoidCallback onClick;

  const CountryCard({
    super.key,
    required this.country,
    required this.channels,
    required this.store,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final cName = countryName(country);
    final flagUrl = countryFlagUrl(country);
    final favCount = channels.where((c) => store.isFav(c)).length;
    final logoChannels = channels.where((c) => c.logo.isNotEmpty).take(4).toList();

    return AspectRatio(
      aspectRatio: 1.5,
      child: Glass(
        borderRadius: BorderRadius.circular(18),
        onClick: onClick,
        builder: (context, focused) {
          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: focused ? const Color(0xFF1E2536) : aestheticCard,
                ),
              ),

              // Top Row: Country Flag Logo + Country ISO Badge + Favs
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    // Flag Logo Image (High Quality FlagCDN)
                    Container(
                      width: 44,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1219),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: focused ? iosBlue : aestheticBorder,
                          width: 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          flagUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              countryFlagEmoji(country),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B26),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: aestheticBorder, width: 0.5),
                      ),
                      child: T(
                        country.toUpperCase(),
                        size: 11,
                        weight: FontWeight.bold,
                        color: iosBlue,
                      ),
                    ),

                    const Spacer(),

                    if (favCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A1520),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const TvIcon(Ico.heartFilled, tint: Color(0xFFFF4D6D), size: 11),
                            const SizedBox(width: 3),
                            T(
                              '$favCount',
                              size: 11,
                              weight: FontWeight.bold,
                              color: const Color(0xFFFF4D6D),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Center: Full Country Name + Channel Count
              Positioned(
                top: 50,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    T(cName, size: 16, weight: FontWeight.bold),
                    const SizedBox(height: 2),
                    T('${channels.length} channels', size: 12, color: aestheticMuted),
                  ],
                ),
              ),

              // Bottom: Representative channel logos
              if (logoChannels.isNotEmpty)
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < logoChannels.length; i++)
                        Transform.translate(
                          offset: Offset(-6.0 * i, 0),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1219),
                              shape: BoxShape.circle,
                              border: Border.all(color: aestheticBorder),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                logoChannels[i].logo,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
