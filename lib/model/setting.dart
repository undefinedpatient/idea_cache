import 'package:flutter/material.dart';

class Setting {
  ThemeMode thememode = ThemeMode.system;
  String font = 'FiraCode Nerd Font';
  int colorcode = Colors.purple.toARGB32();
  Setting({ThemeMode? thememode, String? font, int? colorcode}) {
    this.thememode = (thememode != null) ? thememode : ThemeMode.system;
    this.font = (font != null) ? font : 'FiraCode Nerd Font';
    this.colorcode = (colorcode != null) ? colorcode : Colors.purple.toARGB32();
  }
  Setting.fromJson(Map<String, dynamic> jsonMap) {
    String thememodeString = jsonMap["thememode"];
    switch (thememodeString) {
      case "ThemeMode.light":
        thememode = ThemeMode.light;
      case "ThemeMode.dark":
        thememode = ThemeMode.dark;
      default:
        thememode = ThemeMode.system;
    }
    font = jsonMap["texttheme"];
    colorcode = int.parse(jsonMap["colorseed"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "thememode": thememode.toString(),
      "font": font,
      "colorseed": colorcode.toString(),
    };
  }
}
