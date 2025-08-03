import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/setting.dart';
import 'package:provider/provider.dart';

class ICSettingPage extends StatefulWidget {
  const ICSettingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ICSettingPageState();
  }
}

class _ICSettingPageState extends State<ICSettingPage> {
  ThemeMode _themeMode = ThemeMode.system;
  String _font = 'FiraCode Nerd Font';
  int _colorSeed = Colors.purple.toARGB32();
  Future<void> onSave() async {
    await FileHandler.saveSetting(
      Setting(thememode: _themeMode, fontfamily: _font, colorcode: _colorSeed),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<ICAppState>();
      setState(() {
        _themeMode = appState.thememode;
        _font = appState.font;
        _colorSeed = appState.colorcode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ICAppState appState = context.watch<ICAppState>();
    log(name: runtimeType.toString(), "build(BuildContext context)");
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [],
        actionsPadding: EdgeInsets.fromLTRB(0, 0, 16, 0),
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
                    Text(
                      "Theme",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
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
                          child: Text(
                            "Follow System",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(
                            "Light",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(
                            "Dark",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _themeMode = value!;
                        });
                        appState.changeBrightness((_themeMode));
                        onSave();
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
                    Text(
                      "Font",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    DropdownButton(
                      padding: EdgeInsets.all(4),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      value: _font,
                      items: [
                        DropdownMenuItem(
                          value: "Abel",
                          child: Text(
                            "Abel",
                            style: TextStyle(
                              fontFamily: "Abel",
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Annie Use Your Telescope",
                          child: Text(
                            "Annie",
                            style: TextStyle(
                              fontFamily: "Annie Use Your Telescope",
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Coda",
                          child: Text(
                            "Coda",
                            style: TextStyle(
                              fontFamily: "Coda",
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "EB Garamond",
                          child: Text(
                            "EB Garamond",
                            style: TextStyle(
                              fontFamily: "EB Garamond",
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'FiraCode Nerd Font',
                          child: Text(
                            "Fira Code",
                            style: TextStyle(
                              fontFamily: 'FiraCode Nerd Font',
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),

                        DropdownMenuItem(
                          value: "Noto Sans Thin",
                          child: Text(
                            "Noto Sans",
                            style: TextStyle(
                              fontFamily: "Noto Sans Thin",
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Noto Serif Thin",
                          child: Text(
                            "Noto Serif",
                            style: TextStyle(
                              fontFamily: "Noto Serif Thin",
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Roboto Thin",
                          child: Text(
                            "Roboto",
                            style: TextStyle(
                              fontFamily: "Roboto Thin",
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _font = value!;
                        });
                        appState.changeFontFamily((_font));
                        onSave();
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
                    Text(
                      "Tint",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),

                    DropdownButton(
                      padding: EdgeInsets.all(4),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      value: _colorSeed,
                      items: [
                        DropdownMenuItem(
                          value: Colors.purple.toARGB32(),
                          child: Text(
                            "Purple",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: Colors.blue.toARGB32(),
                          child: Text(
                            "Blue",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: Colors.red.toARGB32(),
                          child: Text(
                            "Red",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: Colors.amber.toARGB32(),
                          child: Text(
                            "Amber",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: Colors.green.toARGB32(),
                          child: Text(
                            "Green",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _colorSeed = value!;
                        });
                        appState.changeColorCode((_colorSeed));
                        onSave();
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
