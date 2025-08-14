import 'dart:developer';

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
  final double tabHeight;
  final void Function() onPageDeleted;

  const ICCacheView({
    super.key,
    required this.cacheid,
    required this.onPageDeleted,
    double? tabHeight,
  }) : tabHeight = (tabHeight != null) ? tabHeight : 42;

  @override
  State<ICCacheView> createState() {
    return _ICCacheView();
  }
}

class _ICCacheView extends State<ICCacheView> {
  Cache localCache = Cache(name: "loading");
  List<ICBlock> localBlocks = [];
  final TextEditingController _textEditingController = TextEditingController(
    text: "",
  );

  int _selectedIndex = -1;
  OverlayEntry? entryImportOverlay;
  final FocusNode _focusNode = FocusNode();

  Future<void> _loadBlocks() async {
    List<ICBlock> blocks = await FileHandler.findBlocksByCacheId(
      widget.cacheid,
    );
    setState(() {
      localBlocks = blocks;
    });
  }

  Future<void> _loadCache() async {
    Cache? cache = await FileHandler.findCacheById(widget.cacheid);
    if (cache == null) {
      return;
    }
    setState(() {
      localCache;
    });
  }

  Future<void> _deleteBlock(BuildContext context) async {
    Navigator.pop(context);
    ICBlock oldBlock = localBlocks[_selectedIndex];
    localCache.removeBlockId(oldBlock.id);
    await FileHandler.updateCache(localCache!);
    await FileHandler.deleteBlocksById(oldBlock.id);

    final SnackBar snackBar = SnackBar(
      content: Text("Block ${oldBlock.name} Deleted!"),
      duration: Durations.extralong3,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await _loadBlocks();
    if (_selectedIndex >= localBlocks.length) {
      _selectedIndex = localBlocks.length - 1;
      // Hard Limiting the _selectedIndex
      if (_selectedIndex == -1) {
        _selectedIndex = 0;
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ICCacheView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _selectedIndex = -1;
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ICSettingsModel appState = context.watch<ICSettingsModel>();
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
        onEdit: () async {
          await _loadBlocks();
          await _loadCache();
        },
      );
    } else if (localBlocks.isNotEmpty) {
      pageWidget = ICBlockView(blockid: localBlocks[_selectedIndex].id);
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: Consumer<ICCacheModel>(
          builder: (context, model, child) {
            localCache = model.caches.firstWhere(
              (item) => item.id == widget.cacheid,
            );
            return Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(localCache.name),
                if (MediaQuery.of(context).size.width > 520)
                  Tooltip(
                    message: (appState.setting.toolTipsEnabled)
                        ? "Rename Cache"
                        : "",
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            _textEditingController.text = localCache.name;
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
                                      onSubmitted: (value) {
                                        localCache.name = value;
                                        model.updateCache(localCache);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        localCache.name =
                                            _textEditingController.text;
                                        model.updateCache(localCache);
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Save"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                    ),
                  ),
              ],
            );
          },
        ),
        actionsPadding: EdgeInsets.fromLTRB(0, 0, 16, 0),
        actions: [
          Tooltip(
            message: (appState.setting.toolTipsEnabled) ? "Pin Cache" : "",
            child: Consumer<ICCacheModel>(
              builder: (context, model, child) {
                return (model.isLoading)
                    ? LinearProgressIndicator()
                    : IconButton(
                        onPressed: () async {
                          setState(() {
                            localCache.priority = 1 - localCache.priority;
                          });
                          model.updateCache(localCache);
                        },
                        icon: Icon(
                          (localCache.priority == 0)
                              ? Icons.push_pin_outlined
                              : Icons.push_pin,
                        ),
                      );
              },
            ),
          ),
          Tooltip(
            message: (appState.setting.toolTipsEnabled) ? "Delete Cache" : "",
            child: Consumer<ICCacheModel>(
              builder: (context, model, child) {
                return IconButton(
                  onPressed: () async {
                    await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => KeyboardListener(
                        focusNode: _focusNode,
                        autofocus: true,
                        onKeyEvent: (KeyEvent event) async {
                          if (event.logicalKey.keyLabel == 'Y' ||
                              event.logicalKey.keyLabel == "Enter") {
                            widget.onPageDeleted();
                            localCache = Cache(name: "Loading");

                            model.deleteCacheById(widget.cacheid);
                            Navigator.pop(context);
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
                                        widget.onPageDeleted();
                                        localCache = Cache(name: "Loading");

                                        model.deleteCacheById(widget.cacheid);
                                        Navigator.pop(context);
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

                  icon: Icon(Icons.delete_outline),
                );
              },
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
                  child: SizedBox(width: 90, child: Text("Overview")),
                ),
                Consumer<ICBlockModel>(
                  builder: (context, model, child) {
                    return Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: model.cacheBlocksMap[widget.cacheid]!
                            .asMap()
                            .entries
                            .map((MapEntry<int, ICBlock> entry) {
                              return ICBlockListTile(
                                name: entry.value.name,
                                blockid: entry.value.id,
                                onTap: () {
                                  if (appState.isContentEdited) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Warning: Content Not Saved",
                                        ),
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
                              );
                            })
                            .toList(),
                      ),
                    );
                  },
                ),
                Consumer<ICBlockModel>(
                  builder: (context, model, child) {
                    return Tooltip(
                      message: (appState.setting.toolTipsEnabled)
                          ? "Add Block"
                          : "",
                      child: MenuItemButton(
                        requestFocusOnHover: false,
                        onPressed: () async {
                          model.createBlock(widget.cacheid);
                        },
                        child: Icon(Icons.add),
                      ),
                    );
                  },
                ),
                // Delete Block Button can only Appear when user is viewing a block
                if (_selectedIndex != -1)
                  Tooltip(
                    message: (appState.setting.toolTipsEnabled)
                        ? "Delete Block"
                        : "",
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
