import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/store.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import 'channel_card.dart';

class ChannelGrid extends StatelessWidget {
  final List<Channel> channels;
  final Store store;
  final String emptyMessage;
  final ValueChanged<int> onPlay;

  const ChannelGrid({
    super.key,
    required this.channels,
    required this.store,
    required this.emptyMessage,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    if (channels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: T(
            emptyMessage,
            size: 16,
            color: aestheticMuted,
            align: TextAlign.center,
            maxLines: 4,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(48, 12, 48, 48),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.65,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];
        return ChannelCard(
          key: ValueKey(channel.id),
          channel: channel,
          store: store,
          onClick: () => onPlay(index),
          onLongClick: () => store.toggleFav(channel),
        );
      },
    );
  }
}
