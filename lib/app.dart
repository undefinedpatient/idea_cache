import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/component/navigationbarbutton.dart';
import 'package:idea_cache/component/reminderbutton.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:idea_cache/model/remindermodel.dart';
import 'package:idea_cache/model/settingsmodel.dart';
import 'package:idea_cache/model/statusmodel.dart';
import 'package:idea_cache/notificationhandler.dart';
import 'package:idea_cache/page/cacheview.dart';
import 'package:idea_cache/page/reminderview.dart';
import 'package:idea_cache/page/overview.dart';
import 'dart:io';

import 'package:idea_cache/page/settingpage.dart';
import 'package:provider/provider.dart';

/* 
  Background color: Theme.of(context).colorScheme.surfaceContainerHigh,
  App Bar color: Theme.of(context).colorScheme.surfaceContainer
  Card color: -
  Selected Color: 
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
        ChangeNotifierProvider(create: (context) => ICStatusModel()),
        ChangeNotifierProvider(create: (context) => ICReminderModel()),
        ChangeNotifierProvider(create: (context) => ICNotificationHandler()),
      ],
      child: Consumer<ICSettingsModel>(
        builder: (context, model, child) {
          return MaterialApp(
            home: ICMainView(),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(model.setting.colorCode),
                brightness: Brightness.light,
                contrastLevel: 0.5,
              ),

              textTheme: Typography.blackCupertino.apply(
                fontFamily: model.setting.fontFamily,
                displayColor: Colors.black,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(model.setting.colorCode),
                brightness: Brightness.dark,
                contrastLevel: 0.5,
              ),
              textTheme: Typography.whiteCupertino.apply(
                fontFamily: model.setting.fontFamily,
                displayColor: Colors.white,
              ),
            ),
            themeMode: model.setting.themeMode,
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

class ICMainView extends StatefulWidget {
  const ICMainView({super.key});
  @override
  State<StatefulWidget> createState() {
    return _ICMainView();
  }
}

class _ICMainView extends State<ICMainView> {
  int _selectedIndex = 0;
  bool isReminderSheetOpened = false;
  bool collapse = false;
  late Timer timer;
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => {
        Provider.of<ICSettingsModel>(context, listen: false).loadFromFile(),
      },
    );
    Future.microtask(
      () => {Provider.of<ICCacheModel>(context, listen: false).loadFromFile()},
    );
    Future.microtask(
      () => {Provider.of<ICBlockModel>(context, listen: false).loadFromFile()},
    );
    Future.microtask(
      () => {Provider.of<ICStatusModel>(context, listen: false).loadFromFile()},
    );
    Future.microtask(
      () => {
        Provider.of<ICReminderModel>(context, listen: false).loadFromFile(),
      },
    );
    Future.microtask(
      () => {
        Provider.of<ICNotificationHandler>(context, listen: false).initLoop(),
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    Widget? pageWidget;

    ICSettingsModel appState = context.watch<ICSettingsModel>();
    ICCacheModel cacheModel = context.read<ICCacheModel>();

    if (_selectedIndex == 0) {
      pageWidget = ICOverview(
        onSetPage: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      );
    } else if (_selectedIndex > cacheModel.caches.length) {
      pageWidget = ICSettingPage();
    } else {
      pageWidget = ICCacheView(
        key: ValueKey(cacheModel.caches[_selectedIndex - 1].id),
        cacheid: cacheModel.caches[_selectedIndex - 1].id,
        onPageDeleted: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      );
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return Scaffold(
        floatingActionButton: ICReminderButton(
          onTap: () {
            isReminderSheetOpened = true;
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return ICReminderView();
              },
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                // NotificationHandler.sendSampleNotification();
              },
              icon: Icon(Icons.ac_unit),
            ),
          ],
          title: RichText(
            text: TextSpan(
              text: "IdeaCache ",
              style: Theme.of(context).textTheme.headlineMedium,
              children: <TextSpan>[
                TextSpan(
                  text: " v1.4.0",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: (collapse) ? 48 : 160,
              child: Consumer<ICCacheModel>(
                builder: (consumerContext, model, child) {
                  return (model.isLoading)
                      ? LinearProgressIndicator()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ICNavigationBarButton(
                              icon: (collapse)
                                  ? Icons.arrow_right
                                  : Icons.arrow_left,
                              title: "",
                              collapsed: collapse,
                              selected: _selectedIndex == -1,
                              onTap: () {
                                setState(() {
                                  collapse = !collapse;
                                });
                              },
                            ),
                            ICNavigationBarButton(
                              icon: (_selectedIndex == 0)
                                  ? Icons.dashboard
                                  : Icons.dashboard_outlined,

                              title: "Overview",
                              selected: _selectedIndex == 0,
                              collapsed: collapse,
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
                                  _selectedIndex = 0;
                                  pageWidget = ICOverview(
                                    onSetPage: (int index) {
                                      setState(() {
                                        _selectedIndex = index;
                                      });
                                    },
                                  );
                                });
                              },
                            ),
                            Expanded(
                              child: ReorderableListView(
                                shrinkWrap: true,
                                buildDefaultDragHandles: false,
                                onReorder: (int oldIndex, int newIndex) async {
                                  Cache fromCache = model.caches[oldIndex];
                                  Cache toCache =
                                      model.caches[(oldIndex < newIndex)
                                          ? newIndex - 1
                                          : newIndex];
                                  await model.reorderCachesByIds(
                                    fromCache.id,
                                    toCache.id,
                                  );
                                  if (_selectedIndex > 0 &&
                                      _selectedIndex <
                                          model.caches.length + 1) {
                                    setState(() {
                                      _selectedIndex = (oldIndex < newIndex)
                                          ? newIndex
                                          : newIndex + 1;
                                    });
                                  }
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
                                    child: ICNavigationBarButton(
                                      key: ValueKey(id),
                                      title: title,
                                      icon: (_selectedIndex == index + 1)
                                          ? Icons.pages
                                          : Icons.pages_outlined,
                                      cacheid: id,
                                      collapsed: collapse,
                                      onTap: () {
                                        if (appState.isContentEdited) {
                                          ScaffoldMessenger.of(
                                            consumerContext,
                                          ).showSnackBar(
                                            const SnackBar(
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
                                        model.loadFromFile();
                                      },
                                      selected: _selectedIndex == index + 1,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Consumer<ICBlockModel>(
                              builder: (context, blockModel, child) {
                                return ICNavigationBarButton(
                                  icon: Icons.add,
                                  title: 'Add Cache',
                                  collapsed: collapse,
                                  selected: false,
                                  onTap: () async {
                                    Cache cache = await model.createCache();
                                    blockModel.updateLocalBlockMapByCacheId(
                                      cache.id,
                                    );
                                  },
                                );
                              },
                            ),
                            ICNavigationBarButton(
                              icon: _selectedIndex == model.caches.length + 1
                                  ? Icons.settings
                                  : Icons.settings_outlined,

                              title: "Settings",
                              collapsed: collapse,
                              selected:
                                  _selectedIndex == model.caches.length + 1,
                              onTap: () {
                                if (appState.isContentEdited) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Warning: Content Not Saved",
                                      ),
                                      duration: Durations.extralong3,
                                    ),
                                  );
                                  // set the edited state such that user can ignore the warning
                                  appState.setContentEditedState(false);
                                  return;
                                }
                                setState(() {
                                  _selectedIndex = model.caches.length + 1;
                                  pageWidget = ICSettingPage();
                                });
                              },
                            ),
                          ],
                        );
                },
              ),
            ),
            const VerticalDivider(thickness: 2, width: 2),
            Expanded(child: pageWidget!),
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
        drawer: SafeArea(child: Drawer()),
        body: pageWidget,
      );
    }
  }
}
