import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/blockview.dart'; // Removed unused imports

class ICCacheView extends StatefulWidget {
  final Cache cache;
  final double tabHeight;
  const ICCacheView({super.key, required this.cache, double? tabHeight})
    : tabHeight = (tabHeight != null) ? tabHeight : 42;

  @override
  State<ICCacheView> createState() {
    return _ICCacheView();
  }
}

class _ICCacheView extends State<ICCacheView> {
  List<Block> _userBlock = [];
  Future<void> _loadBlocks() async {
    List<Block> blocks = await FileHandler.readBlocks();
    setState(() {
      _userBlock = blocks;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadBlocks();
    // _loadCache();
  }

  @override
  Widget build(BuildContext context) {
    // _loadCache();
    // _loadBlocks();
    return Scaffold(
      appBar: AppBar(title: Text(widget.cache.name)),
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
                        child: MenuItemButton(
                          requestFocusOnHover: false,
                          onPressed: () {},
                          leadingIcon: Icon(Icons.square),
                          child: Text(entry.value.name),
                        ),
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
                  onPressed: () async {
                    Block block = Block(
                      cacheid: widget.cache.id,
                      name: "Untitled",
                    );
                    await FileHandler.appendBlock(block);
                    await _loadBlocks();
                  },
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
