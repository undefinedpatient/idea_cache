import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/component/cachecard.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/fileHandler.dart';
import 'package:provider/provider.dart';

class ICOverview extends StatefulWidget {
  final void Function(int) onSetPage;
  const ICOverview({super.key, required void Function(int) onSetPage})
    : onSetPage = onSetPage;
  @override
  State<StatefulWidget> createState() {
    return _ICOverview();
  }
}

class _ICOverview extends State<ICOverview> {
  bool isScrollVertical = true;
  final TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  String searchString = "";

  @override
  void initState() {
    super.initState();
    // Future.microtask(() {
    //   Provider.of<ICCacheModel>(context, listen: false).loadFromFileSync();
    // });
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                        _textEditingController.text = value;
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
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.push_pin),
                          title: Text("Pins"),
                        ),
                        GridView.count(
                          crossAxisCount:
                              (MediaQuery.of(context).size.width > 420)
                              ? (MediaQuery.of(context).size.width / 420)
                                    .floor()
                              : 1,
                          childAspectRatio: 4,
                          shrinkWrap: true,
                          children: model.caches
                              .where((Cache cache) => cache.priority == 1)
                              .where(
                                (Cache cache) =>
                                    cache.name.toLowerCase().contains(
                                      _textEditingController.text.toLowerCase(),
                                    ),
                              )
                              .toList()
                              .asMap()
                              .entries
                              .map(
                                (entry) => Card(
                                  elevation: 4,
                                  clipBehavior: Clip.hardEdge,
                                  child: ListTile(
                                    leading: Icon(Icons.pages_outlined),
                                    title: Text(entry.value.name),
                                    subtitle: Text(
                                      "# of Blocks: ${entry.value.blockIds.length.toString()}",
                                    ),
                                    onTap: () {
                                      widget.onSetPage(entry.key + 1);
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: (isScrollVertical == true)
                        ? (width / 360).floor()
                        : (height / 240).floor(),
                    scrollDirection: (isScrollVertical == true)
                        ? Axis.vertical
                        : Axis.horizontal,

                    childAspectRatio: (isScrollVertical == true) ? 3 : 1 / 2,
                    shrinkWrap: true,
                    children: model.caches
                        // Only take whose not pinned
                        .where((Cache cache) => cache.priority == 0)
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
                            name: entry.value.name,
                            numOfBlocks: entry.value.blockIds.length,
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
