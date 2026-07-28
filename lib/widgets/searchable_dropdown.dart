import 'package:flutter/material.dart';

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
        onTap: () => _removeOverlay(), // ✅ إغلاق عند النقر خارج القائمة
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              width: MediaQuery.of(context).size.width - 32,
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: const Offset(0, 48),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => ListTile(
                        title: Text(widget.labelBuilder(filtered[i])),
                        onTap: () {
                          widget.onChanged?.call(filtered[i]);
                          _searchCtrl.text = widget.labelBuilder(filtered[i]);
                          _removeOverlay();
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
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry!.dispose();
      _overlayEntry = null;
      _overlayVisible = false;
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: widget.hint ?? 'بحث...',
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        onTap: () {
          _showOverlay();
        },
        onChanged: (val) {
          setState(() {
            filtered = widget.items.where((item) => widget.labelBuilder(item).contains(val)).toList();
          });
          _overlayEntry?.markNeedsBuild();
        },
      ),
    );
  }
}