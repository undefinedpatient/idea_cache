import 'package:flutter/material.dart';

class Setting {
  ThemeMode thememode = ThemeMode.system;
  String fontfamily = 'FiraCode Nerd Font';
  int colorcode = const Color.fromRGBO(156, 39, 176, 1).toARGB32();
  Setting({ThemeMode? thememode, String? fontfamily, int? colorcode}) {
    this.thememode = (thememode != null) ? thememode : ThemeMode.system;
    this.fontfamily = (fontfamily != null) ? fontfamily : 'FiraCode Nerd Font';
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
    fontfamily = jsonMap["fontfamily"];
    colorcode = int.parse(jsonMap["colorseed"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "thememode": thememode.toString(),
      "fontfamily": fontfamily,
      "colorseed": colorcode.toString(),
    };
  }
}
