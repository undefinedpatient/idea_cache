import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/cachelisttile.dart';
import 'package:idea_cache/component/createcacheform.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/cacheview.dart';
import 'package:idea_cache/page/overview.dart';
import 'dart:io';

class ICApp extends StatelessWidget {
  const ICApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ICMainView(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.light,
        ),
      ),
      // darkTheme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.greenAccent,
      //     brightness: Brightness.dark,
      //   ),
      // ),
    );
  }
}

class ICMainView extends StatefulWidget {
  const ICMainView({super.key});
  @override
  State<StatefulWidget> createState() {
    return _ICMainView();
  }
}

class _ICMainView extends State<ICMainView> {
  int _selectedIndex = 0;
  String _currentCacheId = "";
  List<Cache> _userCaches = [];
  OverlayEntry? addCacheOverlayEntry;
  void _addCreateCacheOverlay() {
    // Ensure current we do not have any entry
    assert(addCacheOverlayEntry == null);
    // Create a new entry and assign it to our class property
    addCacheOverlayEntry = OverlayEntry(
      builder: (BuildContext buildContext) {
        double width = MediaQuery.of(buildContext).size.width;
        double height = MediaQuery.of(buildContext).size.height;
        return GestureDetector(
          onTap: _removeAddCacheOverlay,
          child: Material(
            color: Colors.black38,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.white,
                margin: (width > 1280 && height > 600)
                    ? EdgeInsets.fromLTRB(360, 128, 360, 128)
                    : EdgeInsets.fromLTRB(0, 128, 0, 128),

                child: ICCreateCacheForm(onExitForm: _removeAddCacheOverlay),
              ),
            ),
          ),
        );
      },
    );
    //Add the entry to our overlayEntry
    Overlay.of(context).insert(addCacheOverlayEntry!);
  }

  void _removeAddCacheOverlay() {
    addCacheOverlayEntry?.remove();
    addCacheOverlayEntry?.dispose();
    addCacheOverlayEntry = null;
  }

  Future<void> _loadCaches() async {
    final caches = await FileHandler.readCaches();
    setState(() {
      _userCaches = caches;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCaches();
  }
  @override
  Widget build(BuildContext buildContext) {
    Widget pageWidget = Placeholder();
    if (_selectedIndex == 0) {
      pageWidget = ICOverview();
    } else if (_selectedIndex > 0 && _selectedIndex < _userCaches.length + 1) {
      pageWidget = ICCacheView(cache: _userCaches[_selectedIndex-1]);
    } else {
      pageWidget = Placeholder();
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return Scaffold(
        appBar: AppBar(title: Text("IdeaCache")),
        body: Row(
          children: [
            SizedBox(
              width: 180,
              // color:,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListTile(
                    leading: Icon(
                      (_selectedIndex == 0)
                          ? Icons.dashboard
                          : Icons.dashboard_outlined,
                    ),
                    title: Text("Overview"),
                    selected: _selectedIndex == 0,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  Expanded(
                    child: ReorderableListView(
                      buildDefaultDragHandles: false,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final Cache item = _userCaches.removeAt(oldIndex);
                          _userCaches.insert(newIndex, item);
                        });
                      },

                      children: _userCaches.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final String title = entry.value.name;
                        final String id = entry.value.id;
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(id),
                          index: index,
                          child: ICCacheListTile(
                            title: title,
                            cacheid: id,
                            onTap: () {
                              setState(() {
                                _selectedIndex = index + 1;
                                _currentCacheId =
                                    _userCaches[_selectedIndex - 1].id;
                              });
                            },
                            selected: _selectedIndex == index + 1,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add Cache'),
                    selected: false,
                    onTap: () async {
                      Cache newCache = Cache(name: "Untitled");
                      await FileHandler.appendCache(newCache);
                      await _loadCaches();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      _selectedIndex == _userCaches.length + 1
                          ? Icons.settings
                          : Icons.settings_outlined,
                    ),
                    title: Text('Settings'),
                    selected: _selectedIndex == _userCaches.length + 1,
                    onTap: () {
                      setState(() {
                        _selectedIndex = _userCaches.length + 1;
                      });
                    },
                  ),
                ],
              ),
            ),
            const VerticalDivider(thickness: 2, width: 2),
            Expanded(child: pageWidget),
          ],
        ),
      );
    } else {
      return Placeholder();
    }
  }
}
