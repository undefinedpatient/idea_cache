import 'package:flutter/material.dart';

class Setting {
  ThemeMode themeMode = ThemeMode.system;
  String fontFamily = 'FiraCode Nerd Font';
  bool toolTipsEnabled = true;
  int colorCode = const Color.fromRGBO(156, 39, 176, 1).toARGB32();
  Setting({
    ThemeMode? thememode,
    String? fontfamily,
    int? colorcode,
    bool? toolTipsEnabled,
  }) {
    this.themeMode = (thememode != null) ? thememode : ThemeMode.system;
    this.fontFamily = (fontfamily != null) ? fontfamily : 'FiraCode Nerd Font';
    this.colorCode = (colorcode != null) ? colorcode : Colors.purple.toARGB32();
    this.toolTipsEnabled = (toolTipsEnabled != null) ? toolTipsEnabled : true;
  }
  Setting.fromJson(Map<String, dynamic> jsonMap) {
    String thememodeString = jsonMap["thememode"];

    switch (thememodeString) {
      case 'ThemeMode.light':
        themeMode = ThemeMode.light;
      case 'ThemeMode.dark':
        themeMode = ThemeMode.dark;
      default:
        themeMode = ThemeMode.system;
    }
    fontFamily = jsonMap["fontfamily"];
    colorCode = int.parse(jsonMap["colorseed"]);
    toolTipsEnabled = jsonMap["toolTipsEnabled"];
  }
  Map<String, dynamic> toJson() {
    return {
      'thememode': themeMode.toString(),
      'fontfamily': fontFamily,
      'colorseed': colorCode.toString(),
      'toolTipsEnabled': toolTipsEnabled,
    };
  }
}
