import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/component/cachelisttile.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/page/cacheview.dart';
import 'package:idea_cache/page/emptypage.dart';
import 'package:idea_cache/page/managestatusview.dart';
import 'package:idea_cache/page/overview.dart';
import 'package:idea_cache/page/settingpage.dart';
import 'package:provider/provider.dart';

class ICSideNavBar extends StatefulWidget {
  final void Function(Widget) onPageChanged;
  const ICSideNavBar({
    Key? key,
    required void Function(Widget widget) onPageChanged,
  }) : onPageChanged = onPageChanged,
       super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ICSideNavBarState();
  }
}

class _ICSideNavBarState extends State<ICSideNavBar> {
  int _selectedIndex = 0;
  List<Cache> _userCaches = [];
  OverlayEntry? manageStatusOverlay;
  Future<void> _loadCaches() async {
    _userCaches = List.empty();
    final caches = await FileHandler.readCaches();
    setState(() {
      _userCaches = caches;
    });
  }

  void _toggleManageStatusView(BuildContext context) {
    if (manageStatusOverlay != null) {
      manageStatusOverlay?.remove();
      manageStatusOverlay?.dispose();
      manageStatusOverlay = null;
      return;
    }
    manageStatusOverlay = OverlayEntry(
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setOverlayState) {
            return GestureDetector(
              onTap: () {
                manageStatusOverlay?.remove();
                manageStatusOverlay?.dispose();
                manageStatusOverlay = null;
              },
              child: ICManageStatus(),
            );
          },
        );
      },
    );
    Overlay.of(context).insert(manageStatusOverlay!);
  }

  @override
  void initState() {
    super.initState();
    _loadCaches();
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ICAppState appState = context.watch<ICAppState>();
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
                    ? Icons.straighten
                    : Icons.straighten,
              ),
              title: Text('Manage Status'),
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
                _toggleManageStatusView(context);
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
