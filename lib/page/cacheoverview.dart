import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/blockcard.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';

class ICCacheOverview extends StatefulWidget {
  final String cacheid;
  final Function(int) setPage;
  final Future<void> Function() onEdit;
  const ICCacheOverview({
    super.key,
    required this.cacheid,
    required this.setPage,
    required this.onEdit,
  });
  @override
  State<StatefulWidget> createState() {
    return _ICCacheOverviewState();
  }
}

class _ICCacheOverviewState extends State<ICCacheOverview> {
  bool isScrollVertical = true;
  final TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  List<ICBlock> _cacheBlocks = List.empty(growable: true);
  Future<void> _loadBlocksUnconditional() async {
    List<ICBlock> temp = await FileHandler.findBlocksByCacheId(widget.cacheid);
    setState(() {
      _cacheBlocks = temp;
    });
  }

  Future<void> _loadBlocks() async {
    List<ICBlock> temp = await FileHandler.findBlocksByCacheId(widget.cacheid);
    if (temp.length != _cacheBlocks.length) {
      setState(() {
        _cacheBlocks = temp;
      });
      return;
    }
    for (int i = 0; i < temp.length; i++) {
      if (_cacheBlocks[i] != temp[i]) {
        setState(() {
          _cacheBlocks = temp;
        });
        return;
      }
    }
  }

  Future<void> _reorderBlock(int from, int to) async {
    Cache? userCache = await FileHandler.findCacheById(widget.cacheid);
    if (userCache == null) {
      return;
    }
    userCache.reorderBlockId(from, to);
    FileHandler.updateCache(userCache);
  }

  Future<void> _filterBlocks() async {
    List<ICBlock> filteredBlocks = List<ICBlock>.of(_cacheBlocks);
    for (int i = 0; i < filteredBlocks.length; i++) {
      if (filteredBlocks[i].name.toLowerCase().contains(
        _textEditingController.text.toLowerCase(),
      )) {
        continue;
      } else {
        filteredBlocks.removeAt(i);
        i--;
      }
    }
    setState(() {
      _cacheBlocks = filteredBlocks;
    });
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.black.withAlpha(0),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  @override
  void didUpdateWidget(covariant ICCacheOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadBlocks();
    _filterBlocks();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text("Overview"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          VerticalDivider(),
          DropdownButton(
            autofocus: false,
            padding: EdgeInsets.all(4),
            value: isScrollVertical,
            items: [
              DropdownMenuItem(value: false, child: Text("Horizontal")),
              DropdownMenuItem(value: true, child: Text("Vertical")),
            ],
            onChanged: (value) {
              setState(() {
                if (value == null) {
                  isScrollVertical = false;
                } else {
                  isScrollVertical = value;
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 4,
          children: [
            Card(
              child: SearchBar(
                hintText: "Search Blocks",
                controller: _textEditingController,
                shape: WidgetStateProperty<OutlinedBorder>.fromMap(
                  <WidgetStatesConstraint, OutlinedBorder>{
                    WidgetState.any: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  },
                ),
                leading: Icon(Icons.search),
                backgroundColor:
                    WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
                      WidgetState.hovered: Colors.transparent,
                      WidgetState.any: Colors.transparent,
                    }),

                overlayColor:
                    WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
                      WidgetState.hovered: Colors.transparent,
                      WidgetState.any: Colors.transparent,
                    }),
                elevation: WidgetStateProperty<double>.fromMap(
                  <WidgetStatesConstraint, double>{
                    WidgetState.disabled: 0,
                    WidgetState.any: 0,
                  },
                ),
                trailing: [],
                onChanged: (value) async {
                  await _loadBlocks();
                  await _filterBlocks();
                },
              ),
            ),
            Card(
              elevation: 2,
              child: ListTile(
                title: Text("You have ${_cacheBlocks.length} blocks!"),
              ),
            ),
            Expanded(
              child: ReorderableListView(
                proxyDecorator: proxyDecorator,
                padding: EdgeInsets.all(0),
                onReorder: (oldIndex, newIndex) async {
                  if (oldIndex < newIndex) {
                    newIndex--;
                  }
                  //Local refresh the page
                  _cacheBlocks.insert(
                    newIndex,
                    _cacheBlocks.removeAt(oldIndex),
                  );
                  setState(() {});
                  await _reorderBlock(oldIndex, newIndex);
                },
                buildDefaultDragHandles: false,
                scrollDirection: (isScrollVertical == true)
                    ? Axis.vertical
                    : Axis.horizontal,
                children: _cacheBlocks.asMap().entries.map((entry) {
                  return ICBlockCard(
                    key: ObjectKey(entry.value),
                    index: entry.key,
                    block: entry.value,
                    onTap: () {
                      widget.setPage(entry.key);
                    },
                    updateCallBack: () async {
                      await _loadBlocksUnconditional();
                      await _filterBlocks();
                      await widget.onEdit();
                    },
                    direction: (isScrollVertical == true)
                        ? Axis.horizontal
                        : Axis.vertical,
                  );
                }).toList(),
              ),
              // child: GridView.count(
              //   crossAxisCount: (isScrollVertical == true)
              //       ? (width / 360).floor()
              //       : (height / 240).floor(),
              //   scrollDirection: (isScrollVertical == true)
              //       ? Axis.vertical
              //       : Axis.horizontal,

              //   childAspectRatio: (isScrollVertical == true) ? 3 : 1 / 2,
              //   children: _cacheBlocks.asMap().entries.map((entry) {
              //     return ICBlockCard(
              //       key: ObjectKey(entry.value),
              //       block: entry.value,
              //       onTap: () {
              //         widget.setPage(entry.key);
              //       },
              //       direction: (isScrollVertical == true)
              //           ? Axis.horizontal
              //           : Axis.vertical,
              //       onBlockUpdated: () async {
              //         await _loadBlocksUnconditional();
              //         await _filterBlocks();
              //       },
              //     );
              //   }).toList(),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
