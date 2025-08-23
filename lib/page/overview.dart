import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/component/cachecard.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:provider/provider.dart';

class ICOverview extends StatefulWidget {
  final void Function(int) onSetPage;
  const ICOverview({super.key, required this.onSetPage});
  @override
  State<StatefulWidget> createState() {
    return _ICOverview();
  }
}

class _ICOverview extends State<ICOverview> {
  bool isScrollVertical = false;
  final TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  String searchString = "";
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
  }

  @override
  void didUpdateWidget(covariant ICOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ICCacheModel>(
      builder: (context, model, child) {
        if (model.isLoading) {
          return LinearProgressIndicator();
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          appBar: AppBar(
            title: Text("Overview"),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            actions: [
              DropdownButton(
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: SearchBar(
                    hintText: "Search Caches",
                    controller: _textEditingController,
                    shape: WidgetStateProperty<OutlinedBorder>.fromMap(
                      <WidgetStatesConstraint, OutlinedBorder>{
                        WidgetState.any: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      },
                    ),
                    leading: Icon(Icons.search),
                    backgroundColor: WidgetStateColor.fromMap(
                      <WidgetStatesConstraint, Color>{
                        WidgetState.hovered: Colors.transparent,
                        WidgetState.any: Colors.transparent,
                      },
                    ),

                    overlayColor: WidgetStateColor.fromMap(
                      <WidgetStatesConstraint, Color>{
                        WidgetState.hovered: Colors.transparent,
                        WidgetState.any: Colors.transparent,
                      },
                    ),
                    elevation: WidgetStateProperty<double>.fromMap(
                      <WidgetStatesConstraint, double>{
                        WidgetState.disabled: 0,
                        WidgetState.any: 0,
                      },
                    ),
                    trailing: [],
                    onChanged: (value) async {
                      setState(() {
                        // _textEditingController.text = value;
                      });
                    },
                  ),
                ),
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("You have ${model.caches.length} Caches!"),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Text("Pinned", textScaler: TextScaler.linear(1.5)),
                Expanded(
                  child: ReorderableListView(
                    proxyDecorator: proxyDecorator,
                    padding: EdgeInsets.all(0),
                    onReorder: (oldIndex, newIndex) async {
                      Cache fromCache = model.caches[oldIndex];
                      Cache toCache =
                          model.caches[(oldIndex < newIndex)
                              ? newIndex - 1
                              : newIndex];
                      await model.reorderCachesByIds(fromCache.id, toCache.id);
                    },
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    scrollDirection: (isScrollVertical == true)
                        ? Axis.vertical
                        : Axis.horizontal,
                    children: model.caches
                        // Only take whose not pinned
                        .where((Cache cache) => cache.group == "pinned")
                        .where(
                          (Cache cache) => cache.name.toLowerCase().contains(
                            _textEditingController.text.toLowerCase(),
                          ),
                        )
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                          return ICCacheCard(
                            scrollDirection: (isScrollVertical)
                                ? Axis.vertical
                                : Axis.horizontal,
                            key: ValueKey(entry.value.id),
                            index: entry.key,
                            cacheId: entry.value.id,
                            onSetPage: () {
                              widget.onSetPage(entry.key + 1);
                            },
                          );
                        })
                        .toList(),
                  ),
                ),
                Divider(),
                Expanded(
                  child: ReorderableListView(
                    proxyDecorator: proxyDecorator,
                    padding: EdgeInsets.all(0),
                    onReorder: (oldIndex, newIndex) async {
                      log("\n");

                      List<Cache> tempList = model.caches
                          .where((cache) => cache.group == "")
                          .toList();
                      Cache fromCache = tempList[oldIndex];
                      Cache toCache =
                          tempList[(oldIndex < newIndex)
                              ? newIndex - 1
                              : newIndex];
                      log("${fromCache.name}vs${toCache.name}");
                      log(
                        model.caches.map((cache) {
                          return "${cache.name}";
                        }).toString(),
                      );
                      log(
                        tempList.map((cache) {
                          return "${cache.name}";
                        }).toString(),
                      );
                      await model.reorderCachesByIds(fromCache.id, toCache.id);
                    },
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    scrollDirection: (isScrollVertical == true)
                        ? Axis.vertical
                        : Axis.horizontal,
                    children: model.caches
                        // Only take whose not pinned
                        .where((Cache cache) => cache.group == "")
                        .where(
                          (Cache cache) => cache.name.toLowerCase().contains(
                            _textEditingController.text.toLowerCase(),
                          ),
                        )
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                          return ICCacheCard(
                            scrollDirection: (isScrollVertical)
                                ? Axis.vertical
                                : Axis.horizontal,
                            key: ValueKey(entry.value.id),
                            index: entry.key,
                            cacheId: entry.value.id,
                            onSetPage: () {
                              widget.onSetPage(entry.key + 1);
                            },
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
