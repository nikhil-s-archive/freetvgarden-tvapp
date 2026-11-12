import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/store.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/tv_icon.dart';
import '../widgets/flag_badge.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  final Store store;
  final VoidCallback onClick;
  final VoidCallback onLongClick;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.store,
    required this.onClick,
    required this.onLongClick,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = store.isFav(channel);
    final initials = channel.name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return AspectRatio(
      aspectRatio: 1.65,
      child: Glass(
        borderRadius: BorderRadius.circular(16),
        onClick: onClick,
        onLongClick: onLongClick,
        builder: (context, focused) {
          return Stack(
            children: [
              // Matte Background
              Positioned.fill(
                child: Container(
                  color: focused ? const Color(0xFF1B2130) : aestheticCard,
                ),
              ),

              // Logo Image or Monogram
              Center(
                child: channel.logo.isNotEmpty
                    ? Container(
                        width: 54,
                        height: 54,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1219),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.network(
                          channel.logo,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(
                            child: T(initials, size: 20, weight: FontWeight.bold),
                          ),
                        ),
                      )
                    : Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF181D29),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: aestheticBorder),
                        ),
                        alignment: Alignment.center,
                        child: T(initials, size: 22, weight: FontWeight.bold),
                      ),
              ),

              // Top Start: Quality / Media Type
              Positioned(
                top: 10,
                left: 10,
                child: _buildTypeBadge(),
              ),

              // Top End: Status Dot & Favourite Heart
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFav) ...[
                      const TvIcon(Ico.heartFilled, tint: Color(0xFFFF4D6D), size: 14),
                      const SizedBox(width: 8),
                    ],
                    if (channel.status == 'live')
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: iosBlue,
                          shape: BoxShape.circle,
                        ),
                      )
                    else if (channel.status == 'down')
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: iosRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Info: Channel Name + Subtitle (Flag + Country · Group · Language)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    T(channel.name, size: 14, weight: FontWeight.w600),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (channel.country.length == 2) ...[
                          FlagBadge(countryCode: channel.country, height: 11),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: T(
                            [
                              channel.country,
                              channel.group,
                              channel.language,
                            ].where((s) => s.isNotEmpty).join(' · '),
                            size: 11,
                            color: aestheticMuted,
                          ),
                        ),
                      ],
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

  Widget _buildTypeBadge() {
    switch (channel.mediaType) {
      case MediaType.radio:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2230),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const TvIcon(Ico.radio, tint: iosBlue, size: 12),
        );
      case MediaType.webcam:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2230),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const TvIcon(Ico.webcam, tint: iosBlue, size: 12),
        );
      case MediaType.tv:
        if (channel.quality.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2230),
              borderRadius: BorderRadius.circular(6),
            ),
            child: T(channel.quality, size: 10, weight: FontWeight.w600, color: iosBlue),
          );
        }
        return const SizedBox.shrink();
    }
  }
}
