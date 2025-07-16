import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/fileHandler.dart';

class ICOverview extends StatefulWidget {
  final Function(int) setPage;
  const ICOverview({super.key, required Function(int) setPage})
    : setPage = setPage;
  @override
  State<StatefulWidget> createState() {
    return _ICOverview();
  }
}

class _ICOverview extends State<ICOverview> {
  List<Cache> _userCaches = List.empty(growable: true);
  void _readCaches() async {
    List<Cache> readCaches = await FileHandler.readCaches();
    setState(() {
      _userCaches = readCaches;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Overview")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text("You have ${_userCaches.length} Caches!"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: (MediaQuery.of(context).size.width > 420)
                    ? (MediaQuery.of(context).size.width / 420).floor()
                    : 1,
                childAspectRatio: 4,
                shrinkWrap: true,
                children: _userCaches
                    .asMap()
                    .entries
                    .map(
                      (entry) => Card(
                        clipBehavior: Clip.hardEdge,
                        child: ListTile(
                          leading: Icon(Icons.pages_outlined),
                          title: Text(entry.value.name),
                          subtitle: Text(
                            "# of Blocks: ${entry.value.blockIds.length.toString()}",
                          ),
                          onTap: () {
                            widget.setPage(entry.key + 1);
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
