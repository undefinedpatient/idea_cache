import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
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
import 'package:idea_cache/userpreferences.dart';
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
        ChangeNotifierProvider(create: (context) => ICAppState()),
        ChangeNotifierProvider(create: (context) => ICCacheModel()),
        ChangeNotifierProvider(create: (context) => ICBlockModel()),
        ChangeNotifierProvider(create: (context) => ICStatusModel()),
        ChangeNotifierProvider(create: (context) => ICReminderModel()),
        ChangeNotifierProvider(create: (context) => ICNotificationHandler()),
        ChangeNotifierProvider(create: (context) => ICUserPreferences()),
      ],
      child: Consumer<ICUserPreferences>(
        builder: (context, pref, child) {
          return MaterialApp(
            home: ICMainView(),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(ICUserPreferences().tint),
                brightness: Brightness.light,
                contrastLevel: 0.5,
              ),

              textTheme: Typography.blackCupertino.apply(
                fontFamily: ICUserPreferences().fontFamily,
                displayColor: Colors.black,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(ICUserPreferences().tint),
                brightness: Brightness.dark,
                contrastLevel: 0.5,
              ),
              textTheme: Typography.whiteCupertino.apply(
                fontFamily: ICUserPreferences().fontFamily,
                displayColor: Colors.white,
              ),
            ),
            themeMode: ICUserPreferences().themeMode,
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
  int _initialBlockPageIndex = -1;
  int _selectedIndex = -1;
  bool collapse = false;
  Widget? pageWidget;
  String _getWeekdayString(int index) {
    List<String> weekdayStrings = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return weekdayStrings[index - 1];
  }

  @override
  void initState() {
    super.initState();
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
        Provider.of<ICNotificationHandler>(
          context,
          listen: false,
        ).initInAppCheckLoop(),
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    ICCacheModel cacheModel = context.read<ICCacheModel>();

    if (_selectedIndex == -1) {
      pageWidget = ICOverview(
        onSetPage: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      );
    } else if (_selectedIndex > cacheModel.caches.length - 1) {
      pageWidget = ICSettingPage();
    } else {
      pageWidget = ICCacheView(
        initialIndex: _initialBlockPageIndex,
        key: ValueKey(cacheModel.caches[_selectedIndex].id),
        cacheid: cacheModel.caches[_selectedIndex].id,
        onPageDeleted: () {
          setState(() {
            _selectedIndex = -1;
          });
        },
      );
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return _windowApp();
    } else {
      return _androidApp();
    }
  }

  Widget _windowApp() {
    ICAppState appState = context.watch<ICAppState>();
    ICCacheModel cacheModel = context.read<ICCacheModel>();
    ICBlockModel blockModel = context.read<ICBlockModel>();
    return Scaffold(
      floatingActionButton: ICReminderButton(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return ICReminderView(
                onTapBlock: (String cacheId, String blockId) {
                  log(cacheId + blockId);
                  setState(() {
                    _selectedIndex = cacheModel.caches.indexWhere(
                      (cache) => cache.id == cacheId,
                    );
                    _initialBlockPageIndex = blockModel.cacheBlocksMap[cacheId]!
                        .indexWhere((block) => block.id == blockId);
                  });
                  Navigator.pop(context);
                },
                onTapCache: (String cacheId) {
                  log(cacheId);
                  setState(() {
                    _selectedIndex = cacheModel.caches.indexWhere(
                      (cache) => cache.id == cacheId,
                    );
                    _initialBlockPageIndex = -1;
                  });
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        toolbarHeight: 32,
        title: Text(
          "IdeaCache v1.5.1",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceTint,
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
                            selected: _selectedIndex == -2,
                            enableEdit: false,
                            onTap: () {
                              setState(() {
                                collapse = !collapse;
                              });
                            },
                          ),
                          ICNavigationBarButton(
                            icon: (_selectedIndex == -1)
                                ? Icons.dashboard
                                : Icons.dashboard_outlined,

                            title: "Overview",
                            selected: _selectedIndex == -1,
                            collapsed: collapse,
                            enableEdit: false,
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
                                _selectedIndex = -1;
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
                                if (_selectedIndex > -1 &&
                                    _selectedIndex < model.caches.length) {
                                  setState(() {
                                    _selectedIndex = (oldIndex < newIndex)
                                        ? newIndex - 1
                                        : newIndex;
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
                                    icon: (_selectedIndex == index)
                                        ? Icons.pages
                                        : Icons.pages_outlined,
                                    cache: entry.value,
                                    collapsed: collapse,
                                    enableEdit: true,
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
                                        _initialBlockPageIndex = -1;
                                        _selectedIndex = index;
                                      });
                                    },
                                    selected: _selectedIndex == index,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Consumer<ICBlockModel>(
                            builder: (context, blockModel, child) {
                              return ICNavigationBarButton(
                                enableEdit: false,
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
                            enableEdit: false,
                            icon: _selectedIndex == model.caches.length
                                ? Icons.settings
                                : Icons.settings_outlined,

                            title: "Settings",
                            collapsed: collapse,
                            selected: _selectedIndex == model.caches.length,
                            onTap: () {
                              if (appState.isContentEdited) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Warning: Content Not Saved"),
                                    duration: Durations.extralong3,
                                  ),
                                );
                                // set the edited state such that user can ignore the warning
                                appState.setContentEditedState(false);
                                return;
                              }
                              setState(() {
                                _selectedIndex = model.caches.length;
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
  }

  Widget _androidApp() {
    ICAppState appState = context.watch<ICAppState>();
    ICCacheModel cacheModel = context.read<ICCacheModel>();
    ICBlockModel blockModel = context.read<ICBlockModel>();
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ICReminderButton(
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              constraints: BoxConstraints(
                // minHeight: MediaQuery.heightOf(context) * 0.8,
                maxHeight: MediaQuery.heightOf(context) * 0.8,
              ),
              builder: (context) {
                return ICReminderView(
                  onTapBlock: (String cacheId, String blockId) {
                    setState(() {
                      _selectedIndex = cacheModel.caches.indexWhere(
                        (cache) => cache.id == cacheId,
                      );
                      _initialBlockPageIndex = blockModel
                          .cacheBlocksMap[cacheId]!
                          .indexWhere((block) => block.id == blockId);
                    });
                    Navigator.pop(context);
                  },
                  onTapCache: (String cacheId) {
                    log(cacheId);
                    setState(() {
                      _selectedIndex = cacheModel.caches.indexWhere(
                        (cache) => cache.id == cacheId,
                      );
                      _initialBlockPageIndex = -1;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
        drawerEdgeDragWidth: 96,
        drawer: Drawer(
          child: Consumer<ICCacheModel>(
            builder: (consumerContext, model, child) {
              return (model.isLoading)
                  ? LinearProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DrawerHeader(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("IdeaCache v1.5.1"),
                              Text(
                                _getWeekdayString(DateTime.now().weekday),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondaryFixedDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ICNavigationBarButton(
                          icon: (_selectedIndex == -1)
                              ? Icons.dashboard
                              : Icons.dashboard_outlined,

                          title: "Overview",
                          selected: _selectedIndex == -1,
                          collapsed: false,
                          enableEdit: false,
                          height: 64,
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
                              _selectedIndex = -1;
                              pageWidget = ICOverview(
                                onSetPage: (int index) {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                },
                              );
                            });
                            Navigator.pop(context);
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
                              if (_selectedIndex > -1 &&
                                  _selectedIndex < model.caches.length) {
                                setState(() {
                                  _selectedIndex = (oldIndex < newIndex)
                                      ? newIndex - 1
                                      : newIndex;
                                });
                              }
                            },

                            children: model.caches.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final String title = entry.value.name;
                              final String id = entry.value.id;
                              return ReorderableDelayedDragStartListener(
                                key: ValueKey(id),
                                index: index,
                                child: ICNavigationBarButton(
                                  key: ValueKey(id),
                                  title: title,
                                  icon: (_selectedIndex == index)
                                      ? Icons.pages
                                      : Icons.pages_outlined,
                                  cache: entry.value,
                                  collapsed: false,
                                  enableEdit: true,
                                  height: 64,
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
                                      _initialBlockPageIndex = -1;
                                      _selectedIndex = index;
                                    });
                                    Navigator.pop(context);
                                  },
                                  selected: _selectedIndex == index,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Consumer<ICBlockModel>(
                          builder: (context, blockModel, child) {
                            return ICNavigationBarButton(
                              enableEdit: false,
                              icon: Icons.add,
                              title: 'Add Cache',
                              collapsed: false,
                              selected: false,
                              height: 64,
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
                          enableEdit: false,
                          icon: _selectedIndex == model.caches.length
                              ? Icons.settings
                              : Icons.settings_outlined,

                          title: "Settings",
                          collapsed: false,
                          selected: _selectedIndex == model.caches.length,
                          height: 64,
                          onTap: () {
                            if (appState.isContentEdited) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Warning: Content Not Saved"),
                                  duration: Durations.extralong3,
                                ),
                              );
                              // set the edited state such that user can ignore the warning
                              appState.setContentEditedState(false);

                              return;
                            }
                            setState(() {
                              _selectedIndex = model.caches.length;
                              pageWidget = ICSettingPage();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
            },
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: AppBar(
          toolbarHeight: 42,
          title: Text(
            "IdeaCache v1.5.1",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surfaceTint,
        ),
        body: pageWidget!,
      ),
    );
  }
}
