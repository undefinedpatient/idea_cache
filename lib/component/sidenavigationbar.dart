import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/component/cachelisttile.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/cacheview.dart';
import 'package:idea_cache/page/overview.dart';
import 'package:idea_cache/page/settingpage.dart';
import 'package:provider/provider.dart';

class ICSideNavBar extends StatefulWidget {
  final void Function(Widget) onPageChanged;
  const ICSideNavBar({
    super.key,
    required void Function(Widget widget) onPageChanged,
  }) : onPageChanged = onPageChanged;
  @override
  State<StatefulWidget> createState() {
    return _ICSideNavBarState();
  }
}

class _ICSideNavBarState extends State<ICSideNavBar> {
  int _selectedIndex = 0;
  List<Cache> _userCaches = [];
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
    // Load ICOverview as default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPageChanged(
        ICOverview(
          onSetPage: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            widget.onPageChanged(
              ICCacheView(
                cacheid: _userCaches[_selectedIndex - 1].id,
                reloadCaches: _loadCaches,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void didUpdateWidget(covariant ICSideNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ICSettingsModel appState = context.watch<ICSettingsModel>();
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return SizedBox(
        width: 180,
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
                if (appState.isContentEdited) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Warning: Content Not Saved"),
                      duration: Durations.extralong3,
                    ),
                  );
                  appState.setContentEditedState(false);
                  return;
                }
                setState(() {
                  _selectedIndex = 0;
                });
                widget.onPageChanged(
                  ICOverview(
                    onSetPage: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                      widget.onPageChanged(
                        ICCacheView(
                          cacheid: _userCaches[_selectedIndex - 1].id,
                          reloadCaches: _loadCaches,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Expanded(
              child: ReorderableListView(
                buildDefaultDragHandles: false,
                onReorder: (int oldIndex, int newIndex) async {
                  await FileHandler.reorderCaches(oldIndex, newIndex);
                  await _loadCaches();
                  setState(() {
                    _selectedIndex = newIndex;
                  });
                  widget.onPageChanged(
                    ICCacheView(
                      cacheid: _userCaches[_selectedIndex - 1].id,
                      reloadCaches: () async {
                        await _loadCaches();
                      },
                    ),
                  );
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
                        if (appState.isContentEdited) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Warning: Content Not Saved"),
                              duration: Durations.extralong3,
                            ),
                          );
                          appState.setContentEditedState(false);

                          return;
                        }
                        setState(() {
                          _selectedIndex = index + 1;
                        });
                        widget.onPageChanged(
                          ICCacheView(
                            cacheid: _userCaches[_selectedIndex - 1].id,
                            reloadCaches: _loadCaches,
                          ),
                        );
                      },
                      onEditName: () async {
                        await _loadCaches();
                        widget.onPageChanged(
                          ICCacheView(
                            cacheid: _userCaches[entry.key].id,
                            reloadCaches: _loadCaches,
                          ),
                        );
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
                _selectedIndex == _userCaches.length + 2
                    ? Icons.settings
                    : Icons.settings_outlined,
              ),
              title: Text('Settings'),
              selected: _selectedIndex == _userCaches.length + 2,
              onTap: () {
                if (appState.isContentEdited) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Warning: Content Not Saved"),
                      duration: Durations.extralong3,
                    ),
                  );
                  // set the edited state such that user can ignore the warning
                  appState.setContentEditedState(false);
                  return;
                }
                setState(() {
                  _selectedIndex = _userCaches.length + 2;
                });
                widget.onPageChanged(ICSettingPage());
              },
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        child: Column(
          children: [
            const DrawerHeader(child: Text("CacheList")),
            ListTile(
              leading: Icon(
                (_selectedIndex == 0)
                    ? Icons.dashboard
                    : Icons.dashboard_outlined,
              ),
              title: Text("Overview"),
              selected: _selectedIndex == 0,
              onTap: () {
                if (appState.isContentEdited) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Warning: Content Not Saved"),
                      duration: Durations.extralong3,
                    ),
                  );
                  appState.setContentEditedState(false);
                  return;
                }
                setState(() {
                  _selectedIndex = 0;
                });
                widget.onPageChanged(
                  ICOverview(
                    onSetPage: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                      widget.onPageChanged(
                        ICCacheView(
                          cacheid: _userCaches[_selectedIndex - 1].id,
                          reloadCaches: _loadCaches,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Expanded(
              child: ReorderableListView(
                buildDefaultDragHandles: false,
                onReorder: (int oldIndex, int newIndex) async {
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
                        if (appState.isContentEdited) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Warning: Content Not Saved"),
                              duration: Durations.extralong3,
                            ),
                          );
                          appState.setContentEditedState(false);
                          return;
                        }
                        setState(() {
                          _selectedIndex = index + 1;
                        });
                        widget.onPageChanged(
                          ICCacheView(
                            cacheid: _userCaches[_selectedIndex - 1].id,
                            reloadCaches: _loadCaches,
                          ),
                        );
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
                if (appState.isContentEdited) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Warning: Content Not Saved"),
                      duration: Durations.extralong3,
                    ),
                  );
                  // set the edited state such that user can ignore the warning
                  appState.setContentEditedState(false);
                  return;
                }
                setState(() {
                  _selectedIndex = _userCaches.length + 1;
                });
                widget.onPageChanged(ICSettingPage());
              },
            ),
          ],
        ),
      );
    }
  }
}
