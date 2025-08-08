import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/fileHandler.dart';

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
  List<Cache> _userCaches = List.empty(growable: true);
  final TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  String searchString = "";
  Future<void> _readCaches() async {
    List<Cache> readCaches = await FileHandler.readCaches();
    setState(() {
      _userCaches = readCaches;
    });
  }

  Future<void> _filterCaches() async {
    List<Cache> filteredCaches = List<Cache>.of(_userCaches);
    for (int i = 0; i < filteredCaches.length; i++) {
      if (filteredCaches[i].name.toLowerCase().contains(
        _textEditingController.text.toLowerCase(),
      )) {
        continue;
      } else {
        filteredCaches.removeAt(i);
        i--;
      }
    }
    setState(() {
      _userCaches = filteredCaches;
    });
  }

  @override
  void initState() {
    super.initState();
    _readCaches();
  }

  @override
  void didUpdateWidget(covariant ICOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _readCaches();
    _filterCaches();
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
                  // setState(() {
                  //   _textEditingController.text = value;
                  // });
                  await _readCaches();
                  await _filterCaches();
                },
              ),
            ),
            Card(
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    title: Text("You have ${_userCaches.length} Caches!"),
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
                      crossAxisCount: (MediaQuery.of(context).size.width > 420)
                          ? (MediaQuery.of(context).size.width / 420).floor()
                          : 1,
                      childAspectRatio: 4,
                      shrinkWrap: true,
                      children: _userCaches
                          .where((Cache cache) => cache.priority == 1)
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
                children: _userCaches
                    // Only take whose not pinned
                    .where((Cache cache) => cache.priority == 0)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (entry) => Card(
                        elevation: 2,
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
            ),
          ],
        ),
      ),
    );
  }
}
