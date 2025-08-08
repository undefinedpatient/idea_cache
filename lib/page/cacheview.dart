import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/component/blocklisttile.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/blockview.dart';
import 'package:idea_cache/page/cacheoverview.dart';
import 'package:idea_cache/page/emptypage.dart';
import 'package:provider/provider.dart'; // Removed unused imports

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
  TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  List<ICBlock> _userBlocks = [];
  int _selectedIndex = -1;
  OverlayEntry? entryImportOverlay;
  final FocusNode _focusNode = FocusNode();

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
      duration: Durations.extralong3,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    await FileHandler.deleteCacheById(userCache!.id);

    await widget.reloadCaches();
  }

  Future<void> _deleteBlock(BuildContext context) async {
    Navigator.pop(context);
    ICBlock oldBlock = _userBlocks[_selectedIndex];
    userCache!.removeBlockId(oldBlock.id);
    await FileHandler.updateCache(userCache!);
    await FileHandler.deleteBlocksById(oldBlock.id);

    final SnackBar snackBar = SnackBar(
      content: Text("Block ${oldBlock.name} Deleted!"),
      duration: Durations.extralong3,
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
    super.didUpdateWidget(oldWidget);
    setState(() {
      _selectedIndex = -1;
    });

    _loadCache();
    _loadBlocks();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ICAppState appState = context.watch<ICAppState>();
    if (userCache == null) {
      return ICEmptyPage();
    }
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(userCache!.name),
            if (MediaQuery.of(context).size.width > 520)
              Tooltip(
                message: (appState.toolTipsEnabled) ? "Rename Cache" : "",
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        _textEditingController.text = userCache!.name;
                        return Dialog(
                          child: Container(
                            width: 240,
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 8,
                              children: [
                                TextField(
                                  controller: _textEditingController,
                                  decoration: InputDecoration(
                                    labelText: "Edit Cache Name",
                                  ),
                                  onSubmitted: (value) async {
                                    userCache!.name = value;
                                    await FileHandler.updateCache(userCache!);
                                    await widget.reloadCaches();

                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  onPressed: () async {
                                    userCache!.name =
                                        _textEditingController.text;
                                    await FileHandler.updateCache(userCache!);
                                    await widget.reloadCaches();

                                    Navigator.pop(context);
                                  },
                                  child: Text("Save"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.edit_outlined),
                ),
              ),
          ],
        ),
        actionsPadding: EdgeInsets.fromLTRB(0, 0, 16, 0),
        actions: [
          Tooltip(
            message: (appState.toolTipsEnabled) ? "Pin Cache" : "",
            child: IconButton(
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
          ),
          Tooltip(
            message: (appState.toolTipsEnabled) ? "Delete Cache" : "",
            child: IconButton(
              onPressed: () async {
                await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => KeyboardListener(
                    focusNode: _focusNode,
                    autofocus: true,
                    onKeyEvent: (KeyEvent event) async {
                      if (event.logicalKey.keyLabel == 'Y' ||
                          event.logicalKey.keyLabel == "Enter") {
                        await _deleteCache(context);
                      }
                      if (event.logicalKey.keyLabel == 'N') {
                        Navigator.pop(context);
                      }
                    },
                    child: Dialog(
                      shape: BeveledRectangleBorder(),
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
          ),
        ],
      ),
      body: Column(
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
                    if (appState.isContentEdited) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Warning: Content Not Saved"),
                          duration: Durations.extralong3,
                        ),
                      );
                      appState.setContentEditedState(false);
                      return;
                    }
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
                        ? Icons.description
                        : Icons.description_outlined,
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
                            if (appState.isContentEdited) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Warning: Content Not Saved"),
                                  duration: Durations.extralong3,
                                ),
                              );
                              // set the edited state such that user can ignore the warning
                              appState.setContentEditedState(false);
                              return;
                            }
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
                Tooltip(
                  message: (appState.toolTipsEnabled) ? "Add Block" : "",
                  child: MenuItemButton(
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
                    child: Icon(Icons.add),
                  ),
                ),
                // Delete Block Button can only Appear when user is viewing a block
                if (_selectedIndex != -1)
                  Tooltip(
                    message: (appState.toolTipsEnabled) ? "Delete Block" : "",
                    child: MenuItemButton(
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
                              shape: BeveledRectangleBorder(),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
