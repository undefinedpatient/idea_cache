import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/blockcard.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:provider/provider.dart';

class ICCacheOverview extends StatefulWidget {
  final String cacheid;
  final Function(int, ICBlock) setPage;
  const ICCacheOverview({
    super.key,
    required this.cacheid,
    required this.setPage,
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
  // List<ICBlock> _localBlocks = List.empty(growable: true);

  // Future<void> _filterBlocks() async {
  //   List<ICBlock> filteredBlocks = List<ICBlock>.of(_localBlocks);
  //   for (int i = 0; i < filteredBlocks.length; i++) {
  //     if (filteredBlocks[i].name.toLowerCase().contains(
  //       _textEditingController.text.toLowerCase(),
  //     )) {
  //       continue;
  //     } else {
  //       filteredBlocks.removeAt(i);
  //       i--;
  //     }
  //   }
  //   setState(() {
  //     _localBlocks = filteredBlocks;
  //   });
  // }

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
    // Future.microtask(() {
    //   setState(() {
    //     _localBlocks =
    //         Provider.of<ICBlockModel>(
    //           context,
    //           listen: false,
    //         ).cacheBlocksMap[widget.cacheid] ??
    //         [];
    //   });
    // });
  }

  @override
  void didUpdateWidget(covariant ICCacheOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // _filterBlocks();
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
                  setState(() {});
                  // _textEditingController.text = value;
                },
              ),
            ),
            Consumer<ICBlockModel>(
              builder: (context, model, child) {
                List<ICBlock> localBlocks =
                    model.cacheBlocksMap[widget.cacheid] ?? [];
                return Expanded(
                  child: ReorderableListView(
                    proxyDecorator: proxyDecorator,
                    padding: EdgeInsets.all(0),
                    onReorder: (oldIndex, newIndex) async {
                      await model.reorderBlockByCacheId(
                        widget.cacheid,
                        oldIndex,
                        newIndex,
                      );
                    },
                    buildDefaultDragHandles: false,
                    scrollDirection: (isScrollVertical == true)
                        ? Axis.vertical
                        : Axis.horizontal,
                    children: localBlocks
                        .asMap()
                        .entries
                        .where(
                          (entry) => entry.value.name.toLowerCase().contains(
                            _textEditingController.text.toLowerCase(),
                          ),
                        )
                        .map((entry) {
                          return ICBlockCard(
                            key: ObjectKey(entry.value),
                            index: entry.key,
                            block: entry.value,
                            onTap: () {
                              widget.setPage(entry.key, entry.value);
                            },
                            direction: (isScrollVertical == true)
                                ? Axis.horizontal
                                : Axis.vertical,
                          );
                        })
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
