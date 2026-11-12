import 'package:flutter/material.dart';
import '../services/store.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/tv_icon.dart';

class SettingsDialog extends StatefulWidget {
  final Store store;
  final int tvCount;
  final int radioCount;
  final int webcamCount;
  final VoidCallback onClearCache;
  final VoidCallback onClose;

  const SettingsDialog({
    super.key,
    required this.store,
    required this.tvCount,
    required this.radioCount,
    required this.webcamCount,
    required this.onClearCache,
    required this.onClose,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final FocusNode _closeFocus = FocusNode();
  bool _clearDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 60), () {
        if (mounted) _closeFocus.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _closeFocus.dispose();
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
            constraints: const BoxConstraints(maxHeight: 560),
            padding: const EdgeInsets.all(30),
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
                      const TvIcon(Ico.settings, tint: iosBlue, size: 24),
                      const SizedBox(width: 12),
                      const T('Settings', size: 24, weight: FontWeight.bold),
                      const Spacer(),
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: Glass(
                          focusNode: _closeFocus,
                          borderRadius: BorderRadius.circular(19),
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

                  const SizedBox(height: 24),

                  // Section 1: Playback
                  const T('Playback & Display', size: 15, weight: FontWeight.bold, color: iosBlue),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: aestheticSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: aestheticBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              T('Video Aspect Ratio', size: 15, weight: FontWeight.w600),
                              SizedBox(height: 2),
                              T('Fit screen, Zoom crop, or Stretch', size: 12, color: aestheticMuted),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            for (final entry in [
                              MapEntry(0, 'Fit'),
                              MapEntry(1, 'Zoom'),
                              MapEntry(2, 'Stretch'),
                            ]) ...[
                              Glass(
                                borderRadius: BorderRadius.circular(12),
                                solidOnFocus: true,
                                baseOpacity: widget.store.playerResizeMode == entry.key ? 0.35 : 0.12,
                                onClick: () => widget.store.setResize(entry.key),
                                builder: (context, focused) {
                                  final isCur = widget.store.playerResizeMode == entry.key;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    child: T(
                                      entry.value,
                                      size: 13,
                                      weight: isCur ? FontWeight.bold : FontWeight.normal,
                                      color: focused
                                          ? Colors.black
                                          : (isCur ? iosBlue : Colors.white),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 2: Channel Preferences
                  const T('Channel Preferences', size: 15, weight: FontWeight.bold, color: iosBlue),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: aestheticSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: aestheticBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              T('Hide Offline Channels', size: 15, weight: FontWeight.w600),
                              SizedBox(height: 2),
                              T('Filter out streams reported as offline', size: 12, color: aestheticMuted),
                            ],
                          ),
                        ),
                        Glass(
                          borderRadius: BorderRadius.circular(14),
                          solidOnFocus: true,
                          onClick: widget.store.toggleHideOffline,
                          builder: (context, focused) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.store.hideOffline) ...[
                                    TvIcon(Ico.check, tint: focused ? Colors.black : iosBlue, size: 14),
                                    const SizedBox(width: 6),
                                  ],
                                  T(
                                    widget.store.hideOffline ? 'Hidden' : 'Shown',
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: focused
                                        ? Colors.black
                                        : (widget.store.hideOffline ? iosBlue : Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 3: Cache & Storage
                  const T('Data & Cache', size: 15, weight: FontWeight.bold, color: iosBlue),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: aestheticSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: aestheticBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const T('Cache Status', size: 15, weight: FontWeight.w600),
                              const SizedBox(height: 2),
                              T(
                                '${widget.tvCount} TV · ${widget.radioCount} Radio · ${widget.webcamCount} Webcams',
                                size: 12,
                                color: aestheticMuted,
                              ),
                            ],
                          ),
                        ),
                        Glass(
                          borderRadius: BorderRadius.circular(14),
                          solidOnFocus: true,
                          onClick: () {
                            widget.onClearCache();
                            setState(() => _clearDone = true);
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) setState(() => _clearDone = false);
                            });
                          },
                          builder: (context, focused) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TvIcon(
                                    _clearDone ? Ico.check : Ico.refresh,
                                    tint: focused ? Colors.black : (_clearDone ? iosBlue : Colors.white),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  T(
                                    _clearDone ? 'Cleared!' : 'Clear Cache',
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: focused
                                        ? Colors.black
                                        : (_clearDone ? iosBlue : Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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
