import 'package:flutter/material.dart';
import '../core/theme.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?>? onChanged;
  final T? initialValue;
  final String? hint;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.labelBuilder,
    this.onChanged,
    this.initialValue,
    this.hint,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<T> filtered = [];
  bool _overlayVisible = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    filtered = widget.items;
  }

  void _showOverlay() {
    if (_overlayVisible) return;
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (ctx) => GestureDetector(
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              width: MediaQuery.of(context).size.width - 32,
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: const Offset(0, 56),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E2E)
                      : Colors.white,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => ListTile(
                        title: Text(widget.labelBuilder(filtered[i])),
                        hoverColor:
                            AppTheme.emeraldGreen.withOpacity(0.1),
                        onTap: () {
                          widget.onChanged?.call(filtered[i]);
                          _searchCtrl.text = widget.labelBuilder(filtered[i]);
                          _removeOverlay();
                          setState(() => _isFocused = false);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
    _overlayVisible = true;
    setState(() => _isFocused = true);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry!.dispose();
      _overlayEntry = null;
      _overlayVisible = false;
      setState(() => _isFocused = false);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _searchCtrl,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: widget.hint ?? 'بحث...',
          hintStyle: TextStyle(
            color: isDark
                ? Colors.grey[400]
                : AppTheme.darkSlate.withOpacity(0.5),
          ),
          suffixIcon: Icon(
            _isFocused ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: AppTheme.emeraldGreen,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 2),
          ),
        ),
        onTap: () {
          if (_overlayVisible) {
            _removeOverlay();
          } else {
            _showOverlay();
          }
        },
        onChanged: (val) {
          setState(() {
            filtered = widget.items
                .where(
                    (item) => widget.labelBuilder(item).contains(val))
                .toList();
          });
          _overlayEntry?.markNeedsBuild();
        },
      ),
    );
  }
}