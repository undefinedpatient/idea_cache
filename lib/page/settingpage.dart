import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ICSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ICSettingPageState();
  }
}

class _ICSettingPageState extends State<ICSettingPage> {
  ThemeMode _themeMode = ThemeMode.system;
  TextTheme _textTheme = GoogleFonts.firaCodeTextTheme();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<ICAppState>();
      setState(() {
        _themeMode = appState.themeMode;
        _textTheme = appState.textTheme;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ICAppState appState = context.watch<ICAppState>();
    log(name: runtimeType.toString(), "build(BuildContext context)");
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
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
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(
                            "Light",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(
                            "Dark",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
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
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Font",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
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
                          child: Text(
                            "Fira Code",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: GoogleFonts.notoSerifTextTheme(),
                          child: Text(
                            "Noto Serif",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
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
          ],
        ),
      ),
    );
  }
}
