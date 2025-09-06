import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class ICUserPreferences extends ChangeNotifier {
  // Mark this class as singleton
  ICUserPreferences._internal();
  static final ICUserPreferences _instance = ICUserPreferences._internal();
  factory ICUserPreferences() {
    return _instance;
  }

  // The only get/set of preferences throughout its lifetime
  final SharedPreferencesAsync _pref = SharedPreferencesAsync(
    options: const SharedPreferencesOptions(),
  );

  Future<void> loadPreferences() async {
    Map<String, Object?> preferences = await _pref.getAll();
    _windowPinValue = (preferences["windowPin"] ?? false) as bool;
    _themeMode =
        ThemeMode.values[((preferences[_themeModeString] ?? 0) as int)];
    _tint = (preferences[_tintString] ?? Colors.amber.toARGB32()) as int;
    _fontFamily = (preferences[_fontFamilyString] ?? "Abel") as String;
    _toolTips = (preferences[_toolTipsString] ?? true) as bool;
    _viewAxis = Axis.values[(preferences[_viewAxisString] ?? 0) as int];
  }

  /* 
  "windowPin" represent whether the window should be always on top or not,
  it is made for Window Platform
  Initial Value: false
  */
  bool _windowPinValue = false;
  bool get windowPinValue => _windowPinValue;

  void toggleWindowPin() {
    _windowPinValue = !_windowPinValue;
    _pref.setBool("windowPin", _windowPinValue);
    windowManager.setAlwaysOnTop(_windowPinValue);
    notifyListeners();
  }

  /*
  "themeMode" expressed in ThemeMode 
  means the light/dark mode of the application
  Initial Value: System
  */
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  final String _themeModeString = "themeMode";
  String get themeModeString => _themeModeString;
  final Map<String, ThemeMode> _themeModeMap = {
    "Follow System": ThemeMode.system,
    "Light": ThemeMode.light,
    "Dark": ThemeMode.dark,
  };
  UnmodifiableMapView<String, ThemeMode> get themeModeMap =>
      UnmodifiableMapView(_themeModeMap);
  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _pref.setInt(_themeModeString, _themeMode.index);
    notifyListeners();
  }

  /*
    "tint" expressed in ARGB32 int format
  */
  int _tint = Colors.amber.toARGB32();
  int get tint => _tint;
  final String _tintString = "tint";
  final Map<String, int> _tintMap = {
    "Amber": Colors.amber.toARGB32(),
    "Blue": Colors.blue.toARGB32(),
    "Green": Colors.green.toARGB32(),
    "Purple": Colors.purple.toARGB32(),
    "Red": Colors.red.toARGB32(),
  };
  UnmodifiableMapView<String, int> get tintMap => UnmodifiableMapView(_tintMap);
  void setTint(int tint) {
    if (!_tintMap.values.toList().contains(tint)) {
      throw Exception("Value $tint Not Found in _tintMap!");
    }
    _tint = tint;
    _pref.setInt(_tintString, _tint);
    notifyListeners();
  }

  /*
    "fontFamily" expressed in String
    !For font only use those from Open Font License (OFL)!
    */
  String _fontFamily = "Abel";
  String get fontFamily => _fontFamily;
  final String _fontFamilyString = "fontFamily";
  final Map<String, String> _fontFamilyMap = {
    "Abel": "Abel",
    "Annie": "Annie Use Your Telescope",
    "Coda": "Coda",
    "EB Garamond": "EB Garamond",
    "FiraCode": "FiraCode Nerd Font",
    "Noto Sans": "Noto Sans Thin",
    "Noto Serif": "Noto Serif Thin",
    "Roboto": "Roboto Thin",
  };
  UnmodifiableMapView<String, String> get fontFamilyMap =>
      UnmodifiableMapView(_fontFamilyMap);
  void setFontFamily(String fontFamily) {
    if (!_fontFamilyMap.values.toList().contains(fontFamily)) {
      throw Exception("Value $fontFamily Not Found in _fontFamilyMap!");
    }
    _fontFamily = fontFamily;
    _pref.setString(_fontFamilyString, _fontFamily);
    notifyListeners();
  }

  /*
    "toolTips" boolean
  */
  bool _toolTips = true;
  bool get toolTips => _toolTips;
  final String _toolTipsString = "toolTips";
  void toggleToolTips() {
    _toolTips = !_toolTips;
    _pref.setBool(_toolTipsString, _toolTips);
    notifyListeners();
  }

  /*

  */
  Axis _viewAxis = Axis.horizontal;
  Axis get viewAxis => _viewAxis;
  final String _viewAxisString = "viewAxis";
  void toggleViewAxis() {
    if (_viewAxis == Axis.horizontal) {
      _viewAxis = Axis.vertical;
    } else {
      _viewAxis = Axis.horizontal;
    }
    _pref.setInt(_viewAxisString, _viewAxis.index);
    notifyListeners();
  }
}
