import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/channel.dart';
import '../services/store.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/tv_icon.dart';
import '../widgets/spinner.dart';

const double _zoomMin = 1.0;
const double _zoomMax = 4.0;
const double _zoomStep = 0.25;

class PlayerScreen extends StatefulWidget {
  final List<Channel> list;
  final int startIndex;
  final Store store;
  final VoidCallback onExit;

  const PlayerScreen({
    super.key,
    required this.list,
    required this.startIndex,
    required this.store,
    required this.onExit,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late int _idx;
  int _src = 0;
  bool _controls = true;
  bool _banner = true;
  bool _buffering = true;
  bool _failed = false;

  double _zoomScale = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;
  bool _showZoomHud = false;

  VideoPlayerController? _controller;
  Timer? _controlsTimer;
  Timer? _bannerTimer;
  Timer? _zoomHudTimer;

  final FocusNode _rootFocus = FocusNode();
  final FocusNode _playBtnFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _idx = widget.startIndex;
    _initPlayer();

    _resetBannerTimer();
    _resetControlsTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rootFocus.requestFocus();
    });
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    if (_controls && (_controller?.value.isPlaying ?? true)) {
      _controlsTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _controls = false);
      });
    }
  }

  void _resetBannerTimer() {
    _bannerTimer?.cancel();
    _banner = true;
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _banner = false);
    });
  }

  void _triggerZoomHud() {
    _zoomHudTimer?.cancel();
    setState(() => _showZoomHud = true);
    _zoomHudTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showZoomHud = false);
    });
  }

  Future<void> _initPlayer() async {
    _controller?.dispose();
    _controller = null;

    if (_idx >= widget.list.length) return;
    final ch = widget.list[_idx];
    if (ch.sources.isEmpty) {
      setState(() {
        _failed = true;
        _buffering = false;
      });
      return;
    }

    final s = ch.sources[_src.clamp(0, ch.sources.length - 1)];

    setState(() {
      _buffering = true;
      _failed = false;
    });

    final headers = <String, String>{
      'User-Agent': s.ua ??
          'Mozilla/5.0 (Linux; Android 12; TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36',
      if (s.referrer != null) 'Referer': s.referrer!,
    };

    try {
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(s.url),
        httpHeaders: headers,
      );

      await ctrl.initialize();
      ctrl.setLooping(true);
      await ctrl.play();

      if (mounted) {
        setState(() {
          _controller = ctrl;
          _buffering = false;
          _failed = false;
        });

        if (_src == 0) {
          widget.store.addRecent(ch);
        }
      }

      ctrl.addListener(() {
        if (!mounted) return;
        final val = ctrl.value;
        if (val.hasError && !_failed) {
          if (_src + 1 < ch.sources.length) {
            _src++;
            _initPlayer();
          } else {
            setState(() {
              _failed = true;
              _buffering = false;
            });
          }
        } else if (val.isBuffering != _buffering) {
          setState(() => _buffering = val.isBuffering);
        }
      });
    } catch (_) {
      if (_src + 1 < ch.sources.length) {
        _src++;
        _initPlayer();
      } else {
        if (mounted) {
          setState(() {
            _failed = true;
            _buffering = false;
          });
        }
      }
    }
  }

  void _zap(int delta) {
    setState(() {
      _idx = (_idx + delta + widget.list.length) % widget.list.length;
      _src = 0;
      _zoomScale = 1.0;
      _panX = 0;
      _panY = 0;
      _showZoomHud = false;
    });
    _resetBannerTimer();
    _initPlayer();
  }

  void _applyZoom(double newScale) {
    setState(() {
      _zoomScale = newScale.clamp(_zoomMin, _zoomMax);
    });
    _triggerZoomHud();
  }

  void _resetZoom() {
    setState(() {
      _zoomScale = 1.0;
      _panX = 0;
      _panY = 0;
      _showZoomHud = false;
    });
  }

  void _togglePlay() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
    _resetControlsTimer();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _bannerTimer?.cancel();
    _zoomHudTimer?.cancel();
    _controller?.dispose();
    _rootFocus.dispose();
    _playBtnFocus.dispose();
    super.dispose();
  }

  BoxFit _getBoxFit() {
    switch (widget.store.playerResizeMode) {
      case 1:
        return BoxFit.cover; // Zoom
      case 2:
        return BoxFit.fill; // Stretch
      default:
        return BoxFit.contain; // Fit
    }
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.list[_idx];
    final isPlaying = _controller?.value.isPlaying ?? false;

    return WillPopScope(
      onWillPop: () async {
        widget.onExit();
        return false;
      },
      child: Focus(
        focusNode: _rootFocus,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          _resetControlsTimer();

          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.backspace) {
            widget.onExit();
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.mediaPlayPause) {
            _togglePlay();
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.channelUp || key == LogicalKeyboardKey.pageUp) {
            _zap(-1);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.channelDown || key == LogicalKeyboardKey.pageDown) {
            _zap(1);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.equal || key == LogicalKeyboardKey.numpadAdd) {
            _applyZoom(_zoomScale + _zoomStep);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.minus || key == LogicalKeyboardKey.numpadSubtract) {
            _applyZoom(_zoomScale - _zoomStep);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) {
            _resetZoom();
            return KeyEventResult.handled;
          }

          if (!_controls) {
            if (key == LogicalKeyboardKey.arrowUp) {
              _zap(-1);
              return KeyEventResult.handled;
            } else if (key == LogicalKeyboardKey.arrowDown) {
              _zap(1);
              return KeyEventResult.handled;
            } else if (key == LogicalKeyboardKey.arrowRight) {
              _applyZoom(_zoomScale + _zoomStep);
              return KeyEventResult.handled;
            } else if (key == LogicalKeyboardKey.arrowLeft) {
              _applyZoom(_zoomScale - _zoomStep);
              return KeyEventResult.handled;
            } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
              setState(() => _controls = true);
              _playBtnFocus.requestFocus();
              return KeyEventResult.handled;
            }
          }

          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: () {
            setState(() => _controls = !_controls);
            if (_controls) _resetControlsTimer();
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // ── Video Player Surface with Zoom Transform ──────────────────
                Positioned.fill(
                  child: Center(
                    child: Transform.scale(
                      scale: _zoomScale,
                      child: Transform.translate(
                        offset: Offset(_panX, _panY),
                        child: _controller != null && _controller!.value.isInitialized
                            ? FittedBox(
                                fit: _getBoxFit(),
                                child: SizedBox(
                                  width: _controller!.value.size.width,
                                  height: _controller!.value.size.height,
                                  child: VideoPlayer(_controller!),
                                ),
                              )
                            : Container(color: Colors.black),
                      ),
                    ),
                  ),
                ),

                // ── Buffering Spinner ─────────────────────────────────────────
                if (_buffering && !_failed)
                  const Center(child: Spinner(size: 56)),

                // ── Error Message ─────────────────────────────────────────────
                if (_failed)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: T(
                        "This stream isn't available right now.\nSwitch channel to try another.",
                        size: 20,
                        color: Colors.white,
                        maxLines: 3,
                        align: TextAlign.center,
                      ),
                    ),
                  ),

                // ── Zoom HUD ──────────────────────────────────────────────────
                if (_showZoomHud && _zoomScale != 1.0)
                  Positioned(
                    top: 48,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xE610131A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: iosBlue.withOpacity(0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const TvIcon(Ico.search, tint: iosBlue, size: 16),
                            const SizedBox(width: 10),
                            T(
                              '${_zoomScale.toStringAsFixed(1)}×   Press 0 to reset',
                              size: 14,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Channel Banner (Top-Left, Auto-Hides) ──────────────────────
                if (_controls || _banner)
                  Positioned(
                    top: 40,
                    left: 56,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xEB11141D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: aestheticBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: iosBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: T(
                              ch.mediaType == MediaType.radio
                                  ? 'RADIO'
                                  : (ch.mediaType == MediaType.webcam ? 'CAM' : 'LIVE'),
                              size: 11,
                              weight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          T(ch.name, size: 19, weight: FontWeight.w600),
                          if (ch.group.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            T('· ${ch.group}', size: 14, color: aestheticMuted),
                          ],
                        ],
                      ),
                    ),
                  ),

                // ── Bottom Playback Controls Bar ──────────────────────────────
                if (_controls)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xF00A0C10),
                        border: Border(top: BorderSide(color: aestheticBorder.withOpacity(0.5))),
                      ),
                      padding: const EdgeInsets.fromLTRB(56, 20, 56, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Zoom Slider Row
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: aestheticSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: aestheticBorder),
                            ),
                            child: Row(
                              children: [
                                const TvIcon(Ico.search, tint: iosBlue, size: 18),
                                const SizedBox(width: 14),
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Glass(
                                    borderRadius: BorderRadius.circular(18),
                                    solidOnFocus: true,
                                    focusScale: 1.1,
                                    onClick: () => _applyZoom(_zoomScale - _zoomStep),
                                    builder: (context, focused) => Center(
                                      child: TvIcon(
                                        Ico.minus,
                                        tint: focused ? Colors.black : Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: (_zoomScale - _zoomMin) / (_zoomMax - _zoomMin),
                                      backgroundColor: Colors.white.withOpacity(0.15),
                                      valueColor: const AlwaysStoppedAnimation(iosBlue),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Glass(
                                    borderRadius: BorderRadius.circular(18),
                                    solidOnFocus: true,
                                    focusScale: 1.1,
                                    onClick: () => _applyZoom(_zoomScale + _zoomStep),
                                    builder: (context, focused) => Center(
                                      child: TvIcon(
                                        Ico.plus,
                                        tint: focused ? Colors.black : Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                T('${_zoomScale.toStringAsFixed(1)}×', size: 14, weight: FontWeight.w600),
                                const SizedBox(width: 14),
                                Glass(
                                  borderRadius: BorderRadius.circular(12),
                                  solidOnFocus: true,
                                  onClick: _resetZoom,
                                  builder: (context, focused) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    child: T(
                                      'Reset',
                                      size: 13,
                                      weight: FontWeight.w500,
                                      color: focused ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Playback Controls Row
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: aestheticSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: aestheticBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      T(ch.name, size: 22, weight: FontWeight.bold),
                                      const SizedBox(height: 4),
                                      T(
                                        [
                                          ch.country,
                                          ch.language,
                                          ch.group,
                                          ch.quality,
                                          'Src ${_src + 1}/${ch.sources.length}',
                                          '${_idx + 1}/${widget.list.length}',
                                        ].where((s) => s.isNotEmpty).join('  ·  '),
                                        size: 13,
                                        color: aestheticMuted,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    RoundBtn(
                                      onClick: () => _zap(-1),
                                      icon: (color) => TvIcon(Ico.prev, tint: color),
                                    ),
                                    const SizedBox(width: 12),
                                    RoundBtn(
                                      focusNode: _playBtnFocus,
                                      onClick: _togglePlay,
                                      icon: (color) => TvIcon(isPlaying ? Ico.pause : Ico.play, tint: color),
                                    ),
                                    const SizedBox(width: 12),
                                    RoundBtn(
                                      onClick: () => _zap(1),
                                      icon: (color) => TvIcon(Ico.next, tint: color),
                                    ),
                                    const SizedBox(width: 12),
                                    RoundBtn(
                                      onClick: () {
                                        widget.store.toggleFav(ch);
                                        setState(() {});
                                      },
                                      icon: (color) {
                                        final isFav = widget.store.isFav(ch);
                                        return TvIcon(
                                          isFav ? Ico.heartFilled : Ico.heartOutline,
                                          tint: isFav ? const Color(0xFFFF4D6D) : color,
                                        );
                                      },
                                    ),
                                  ],
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
          ),
        ),
      ),
    );
  }
}
