import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/blocklisttile.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/blockview.dart'; // Removed unused imports

class ICCacheView extends StatefulWidget {
  final String cacheid;
  final Function() reloadCaches;
  final double tabHeight;

  const ICCacheView({
    super.key,
    required this.cacheid,
    required Function() reloadCaches,
    double? tabHeight,
  }) : reloadCaches = reloadCaches,
       tabHeight = (tabHeight != null) ? tabHeight : 42;

  @override
  State<ICCacheView> createState() {
    log("createState", name: runtimeType.toString());
    return _ICCacheView();
  }
}

class _ICCacheView extends State<ICCacheView> {
  Cache? userCache = Cache(name: "loading");
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
      userCache = cache;
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
    log("didUpdateWidget", name: runtimeType.toString());
    super.didUpdateWidget(oldWidget);
    _loadCache();
    _loadBlocks();
  }

  @override
  Widget build(BuildContext context) {
    if (userCache == null) {
      return Placeholder();
    }
    log("build", name: runtimeType.toString());
    Widget pageWidget = ICBlockView();
    return Scaffold(
      appBar: AppBar(
        title: Text(userCache!.name),
        actionsPadding: EdgeInsets.fromLTRB(0, 0, 16, 0),
        actions: [
          IconButton(
            onPressed: () async {
              await showDialog<String>(
                context: context,
                builder: (BuildContext context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text("Confirm Cache Deletion?"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () async {
                                log(
                                  "deleted Cache ${userCache!.id}",
                                  name: runtimeType.toString(),
                                );
                                Navigator.pop(context);
                                await FileHandler.deleteCacheById(
                                  userCache!.id,
                                );
                                await widget.reloadCaches();
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },

            icon: Icon(Icons.delete),
          ),
        ],
      ),
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
