import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/blocklisttile.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/blockview.dart'; // Removed unused imports

class ICCacheView extends StatefulWidget {
  final String cacheid;
  final double tabHeight;
  const ICCacheView({super.key, required this.cacheid, double? tabHeight})
    : tabHeight = (tabHeight != null) ? tabHeight : 42;

  @override
  State<ICCacheView> createState() {
    log("build", name: runtimeType.toString());
    return _ICCacheView();
  }
}

class _ICCacheView extends State<ICCacheView> {
  Cache userCache = Cache(name: "loading");
  List<Block> _userBlock = [];
  int _selectedIndex = 0;

  Future<void> _loadBlocks() async {
    List<Block> blocks = await FileHandler.findBlocksByCacheId(widget.cacheid);
    setState(() {
      _userBlock = blocks;
    });
  }

  Future<void> _loadCache() async {
    Cache? cache = await FileHandler.findCacheById(widget.cacheid);
    setState(() {
      userCache = cache!;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadBlocks();
    _loadCache();
  }

  @override
  void didUpdateWidget(covariant ICCacheView oldWidget) {
    log("rebuild", name: runtimeType.toString());
    super.didUpdateWidget(oldWidget);
    _loadCache();
    _loadBlocks();
  }

  @override
  Widget build(BuildContext context) {
    log("build", name: runtimeType.toString());
    Widget pageWidget = Placeholder();
    // _loadCache();
    // _loadBlocks();
    return Scaffold(
      appBar: AppBar(title: Text(userCache.name)),
      body: Column(
        children: [
          const Divider(thickness: 2, height: 2),
          Container(
            color: Theme.of(context).colorScheme.surface,
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
                        child: ICBlockListTile(
                          name: entry.value.name,
                          blockid: entry.value.id,
                          onTap: () {
                            setState(() {
                              _selectedIndex = entry.key;
                            });
                          },
                          onEditName: () async {
                            await _loadBlocks();
                          },
                          isSelected: _selectedIndex == entry.key,
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
                      cacheid: widget.cacheid,
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
            child: pageWidget, // Pass cacheId if needed
          ),
        ],
      ),
    );
  }
}
