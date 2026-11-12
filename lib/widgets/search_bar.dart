import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/tv_icon.dart';

class TvSearchBar extends StatefulWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;
  final String hint;

  const TvSearchBar({
    super.key,
    required this.query,
    required this.onQueryChanged,
    this.hint = 'Search channels…',
  });

  @override
  State<TvSearchBar> createState() => _TvSearchBarState();
}

class _TvSearchBarState extends State<TvSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant TvSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && _controller.text != widget.query) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 44,
      decoration: BoxDecoration(
        color: aestheticSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isFocused ? iosBlue : aestheticBorder,
          width: _isFocused ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          TvIcon(
            Ico.search,
            tint: _isFocused ? iosBlue : aestheticMuted,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Roboto',
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: widget.onQueryChanged,
            ),
          ),
          if (widget.query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onQueryChanged('');
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: TvIcon(Ico.close, tint: aestheticMuted, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}
