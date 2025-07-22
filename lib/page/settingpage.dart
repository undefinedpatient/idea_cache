import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/setting.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ICSettingPage extends StatefulWidget {
  const ICSettingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ICSettingPageState();
  }
}

class _ICSettingPageState extends State<ICSettingPage> {
  ThemeMode _themeMode = ThemeMode.system;
  TextTheme _textTheme = GoogleFonts.firaCodeTextTheme();
  int _colorseed = Colors.purple.toARGB32();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<ICAppState>();
      setState(() {
        _themeMode = appState.themeMode;
        _textTheme = appState.textTheme;
        _colorseed = appState.colorcode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ICAppState appState = context.watch<ICAppState>();
    log(name: runtimeType.toString(), "build(BuildContext context)");
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        title: Text("Settings"),
        // backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          IconButton(
            onPressed: () async {
              await FileHandler.saveSetting(
                Setting(
                  thememode: _themeMode,
                  texttheme: _textTheme,
                  colorcode: _colorseed,
                ),
              );
              final SnackBar snackBar = SnackBar(
                content: Text("Settings Saved!"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            icon: Icon(Icons.save),
          ),
        ],
        actionsPadding: EdgeInsets.fromLTRB(0, 0, 0, 16),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Theme"),
                    DropdownButton(
                      padding: EdgeInsets.all(4),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      value: _themeMode,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text("Follow System"),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text("Light"),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text("Dark"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _themeMode = value!;
                        });
                        appState.changeBrightness((_themeMode));
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Font"),
                    DropdownButton(
                      padding: EdgeInsets.all(4),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      value: _textTheme,
                      items: [
                        DropdownMenuItem(
                          value: GoogleFonts.firaCodeTextTheme(),
                          child: Text("Fira Code"),
                        ),
                        DropdownMenuItem(
                          value: GoogleFonts.notoSerifTextTheme(),
                          child: Text("Noto Serif"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _textTheme = value!;
                        });
                        appState.changeTextTheme((_textTheme));
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Main Color"),

                    DropdownButton(
                      padding: EdgeInsets.all(4),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      value: _colorseed,
                      items: [
                        DropdownMenuItem(
                          value: Colors.purple.toARGB32(),
                          child: Text("Purple"),
                        ),
                        DropdownMenuItem(
                          value: Colors.amber.toARGB32(),
                          child: Text("Amber"),
                        ),
                        DropdownMenuItem(
                          value: Colors.green.toARGB32(),
                          child: Text("Green"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _colorseed = value!;
                        });
                        appState.changeColorCode((_colorseed));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
