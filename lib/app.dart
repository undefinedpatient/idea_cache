import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/component/sidenavigationbar.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/setting.dart';
import 'package:idea_cache/page/emptypage.dart';
import 'package:idea_cache/page/overview.dart';
import 'dart:io';
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
  Widget pageWidget = ICEmptyPage();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // overlayEntryExport?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    // Widget pageWidget = ICOverview(onSetPage: (int index) {
    //                   setState(() {
    //                     _selectedIndex = index;
    //                   });
    //                   widget.onPageChanged(
    //                     ICCacheView(
    //                       cacheid: _userCaches[_selectedIndex - 1].id,
    //                       reloadCaches: _loadCaches,
    //                     ),
    //                   );
    //                 };
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
                  text: " v1.3.0",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Row(
          children: [
            ICSideNavBar(
              onPageChanged: (Widget widget) {
                setState(() {
                  pageWidget = widget;
                });
              },
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
                  text: " v1.2.1-beta",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),

          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        drawer: Drawer(
          child: ICSideNavBar(
            onPageChanged: (Widget widget) {
              setState(() {
                pageWidget = widget;
              });
            },
          ),
        ),
        body: Expanded(child: pageWidget),
      );
    }
  }
}
