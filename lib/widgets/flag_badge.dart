import 'package:flutter/material.dart';
import '../services/country_helper.dart';
import '../theme/colors.dart';
import '../theme/tv_icon.dart';

class FlagBadge extends StatelessWidget {
  final String countryCode;
  final double height;

  const FlagBadge({
    super.key,
    required this.countryCode,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (countryCode.isEmpty ||
        countryCode.toUpperCase() == 'ALL' ||
        countryCode.length != 2) {
      return TvIcon(Ico.globe, tint: iosBlue, size: height);
    }

    final url = countryFlagUrlSmall(countryCode);
    final width = height * 1.45;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2130),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: aestheticBorder, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.5),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                countryFlagEmoji(countryCode),
                style: TextStyle(fontSize: height * 0.8),
              ),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(color: const Color(0xFF1B2130));
          },
        ),
      ),
    );
  }
}
