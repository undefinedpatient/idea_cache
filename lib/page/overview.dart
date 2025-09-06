import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/cachecard.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:idea_cache/userpreferences.dart';
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
    ICUserPreferences pref = context.watch<ICUserPreferences>();
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
              IconButton(
                onPressed: () {
                  pref.toggleViewAxis();
                },
                icon: Icon(
                  (pref.viewAxis == Axis.vertical)
                      ? Icons.horizontal_distribute
                      : Icons.vertical_distribute,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
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
                SizedBox(
                  height: (pref.viewAxis == Axis.vertical) ? null : 180,
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
                    scrollDirection: pref.viewAxis,
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
                            scrollDirection: pref.viewAxis,
                            key: ValueKey(entry.value.id),
                            index: entry.key,
                            cacheId: entry.value.id,
                            onSetPage: () {
                              int indexOfCache = model.caches.indexWhere(
                                (cache) => cache.id == entry.value.id,
                              );
                              widget.onSetPage(indexOfCache);
                            },
                          );
                        })
                        .toList(),
                  ),
                ),
                Divider(),
                SizedBox(
                  height: (pref.viewAxis == Axis.vertical) ? null : 180,
                  child: ReorderableListView(
                    proxyDecorator: proxyDecorator,
                    padding: EdgeInsets.all(0),
                    onReorder: (oldIndex, newIndex) async {
                      List<Cache> tempList = model.caches
                          .where((cache) => cache.group == "")
                          .toList();
                      Cache fromCache = tempList[oldIndex];
                      Cache toCache =
                          tempList[(oldIndex < newIndex)
                              ? newIndex - 1
                              : newIndex];
                      await model.reorderCachesByIds(fromCache.id, toCache.id);
                    },
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    scrollDirection: pref.viewAxis,
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
                            scrollDirection: pref.viewAxis,
                            key: ValueKey(entry.value.id),
                            index: entry.key,
                            cacheId: entry.value.id,
                            onSetPage: () {
                              int indexOfCache = model.caches.indexWhere(
                                (cache) => cache.id == entry.value.id,
                              );
                              widget.onSetPage(indexOfCache);
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
