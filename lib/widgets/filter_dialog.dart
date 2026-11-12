import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/country_helper.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/tv_icon.dart';
import 'flag_badge.dart';

class FilterDialog extends StatefulWidget {
  final List<String> countries;
  final List<String> languages;
  final String selectedCountry;
  final String selectedLanguage;
  final int currentSort;
  final ValueChanged<String> onSelectCountry;
  final ValueChanged<String> onSelectLanguage;
  final ValueChanged<int> onSelectSort;
  final VoidCallback onClose;

  const FilterDialog({
    super.key,
    required this.countries,
    required this.languages,
    required this.selectedCountry,
    required this.selectedLanguage,
    required this.currentSort,
    required this.onSelectCountry,
    required this.onSelectLanguage,
    required this.onSelectSort,
    required this.onClose,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final FocusNode _firstFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 60), () {
        if (mounted) _firstFocus.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _firstFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onClose();
        return false;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Semi-transparent backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onClose,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: const Color(0x75000000),
              ),
            ),
          ),

          // Translucent frosted glass panel
          Container(
            width: 660,
            constraints: const BoxConstraints(maxHeight: 520),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xBB121624),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0x6630D158), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const TvIcon(Ico.sliders, tint: iosBlue, size: 20),
                      const SizedBox(width: 10),
                      const T('Sort & Filter Options', size: 20, weight: FontWeight.bold),
                      const Spacer(),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: Glass(
                          focusNode: _firstFocus,
                          borderRadius: BorderRadius.circular(18),
                          solidOnFocus: true,
                          focusScale: 1.1,
                          onClick: widget.onClose,
                          builder: (context, focused) => Center(
                            child: TvIcon(
                              Ico.close,
                              tint: focused ? Colors.black : Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 1. Sort Options
                  const T('Sort By', size: 14, weight: FontWeight.w600, color: aestheticMuted),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: SortOption.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final opt = SortOption.values[index];
                        final isSelected = widget.currentSort == opt.index;
                        return Glass(
                          borderRadius: BorderRadius.circular(14),
                          solidOnFocus: true,
                          baseOpacity: isSelected ? 0.35 : 0.12,
                          onClick: () => widget.onSelectSort(opt.index),
                          builder: (context, focused) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              color: isSelected && !focused ? const Color(0xFF1A2A20) : Colors.transparent,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    TvIcon(Ico.check, tint: focused ? Colors.black : iosBlue, size: 12),
                                    const SizedBox(width: 6),
                                  ],
                                  T(
                                    opt.label,
                                    size: 13,
                                    weight: FontWeight.w500,
                                    color: focused
                                        ? Colors.black
                                        : (isSelected ? iosBlue : Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Country Filter (with official flags)
                  Row(
                    children: const [
                      TvIcon(Ico.globe, tint: aestheticMuted, size: 15),
                      SizedBox(width: 8),
                      T('Filter by Country', size: 14, weight: FontWeight.w600, color: aestheticMuted),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.countries.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final c = widget.countries[index];
                        final isSelected = widget.selectedCountry == c;
                        return Glass(
                          borderRadius: BorderRadius.circular(14),
                          solidOnFocus: true,
                          baseOpacity: isSelected ? 0.35 : 0.12,
                          onClick: () => widget.onSelectCountry(c),
                          builder: (context, focused) {
                            final cLabel = c == 'All' ? 'All' : '$c (${countryName(c)})';
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              color: isSelected && !focused ? const Color(0xFF1A2A20) : Colors.transparent,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FlagBadge(countryCode: c, height: 15),
                                  const SizedBox(width: 6),
                                  T(
                                    cLabel,
                                    size: 13,
                                    weight: FontWeight.w500,
                                    color: focused
                                        ? Colors.black
                                        : (isSelected ? iosBlue : Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Language Filter
                  Row(
                    children: const [
                      TvIcon(Ico.language, tint: aestheticMuted, size: 15),
                      SizedBox(width: 8),
                      T('Filter by Language', size: 14, weight: FontWeight.w600, color: aestheticMuted),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.languages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final lang = widget.languages[index];
                        final isSelected = widget.selectedLanguage == lang;
                        return Glass(
                          borderRadius: BorderRadius.circular(14),
                          solidOnFocus: true,
                          baseOpacity: isSelected ? 0.35 : 0.12,
                          onClick: () => widget.onSelectLanguage(lang),
                          builder: (context, focused) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              color: isSelected && !focused ? const Color(0xFF1A2A20) : Colors.transparent,
                              child: T(
                                lang,
                                size: 13,
                                weight: FontWeight.w500,
                                color: focused
                                    ? Colors.black
                                    : (isSelected ? iosBlue : Colors.white),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Done Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Glass(
                      borderRadius: BorderRadius.circular(16),
                      solidOnFocus: true,
                      focusScale: 1.06,
                      onClick: widget.onClose,
                      builder: (context, focused) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          child: T(
                            'Apply & Close',
                            size: 14,
                            weight: FontWeight.bold,
                            color: focused ? Colors.black : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
