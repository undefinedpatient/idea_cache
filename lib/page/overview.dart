import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/fileHandler.dart';

class ICOverview extends StatefulWidget {
  const ICOverview({super.key});
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
                crossAxisCount: 2,
                shrinkWrap: true,
                children: [
                  Card(child: Text("data")),
                  Card(child: Text("data")),
                  Card(child: Text("data")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
