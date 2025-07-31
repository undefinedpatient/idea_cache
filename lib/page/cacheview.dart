import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
  OverlayEntry? overlayEntryImport;
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

  void _toggleImportOverlay(BuildContext context) {
    if (overlayEntryImport == null) {
      overlayEntryImport = OverlayEntry(
        builder: (BuildContext context) {
          String selectedFileName = "None";
          List<ICBlock> externalBlocks = List.empty(growable: true);
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setOverlayState) {
              return GestureDetector(
                onTap: () {
                  overlayEntryImport?.remove();
                  overlayEntryImport?.dispose();
                  overlayEntryImport = null;
                },
                child: Material(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(16),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        // Clamping
                        height: (MediaQuery.of(context).size.height < 600)
                            ? MediaQuery.of(context).size.height - 24
                            : 600,
                        width: (MediaQuery.of(context).size.width < 800)
                            ? MediaQuery.of(context).size.width - 96
                            : 800,
                        //
                        child: Column(
                          spacing: 16,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Import", textScaler: TextScaler.linear(1.1)),
                            Container(
                              padding: EdgeInsets.all(16),
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Select File: $selectedFileName"),
                                  IconButton(
                                    onPressed: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                            allowMultiple: false,
                                            allowedExtensions: ["json"],
                                          );

                                      if (result != null) {
                                        File file = File(
                                          result.files.single.path!,
                                        );
                                        log(file.path);
                                        List<ICBlock> tempBlockList =
                                            await FileHandler.readBlocks(
                                              dataString: file
                                                  .readAsStringSync(),
                                            );
                                        setOverlayState(() {
                                          selectedFileName = file.path;
                                          externalBlocks = tempBlockList;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.folder),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                                child: ListView(
                                  children: externalBlocks.map((ICBlock block) {
                                    return ListTile(
                                      title: Text(block.name),
                                      trailing: IconButton(
                                        onPressed: () {
                                          setOverlayState(() {
                                            externalBlocks.remove(block);
                                          });
                                        },
                                        icon: Icon(Icons.remove),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const Text(
                              "Hint: Duplicate blocks will be replaced",
                            ),
                            TextButton(
                              onPressed: () async {
                                for (
                                  int i = 0;
                                  i < externalBlocks.length;
                                  i++
                                ) {
                                  ICBlock newBlock = ICBlock(
                                    cacheid: userCache!.id,
                                    name: externalBlocks[i].name,
                                  );
                                  newBlock.content = externalBlocks[i].content;
                                  await FileHandler.appendBlock(newBlock);
                                  userCache!.addBlockId(newBlock.id);
                                  await FileHandler.updateCache(userCache!);
                                }
                                // After importing remove the overlay and reload the blocks
                                await _loadBlocks();
                                overlayEntryImport?.remove();
                                overlayEntryImport?.dispose();
                                overlayEntryImport = null;
                              },
                              child: Text("Import Blocks"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
      Overlay.of(context).insert(overlayEntryImport!);
    } else {
      overlayEntryImport?.remove();
      overlayEntryImport?.dispose();
      overlayEntryImport = null;
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
              _toggleImportOverlay(context);
            },
            icon: Icon(Icons.import_export),
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
                // Delete Block Button can only Appear when user is viewing a block
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
