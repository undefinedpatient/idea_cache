import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/component/cachelisttile.dart';
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
    return ChangeNotifierProvider(
      create: (context) => ICAppState(),
      child: Consumer<ICAppState>(
        builder: (context, value, child) {
          return MaterialApp(
            home: ICMainView(),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(value.colorcode),
                brightness: Brightness.light,
                contrastLevel: 1,
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
                contrastLevel: 1,
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

class ICAppState extends ChangeNotifier {
  ThemeMode thememode = ThemeMode.light;
  String font = 'FiraCode Nerd Font';
  int colorcode = Colors.purple.toARGB32();

  // Used to ensure user explicity save the content before switch views
  bool isContentEdited = false;
  ICAppState() {
    FileHandler.loadSetting().then((Setting setting) {
      changeBrightness(setting.thememode);
      changeFontFamily(setting.fontfamily);
      changeColorCode(setting.colorcode);
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
    _loadCaches();
  }

  @override
  void dispose() {
    // overlayEntryExport?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    ICAppState appState = context.watch<ICAppState>();
    // log("build", name: runtimeType.toString());
    Widget pageWidget = ICEmptyPage();
    if (_selectedIndex == 0) {
      pageWidget = ICOverview(
        setPage: (int index) {
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
                  text: " v1.2.0",
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
