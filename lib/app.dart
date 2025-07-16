import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/component/cachelisttile.dart';
import 'package:idea_cache/component/createcacheform.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/cacheview.dart';
import 'package:idea_cache/page/emptypage.dart';
import 'package:idea_cache/page/overview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class ICApp extends StatelessWidget {
  const ICApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ICMainView(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purpleAccent,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.firaCodeTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.firaCodeTextTheme(),
      ),
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
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

  Future<void> _loadCaches() async {
    _userCaches = List.empty();
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
    log("build", name: runtimeType.toString());
    Widget pageWidget = ICEmptyPage();
    if (_selectedIndex == 0) {
      pageWidget = ICOverview();
    } else if (_selectedIndex > 0 && _selectedIndex < _userCaches.length + 1) {
      pageWidget = ICCacheView(
        cacheid: _userCaches[_selectedIndex - 1].id,
        reloadCaches: _loadCaches,
      );
    } else {
      pageWidget = ICEmptyPage();
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        appBar: AppBar(
          title: Text("IdeaCache"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
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
                      onReorder: (int oldIndex, int newIndex) async {
                        log("$oldIndex $newIndex");
                        await FileHandler.reorderCaches(oldIndex, newIndex);
                        await _loadCaches();
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
                            onEditName: () async {
                              await _loadCaches();
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
      return ICEmptyPage();
    }
  }
}
