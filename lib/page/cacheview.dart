import 'package:flutter/material.dart';
import 'package:idea_cache/component/blocklisttile.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/page/blockview.dart'; // Removed unused imports

class ICCacheView extends StatefulWidget {
  final String cacheId;
  final double tabHeight;
  const ICCacheView({super.key, required this.cacheId, double? tabHeight})
    : tabHeight = (tabHeight != null) ? tabHeight : 42;

  @override
  State<ICCacheView> createState() => _ICCacheView();
}

class _ICCacheView extends State<ICCacheView> {
  List<Block> _userBlock = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cacheId.isEmpty ? 'Cache View' : widget.cacheId),
      ),
      body: Column(
        children: [
          const Divider(thickness: 2, height: 2),
          SizedBox(
            height: widget.tabHeight, // Fixed height for tab bar
            width: MediaQuery.of(context).size.width,
            // Use SizedBox to container listtile to avoid overflow
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ReorderableListView(
                    buildDefaultDragHandles: false,
                    scrollDirection: Axis.horizontal,
                    children: _userBlock.asMap().entries.map((
                      MapEntry<int, Block> entry,
                    ) {
                      return ReorderableDelayedDragStartListener(
                        index: entry.key,
                        key: ValueKey(entry.value.id),
                        child: Text("dd"),
                      );
                    }).toList(),
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final Block item = _userBlock.removeAt(oldIndex);
                        _userBlock.insert(newIndex, item);
                      });
                    },
                  ),
                ),
                MenuItemButton(
                  requestFocusOnHover: false,
                  onPressed: () {},
                  leadingIcon: Icon(Icons.add),
                  child: Text("Add Block"),
                ),
              ],
            ),
          ),

          const Divider(thickness: 2, height: 2),
          Expanded(
            child: ICBlockView(), // Pass cacheId if needed
          ),
        ],
      ),
    );
  }
}
