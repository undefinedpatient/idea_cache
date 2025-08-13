import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/component/cachelisttile.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/setting.dart';
import 'package:idea_cache/page/cacheview.dart';
import 'package:idea_cache/page/emptypage.dart';
import 'package:idea_cache/page/overview.dart';
import 'dart:io';

import 'package:idea_cache/page/settingpage.dart';
import 'package:provider/provider.dart';

/* 
  Background color: Theme.of(context).colorScheme.surfaceContainerHigh,
  App Bar color: Theme.of(context).colorScheme.surfaceContainer
  Card color: -
*/

class ICApp extends StatelessWidget {
  const ICApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ICSettingsModel()),
        ChangeNotifierProvider(create: (context) => ICCacheModel()),
        ChangeNotifierProvider(create: (context) => ICBlockModel()),
      ],
      child: Consumer<ICSettingsModel>(
        builder: (context, value, child) {
          return MaterialApp(
            home: ICMainView(),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(value.colorcode),
                brightness: Brightness.light,
                contrastLevel: 0.5,
              ),

              textTheme: Typography.blackCupertino.apply(
                fontFamily: value.font,
                displayColor: Colors.black,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(value.colorcode),
                brightness: Brightness.dark,
                contrastLevel: 0.5,
              ),
              textTheme: Typography.whiteCupertino.apply(
                fontFamily: value.font,
                displayColor: Colors.white,
              ),
            ),
            themeMode: value.thememode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}

class ICSettingsModel extends ChangeNotifier {
  // User Settings
  ThemeMode thememode = ThemeMode.light;
  String font = 'FiraCode Nerd Font';
  int colorcode = Colors.purple.toARGB32();
  bool toolTipsEnabled = true;
  // App States
  bool isContentEdited = false;

  ICSettingsModel() {
    FileHandler.loadSetting().then((Setting setting) {
      changeBrightness(setting.thememode);
      changeFontFamily(setting.fontfamily);
      changeColorCode(setting.colorcode);
      changeTooltipsEnabled(setting.toolTipsEnabled);
    });
  }
  void setContentEditedState(bool isEdited) {
    isContentEdited = isEdited;
  }

  void changeBrightness(ThemeMode thememode) {
    this.thememode = thememode;
    notifyListeners();
  }

  void changeFontFamily(String fontFamily) {
    font = fontFamily;
    notifyListeners();
  }

  void changeColorCode(int code) {
    colorcode = code;
    notifyListeners();
  }

  void changeTooltipsEnabled(bool enable) {
    toolTipsEnabled = enable;
    notifyListeners();
  }
}

class ICCacheModel extends ChangeNotifier {
  final List<Cache> _caches = [];
  UnmodifiableListView<Cache> get caches => UnmodifiableListView(_caches);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> loadFromFile() async {
    log("loadFromFile");
    _isLoading = true;
    notifyListeners();
    _caches.clear();
    FileHandler.readCaches().then((caches) {
      for (Cache item in caches) {
        _caches.add(item);
      }
    });
    _isLoading = false;
    notifyListeners();
  }

  void loadFromFileSync() async {
    log("loadFromFileSync");
    _isLoading = true;
    notifyListeners();
    _caches.clear();
    _caches.addAll(await FileHandler.readCaches());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reorderCache(int from, int to) async {
    log("Reordering");
    if (from < to) {
      to--;
    }
    FileHandler.reorderCaches(from, to);
    _caches.insert(to, _caches.removeAt(from));
    notifyListeners();
  }
}

class ICBlockModel extends ChangeNotifier {
  final List<ICBlock> _blocks = [];
  UnmodifiableListView<ICBlock> get blocks => UnmodifiableListView(_blocks);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> loadFromFile() async {
    _isLoading = true;
    notifyListeners();
    _blocks.clear();
    FileHandler.readBlocks().then((blockes) {
      for (ICBlock item in blockes) {
        _blocks.add(item);
      }
    });
    _isLoading = false;
    notifyListeners();
  }

  void loadFromFileSync() async {
    _isLoading = true;
    notifyListeners();
    _blocks.clear();
    _blocks.addAll(await FileHandler.readBlocks());
    _isLoading = false;
    notifyListeners();
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
  List<Cache> _userCaches = [];
  OverlayEntry? addCacheOverlayEntry;
  OverlayEntry? overlayEntryImport;

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
    // _loadCaches();
    Future.microtask(
      () => {
        Provider.of<ICCacheModel>(context, listen: false).loadFromFileSync(),
      },
    );
    Future.microtask(
      () => {
        Provider.of<ICBlockModel>(context, listen: false).loadFromFileSync(),
      },
    );
  }

  @override
  void dispose() {
    // overlayEntryExport?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    ICSettingsModel appState = context.watch<ICSettingsModel>();
    // log("build", name: runtimeType.toString());
    Widget pageWidget = ICEmptyPage();
    if (_selectedIndex == 0) {
      pageWidget = ICOverview(
        onSetPage: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      );
    } else if (_selectedIndex > 0 && _selectedIndex < _userCaches.length + 1) {
      pageWidget = ICCacheView(
        cacheid: _userCaches[_selectedIndex - 1].id,
        reloadCaches: _loadCaches,
      );
    } else {
      pageWidget = ICSettingPage();
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: AppBar(
          title: RichText(
            text: TextSpan(
              text: "IdeaCache ",
              style: Theme.of(context).textTheme.headlineMedium,
              children: <TextSpan>[
                TextSpan(
                  text: " v1.3.1",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Row(
          children: [
            SizedBox(
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
                    },
                  ),

                  Consumer<ICCacheModel>(
                    builder: (consumerContext, model, child) {
                      return (model.isLoading)
                          ? LinearProgressIndicator()
                          : Expanded(
                              child: ReorderableListView(
                                buildDefaultDragHandles: false,
                                onReorder: (int oldIndex, int newIndex) async {
                                  model.reorderCache(oldIndex, newIndex);
                                },

                                children: model.caches.asMap().entries.map((
                                  entry,
                                ) {
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
                                          ScaffoldMessenger.of(
                                            consumerContext,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Warning: Content Not Saved",
                                              ),
                                              duration: Durations.extralong3,
                                            ),
                                          );
                                          appState.setContentEditedState(false);
                                          return;
                                        }
                                        setState(() {
                                          _selectedIndex = index + 1;
                                        });
                                      },
                                      onEditName: () async {
                                        model.loadFromFileSync();
                                      },
                                      selected: _selectedIndex == index + 1,
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                    },
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
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: AppBar(
          title: RichText(
            text: TextSpan(
              text: "IdeaCache ",
              style: Theme.of(context).textTheme.headlineMedium,
              children: <TextSpan>[
                TextSpan(
                  text: " v1.3.0",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        drawer: SafeArea(
          child: Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceTint,
                  ),
                  child: Text(
                    "Cache Menu",
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
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
                  },
                ),
                Builder(
                  builder: (context) {
                    return Expanded(
                      child: ReorderableListView(
                        onReorder: (int oldIndex, int newIndex) async {
                          _userCaches.insert(
                            (oldIndex < newIndex) ? newIndex - 1 : newIndex,
                            _userCaches.removeAt(oldIndex),
                          );
                          setState(() {});
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
                                      content: Text(
                                        "Warning: Content Not Saved",
                                      ),
                                      duration: Durations.extralong3,
                                    ),
                                  );
                                  appState.setContentEditedState(false);
                                  return;
                                }
                                setState(() {
                                  _selectedIndex = index + 1;
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
                    );
                  },
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
                  },
                ),
              ],
            ),
          ),
        ),
        body: pageWidget,
      );
    }
  }
}
