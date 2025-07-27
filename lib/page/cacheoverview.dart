import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/filehandler.dart';

class ICCacheOverview extends StatefulWidget {
  final String cacheid;
  final Function(int) setPage;
  const ICCacheOverview({
    super.key,
    required String cacheid,
    required Function(int) setPage,
  }) : cacheid = cacheid,
       setPage = setPage;
  @override
  State<StatefulWidget> createState() {
    return _ICCacheOverviewState();
  }
}

class _ICCacheOverviewState extends State<ICCacheOverview> {
  TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  List<ICBlock> _cacheBlocks = List.empty(growable: true);
  Future<void> _loadBlocks() async {
    List<ICBlock> temp = await FileHandler.findBlocksByCacheId(widget.cacheid);
    setState(() {
      _cacheBlocks = temp;
    });
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
              child: GridView.count(
                crossAxisCount: (MediaQuery.of(context).size.width > 420)
                    ? (MediaQuery.of(context).size.width / 360).floor()
                    : 1.floor(),
                childAspectRatio: 3,
                children: _cacheBlocks
                    .asMap()
                    .entries
                    .map(
                      (entry) => Card(
                        elevation: 2,
                        clipBehavior: Clip.hardEdge,
                        child: ListTile(
                          leading: Icon(Icons.square_outlined),
                          title: Text(entry.value.name),
                          onTap: () {
                            widget.setPage(entry.key);
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
