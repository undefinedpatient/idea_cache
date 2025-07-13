import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/blocklisttile.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/blockview.dart';
import 'package:idea_cache/page/emptypage.dart'; // Removed unused imports

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
  List<ICBlock> _userBlocks = [];
  int _selectedIndex = 0;

  Future<void> _loadBlocks() async {
    List<ICBlock> blocks = await FileHandler.findBlocksByCacheId(
      widget.cacheid,
    );
    setState(() {
      _userBlocks = blocks;
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
    _selectedIndex = 0;
    _loadCache();
    _loadBlocks();
  }

  @override
  Widget build(BuildContext context) {
    if (userCache == null) {
      return ICEmptyPage();
    }
    log("build", name: runtimeType.toString());
    Widget pageWidget = ICEmptyPage();
    if (_userBlocks.isNotEmpty) {
      pageWidget = ICBlockView(blockid: _userBlocks[_selectedIndex].id);
    }
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
                                Navigator.pop(context);
                                await FileHandler.deleteCacheById(
                                  userCache!.id,
                                );
                                final SnackBar snackBar = SnackBar(
                                  content: Text(
                                    "Cache ${userCache!.name} Deleted!",
                                  ),
                                );
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(snackBar);
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
                    children: _userBlocks.asMap().entries.map((
                      MapEntry<int, ICBlock> entry,
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
                        final ICBlock item = _userBlocks.removeAt(oldIndex);
                        _userBlocks.insert(newIndex, item);
                      });
                    },
                  ),
                ),
                MenuItemButton(
                  requestFocusOnHover: false,
                  onPressed: () async {
                    ICBlock block = ICBlock(
                      cacheid: widget.cacheid,
                      name: "Untitled",
                    );
                    await FileHandler.appendBlock(block);
                    await _loadBlocks();
                  },
                  leadingIcon: Icon(Icons.add),
                  child: Text("Add Block"),
                ),
                MenuItemButton(
                  requestFocusOnHover: false,
                  onPressed: () async {
                    ICBlock oldBlock = _userBlocks[_selectedIndex];
                    await FileHandler.deleteBlocksById(oldBlock.id);
                    final SnackBar snackBar = SnackBar(
                      content: Text("Block ${oldBlock.name} Deleted!"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    await _loadBlocks();
                    if (_selectedIndex >= _userBlocks.length) {
                      _selectedIndex = _userBlocks.length - 1;
                      // Hard Limiting tghe _selectedIndex
                      if (_selectedIndex == -1) {
                        _selectedIndex = 0;
                      }
                    }
                  },
                  leadingIcon: Icon(Icons.delete_outlined),
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
