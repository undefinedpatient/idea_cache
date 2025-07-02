import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:idea_cache/cache.dart';
import './overview.dart';
import 'cacheview.dart';

class ICApp extends StatelessWidget {
  const ICApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ICMainView(),
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.light,
        ),
      ),
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
  final List<Cache> _userCaches = [];
  @override
  Widget build(BuildContext buildContext) {
    double width = MediaQuery.of(buildContext).size.width;
    double height = MediaQuery.of(buildContext).size.height;
    Widget currentPageWidget = Placeholder();

    if (_selectedIndex == 0) {
      currentPageWidget = Text("Overview");
    } else if (_selectedIndex > 0 && _selectedIndex < _userCaches.length) {
      currentPageWidget = Placeholder();
    } else {
      currentPageWidget = Text("Setting");
    }
    if (width > height) {
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
                      children: _userCaches.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final String title = entry.value.name;
                        final int id = entry.value.id;
                        return ListTile(
                          key: ValueKey(id), // Required for ReorderableListView
                          leading: Icon(
                            _selectedIndex == index + 1
                                ? Icons.pages
                                : Icons.pages_outlined,
                          ),
                          title: Text(title),
                          trailing: const Icon(Icons.drag_handle),
                          selected: _selectedIndex == index + 1,
                          onTap: () {
                            setState(() {
                              _selectedIndex = index + 1;
                            });
                          },
                        );
                      }).toList(),

                      onReorder: (int v, int a) {},
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add Cache'),
                    selected: false,
                    onTap: () {},
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
            VerticalDivider(thickness: 2, width: 2),
            Expanded(child: currentPageWidget),
          ],
        ),
      );
    } else {
      return Placeholder();
    }
  }
}
