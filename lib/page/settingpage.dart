import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/optioncard.dart';
import 'package:idea_cache/model/settingsmodel.dart';
import 'package:idea_cache/userpreferences.dart';
import 'package:provider/provider.dart';

class ICSettingPage extends StatefulWidget {
  const ICSettingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ICSettingPageState();
  }
}

class _ICSettingPageState extends State<ICSettingPage> {
  ICUserPreferences _pref = ICUserPreferences();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            Flex(
              mainAxisSize: MainAxisSize.min,
              direction: Axis.horizontal,
              children: [
                Flexible(flex: 1, fit: FlexFit.tight, child: Divider()),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 64),
                  child: Text("Theme", textAlign: TextAlign.center),
                ),
                Flexible(flex: 16, fit: FlexFit.tight, child: Divider()),
              ],
            ),
            ICOptionCard<ThemeMode>(
              title: "ThemeMode",
              description: "",
              initialValue: _pref.themeMode,
              options: _pref.themeModeMap,
              onChanged: (value) {
                _pref.setThemeMode(value);
              },
            ),
            ICOptionCard<String>(
              title: "FontFamily",
              description: "",
              initialValue: _pref.fontFamily,
              options: _pref.fontFamilyMap,
              onChanged: (value) {
                _pref.setFontFamily(value);
              },
            ),
            ICOptionCard<int>(
              title: "Tint",
              description: "",
              initialValue: _pref.tint,
              options: _pref.tintMap,
              onChanged: (value) {
                _pref.setTint(value);
              },
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(flex: 1, fit: FlexFit.tight, child: Divider()),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 64),
                  child: Text("Misc", textAlign: TextAlign.center),
                ),
                Flexible(flex: 16, fit: FlexFit.tight, child: Divider()),
              ],
            ),
            ICOptionCard<bool>(
              title: "ToolTips",
              description: "",
              initialValue: _pref.toolTips,
              options: {},
              onChanged: (value) {
                _pref.toggleToolTips();
              },
            ),

            ICOptionCard<bool>(
              title: "Pin Window",
              description: "",
              initialValue: _pref.windowPinValue,
              options: {},
              onChanged: (value) {
                _pref.toggleWindowPin();
              },
            ),
          ],
        ),
      ),
    );
  }
}
