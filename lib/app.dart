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
import 'package:idea_cache/model/status.dart';
import 'package:idea_cache/page/cacheview.dart';
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
        ChangeNotifierProvider(create: (context) => ICStatusModel()),
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

class ICSettingsModel extends ChangeNotifier {
  Setting setting = Setting();
  bool isLoading = false;
  // App States
  bool isContentEdited = false;

  ICSettingsModel() {
    FileHandler.loadSetting().then((Setting setting) {
      changeBrightness(setting.themeMode);
      changeFontFamily(setting.fontFamily);
      changeColorCode(setting.colorCode);
      changeTooltipsEnabled(setting.toolTipsEnabled);
    });
  }
  Future<void> loadFromFile() async {
    isLoading = true;
    notifyListeners();
    await FileHandler.loadSetting().then((Setting setting) {
      this.setting.themeMode = setting.themeMode;
      this.setting.fontFamily = setting.fontFamily;
      this.setting.colorCode = setting.colorCode;
      this.setting.toolTipsEnabled = setting.toolTipsEnabled;
    });
    isLoading = false;
    notifyListeners();
  }

  void setContentEditedState(bool isEdited) {
    isContentEdited = isEdited;
    notifyListeners();
  }

  void changeBrightness(ThemeMode thememode) {
    setting.themeMode = thememode;
    saveSetting(setting);
  }

  void changeFontFamily(String fontFamily) {
    setting.fontFamily = fontFamily;
    saveSetting(setting);
  }

  void changeColorCode(int code) {
    setting.colorCode = code;
    saveSetting(setting);
  }

  void changeTooltipsEnabled(bool enable) {
    setting.toolTipsEnabled = enable;
    saveSetting(setting);
  }

  Future<void> saveSetting(Setting setting) async {
    await FileHandler.saveSetting(setting);
    notifyListeners();
  }
}

class ICCacheModel extends ChangeNotifier {
  final List<Cache> _caches = [];
  UnmodifiableListView<Cache> get caches => UnmodifiableListView(_caches);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> loadFromFile() async {
    _isLoading = true;
    notifyListeners();
    _caches.clear();
    await FileHandler.readCaches().then((caches) {
      for (Cache item in caches) {
        _caches.add(item);
      }
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reorderCache(int from, int to) async {
    if (from < to) {
      to--;
    }
    FileHandler.reorderCaches(from, to);
    _caches.insert(to, _caches.removeAt(from));
    notifyListeners();
  }

  Future<Cache> createCache() async {
    Cache cache = Cache(name: "Untitled");
    await FileHandler.appendCache(cache);
    _caches.add(cache);
    notifyListeners();
    return cache;
  }

  Future<void> updateCache(Cache cache) async {
    await FileHandler.updateCache(cache);
    int targetReplaceIndex = _caches.indexWhere((item) => item.id == cache.id);
    _caches[targetReplaceIndex] = cache;
    notifyListeners();
  }

  Future<void> deleteCacheById(String id) async {
    await FileHandler.deleteCacheById(id);
    _caches.removeWhere((caches) => caches.id == id);
    notifyListeners();
  }
}

class ICBlockModel extends ChangeNotifier {
  // final List<ICBlock> _blocks = [];

  final Map<String, List<ICBlock>> _cacheBlocksMap = {};
  // UnmodifiableListView<ICBlock> get blocks => UnmodifiableListView(_blocks);
  UnmodifiableMapView<String, List<ICBlock>> get cacheBlocksMap =>
      UnmodifiableMapView(_cacheBlocksMap);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> loadFromFile() async {
    _isLoading = true;
    notifyListeners();

    // _blocks.clear();
    _cacheBlocksMap.clear();
    // _blocks.addAll(await FileHandler.readBlocks());
    log("Update Completed");
    List<Cache> caches = await FileHandler.readCaches();
    for (int i = 0; i < caches.length; i++) {
      _cacheBlocksMap.addAll({
        caches[i].id: await FileHandler.findBlocksByCacheId(caches[i].id),
      });
    }
    log("Update Completed1");
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateLocalBlockMapByCacheId(String cacheId) async {
    _cacheBlocksMap[cacheId] = await FileHandler.findBlocksByCacheId(cacheId);
    notifyListeners();
  }

  Future<void> createBlock(String cacheId) async {
    ICBlock block = ICBlock(cacheId: cacheId, name: "Untitled");
    Cache? parentCache = await FileHandler.findCacheById(cacheId);
    if (parentCache == null) {
      throw Exception("createBlock: parentCache cannot be found");
    }

    parentCache.addBlockId(block.id);
    await FileHandler.appendBlock(block);
    await FileHandler.updateCache(parentCache);
    await updateLocalBlockMapByCacheId(cacheId);
    notifyListeners();
  }

  Future<void> reorderBlockByCacheId(String cacheId, int from, int to) async {
    if (from < to) {
      to--;
    }
    // Update the local Storge First since it cost less time
    cacheBlocksMap[cacheId]!.insert(
      to,
      cacheBlocksMap[cacheId]!.removeAt(from),
    );
    notifyListeners();

    // Then save it to the storage
    Cache? parentCache = await FileHandler.findCacheById(cacheId);
    if (parentCache == null) {
      throw Exception("reorderBlockByCacheId: parentCache not found!");
    }

    parentCache.swapBlockId(from, to);
    await FileHandler.updateCache(parentCache);

    notifyListeners();
  }

  Future<void> updateBlock(ICBlock block) async {
    await FileHandler.updateBlock(block);
    await updateLocalBlockMapByCacheId(block.cacheId);
    notifyListeners();
  }

  Future<void> deleteBlockById(ICBlock block) async {
    await FileHandler.deleteBlocksById(block.id);
    Cache? parentCache = await FileHandler.findCacheById(block.cacheId);
    if (parentCache == null) {
      throw Exception("reorderBlockByCacheId: parentCache not found!");
    }
    parentCache.removeBlockId(block.id);
    await FileHandler.updateCache(parentCache);
    await updateLocalBlockMapByCacheId(block.cacheId);
    notifyListeners();
  }
}

class ICStatusModel extends ChangeNotifier {
  final List<ICStatus> _statuses = [];
  UnmodifiableListView<ICStatus> get statuses =>
      UnmodifiableListView(_statuses);
  Future<void> loadFromFile() async {
    _statuses.clear();
    _statuses.addAll(await FileHandler.readStatus());
    notifyListeners();
  }

  Future<void> createStatus() async {
    ICStatus status = ICStatus(statusName: "UnnamedStatus");
    FileHandler.appendStatus(status);
    _statuses.add(status);
    notifyListeners();
  }

  Future<void> reorderStatus(int from, int to) async {
    if (from < to) {
      to--;
    }
    _statuses.insert(to, _statuses.removeAt(from));
    notifyListeners();
    await FileHandler.reorderStatuses(from, to);
    notifyListeners();
  }

  Future<void> updateStatus(ICStatus status) async {
    int targetReplaceIndex = statuses.indexWhere(
      (item) => item.id == status.id,
    );
    _statuses[targetReplaceIndex] = status;
    await FileHandler.updateStatus(status);
    notifyListeners();
  }

  Future<void> deleteStatusById(String statusId) async {
    _statuses.removeWhere((status) => status.id == statusId);
    FileHandler.deleteStatusById(statusId);
    notifyListeners();
  }

  ICStatus? findStatusByBlock(ICBlock block) {
    if (block.statusId == "") {
      return null;
    }
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i].id == block.statusId &&
          (statuses[i].cacheId == block.cacheId ||
              statuses[i].cacheId.isEmpty)) {
        return statuses[i];
      }
    }
    return null;
  }

  List<ICStatus> findAvailableByCacheId(String cacheId) {
    List<ICStatus>? availableStatuses = List.empty(growable: true);
    // Filtering
    for (int i = 0; i < _statuses.length; i++) {
      if (_statuses[i].cacheId == cacheId || _statuses[i].cacheId == "") {
        availableStatuses.add(_statuses[i]);
      }
    }
    return availableStatuses;
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
  }

  @override
  void dispose() {
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
        cacheid: cacheModel._caches[_selectedIndex - 1].id,
        onPageDeleted: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      );
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
              child: Consumer<ICCacheModel>(
                builder: (consumerContext, model, child) {
                  return (model.isLoading)
                      ? LinearProgressIndicator()
                      : Column(
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
                                  await model.reorderCache(oldIndex, newIndex);
                                  setState(() {
                                    _selectedIndex = (oldIndex < newIndex)
                                        ? newIndex
                                        : newIndex + 1;
                                  });
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
                                return ListTile(
                                  leading: Icon(Icons.add),
                                  title: Text('Add Cache'),
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
                            ListTile(
                              leading: Icon(
                                _selectedIndex == model.caches.length + 1
                                    ? Icons.settings
                                    : Icons.settings_outlined,
                              ),
                              title: Text('Settings'),
                              selected:
                                  _selectedIndex == model.caches.length + 1,
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
