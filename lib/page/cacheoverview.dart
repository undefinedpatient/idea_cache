import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/blockcard.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:idea_cache/userpreferences.dart';
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
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ICUserPreferences userPreferences = context.watch<ICUserPreferences>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text("Overview"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          IconButton(
            onPressed: () {
              userPreferences.toggleViewAxis();
            },
            icon: Icon(
              (userPreferences.viewAxis == Axis.vertical)
                  ? Icons.horizontal_distribute
                  : Icons.vertical_distribute,
            ),
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
            Divider(),
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
                    scrollDirection: userPreferences.viewAxis,
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
                            axis: (userPreferences.viewAxis == Axis.horizontal)
                                ? Axis.vertical
                                : Axis.horizontal,
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
