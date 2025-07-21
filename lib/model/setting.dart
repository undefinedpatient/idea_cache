import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Setting {
  ThemeMode thememode = ThemeMode.system;
  TextTheme texttheme = GoogleFonts.firaCodeTextTheme();
  Color colorseed = Colors.purple;
  Setting({ThemeMode? thememode, TextTheme? texttheme, Color? colorseed}) {
    this.thememode = (thememode != null) ? thememode : ThemeMode.system;
    this.texttheme = (texttheme != null)
        ? texttheme
        : GoogleFonts.firaCodeTextTheme();
    this.colorseed = (colorseed != null) ? colorseed : Colors.purple;
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
    int colorcode = jsonMap["colorseed"];
    colorseed = Color(colorcode);
  }
  Map<String, dynamic> toJson() {
    return {
      "thememode": thememode.toString(),
      "texttheme": texttheme.toStringShort(),
      "colorseed": colorseed.toARGB32(),
    };
  }
}
