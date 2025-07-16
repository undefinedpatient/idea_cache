import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  List<ICBlock> _cacheBlocks = List.empty(growable: true);
  Future<void> _loadBlocks() async {
    List<ICBlock> temp = await FileHandler.findBlocksByCacheId(widget.cacheid);
    setState(() {
      _cacheBlocks = temp;
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Overview"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.view_array))],
        ),
        body: Column(
          children: [
            Card(
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
                        clipBehavior: Clip.hardEdge,
                        child: ListTile(
                          leading: Icon(Icons.square_outlined),
                          title: Text(entry.value.name),
                          trailing: IconButton(
                            onPressed: () {
                              widget.setPage(entry.key);
                            },
                            icon: Icon(Icons.arrow_right),
                          ),
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
