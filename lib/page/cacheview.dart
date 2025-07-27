import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/blocklisttile.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/blockview.dart';
import 'package:idea_cache/page/cacheoverview.dart';
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
    // log("createState", name: runtimeType.toString());
    return _ICCacheView();
  }
}

class _ICCacheView extends State<ICCacheView> {
  Cache? userCache = Cache(name: "loading");
  List<ICBlock> _userBlocks = [];
  int _selectedIndex = -1;
  FocusNode _focusNode = FocusNode();

  Future<void> _loadBlocks() async {
    List<ICBlock> blocks = await FileHandler.findBlocksByCacheId(
      widget.cacheid,
    );
    setState(() {
      _userBlocks = blocks;
    });
    // log(name: "_loadBlocks()", "${blocks.map((block) => block.id)}");
  }

  Future<void> _loadCache() async {
    Cache? cache = await FileHandler.findCacheById(widget.cacheid);
    setState(() {
      userCache = cache;
    });
  }

  Future<void> reorderBlock(int from, int to) async {
    if (userCache == null) {
      return;
    }
    userCache!.reorderBlockId(from, to);
    FileHandler.updateCache(userCache!);
  }

  Future<void> _deleteCache(BuildContext context) async {
    Navigator.pop(context);
    final SnackBar snackBar = SnackBar(
      content: Text("Cache ${userCache!.name} Deleted!"),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    await FileHandler.deleteCacheById(userCache!.id);

    await widget.reloadCaches();
  }

  Future<void> _deleteBlock(BuildContext context) async {
    Navigator.pop(context);
    ICBlock oldBlock = _userBlocks[_selectedIndex];
    userCache!.removeBlockIds(oldBlock.id);
    await FileHandler.updateCache(userCache!);
    await FileHandler.deleteBlocksById(oldBlock.id);

    final SnackBar snackBar = SnackBar(
      content: Text("Block ${oldBlock.name} Deleted!"),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await _loadBlocks();
    if (_selectedIndex >= _userBlocks.length) {
      _selectedIndex = _userBlocks.length - 1;
      // Hard Limiting the _selectedIndex
      if (_selectedIndex == -1) {
        _selectedIndex = 0;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBlocks();
    _loadCache();
  }

  @override
  void didUpdateWidget(covariant ICCacheView oldWidget) {
    // log("didUpdateWidget", name: runtimeType.toString());
    super.didUpdateWidget(oldWidget);
    setState(() {
      _selectedIndex = -1;
    });

    _loadCache();
    _loadBlocks();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userCache == null) {
      return ICEmptyPage();
    }
    // log("build", name: runtimeType.toString());
    Widget pageWidget = ICEmptyPage();
    // -1 means that user is in Overview Page
    if (_selectedIndex == -1) {
      pageWidget = ICCacheOverview(
        cacheid: widget.cacheid,
        setPage: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      );
    } else if (_userBlocks.isNotEmpty) {
      pageWidget = ICBlockView(blockid: _userBlocks[_selectedIndex].id);
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: Text(userCache!.name),
        actionsPadding: EdgeInsets.fromLTRB(0, 0, 16, 0),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                userCache?.priority = 1 - userCache!.priority;
              });

              await FileHandler.updateCache(userCache!);
              _loadCache();
            },
            icon: Icon(
              (userCache?.priority == 0)
                  ? Icons.push_pin_outlined
                  : Icons.push_pin,
            ),
          ),
          IconButton(
            onPressed: () async {
              await showDialog<String>(
                context: context,
                builder: (BuildContext context) => KeyboardListener(
                  focusNode: _focusNode,
                  autofocus: true,
                  onKeyEvent: (KeyEvent event) async {
                    log(event.logicalKey.keyLabel);
                    if (event.logicalKey.keyLabel == 'Y' ||
                        event.logicalKey.keyLabel == "Enter") {
                      await _deleteCache(context);
                    }
                    if (event.logicalKey.keyLabel == 'N') {
                      Navigator.pop(context);
                    }
                  },
                  child: Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Confirm Cache Deletion?",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await _deleteCache(context);
                                },
                                child: const Text(
                                  "Delete (Y)",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Close (n)"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },

            icon: Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        // spacing: 0.0,
        // spacing: 0.0,
        children: [
          const Divider(thickness: 2, height: 2),
          // Use SizedBox to container listtile to avoid overflow
          SizedBox(
            
            height: widget.tabHeight, // Fixed height for tab bar
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: <Widget>[
                MenuItemButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = -1;
                    });
                  },
                  style: MenuItemButton.styleFrom(
                    backgroundColor: (_selectedIndex == -1)
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  clipBehavior: Clip.hardEdge,
                  requestFocusOnHover: false,
                  leadingIcon: Icon(
                    (_selectedIndex == -1)
                        ? Icons.square
                        : Icons.square_outlined,
                  ),
                  child: SizedBox(width: 120, child: Text("Overview")),
                ),
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
                    onReorder: (int oldIndex, int newIndex) async {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final ICBlock item = _userBlocks.removeAt(oldIndex);
                        _userBlocks.insert(newIndex, item);
                      });
                      await reorderBlock(oldIndex, newIndex);
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
                    userCache!.addBlockId(block.id);
                    await FileHandler.updateCache(userCache!);
                    await _loadBlocks();
                  },
                  leadingIcon: Icon(Icons.add),
                  child: Text("Add Block "),
                ),
                if (_selectedIndex != -1)
                  MenuItemButton(
                    requestFocusOnHover: false,
                    onPressed: () async {
                      await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => KeyboardListener(
                          focusNode: _focusNode,
                          autofocus: true,
                          onKeyEvent: (KeyEvent keyEvent) {
                            if (keyEvent.logicalKey.keyLabel == "Y" ||
                                keyEvent.logicalKey.keyLabel == "Enter") {
                              _deleteBlock(context);
                            }
                            if (keyEvent.logicalKey.keyLabel == "N") {
                              Navigator.pop(context);
                            }
                          },
                          child: Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                spacing: 8,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "Confirm Block Deletion?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          await _deleteBlock(context);
                                        },
                                        child: const Text(
                                          "Delete (Y)",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Close (n)"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
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
