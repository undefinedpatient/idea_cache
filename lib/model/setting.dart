import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Setting {
  ThemeMode thememode = ThemeMode.system;
  TextTheme texttheme = GoogleFonts.firaCodeTextTheme();
  Setting({ThemeMode? thememode, TextTheme? texttheme}) {
    this.thememode = (thememode != null) ? thememode : ThemeMode.system;
    this.texttheme = (texttheme != null)
        ? texttheme
        : GoogleFonts.firaCodeTextTheme();
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
    String textthemeString = jsonMap["texttheme"];
    switch (textthemeString) {
      // TextTheme#256c8 == Fira Code
      case "TextTheme#256c8":
        texttheme = GoogleFonts.firaCodeTextTheme();
      // TextTheme#256c8 == Noto Serif
      case "TextTheme#bb442":
        texttheme = GoogleFonts.notoSerifTextTheme();
      default:
        texttheme = GoogleFonts.firaCodeTextTheme();
    }
  }
  Map<String, dynamic> toJson() {
    return {
      "thememode": thememode.toString(),
      "texttheme": texttheme.toStringShort(),
    };
  }
}
