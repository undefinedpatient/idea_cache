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
  ICBlock? activeBlock;
  final TextEditingController _textEditingController = TextEditingController(
    text: "",
  );

  int _selectedIndex = -1;
  OverlayEntry? entryImportOverlay;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ICCacheView oldWidget) {
    log("updated");
    super.didUpdateWidget(oldWidget);
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
    if (activeBlock == null) {
      pageWidget = ICCacheOverview(
        cacheid: widget.cacheid,
        setPage: (int index, ICBlock block) {
          setState(() {
            _selectedIndex = index;
            activeBlock = block;
          });
        },
      );
    } else {
      pageWidget = ICBlockView(block: activeBlock!);
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
                    activeBlock = null;
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
                    List<ICBlock> localBlocks =
                        model.cacheBlocksMap[widget.cacheid] ?? [];
                    return Expanded(
                      child: ListView(
                        addAutomaticKeepAlives: false,
                        scrollDirection: Axis.horizontal,
                        children: localBlocks.asMap().entries.map((
                          MapEntry<int, ICBlock> entry,
                        ) {
                          return ICBlockListTile(
                            key: ObjectKey(entry.value),
                            // name: entry.value.name,
                            block: entry.value,
                            // blockid: entry.value.id,
                            onTap: () {
                              log(entry.value.name);
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
                                activeBlock = localBlocks[_selectedIndex];
                              });
                            },
                            isSelected: _selectedIndex == entry.key,
                          );
                        }).toList(),
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
