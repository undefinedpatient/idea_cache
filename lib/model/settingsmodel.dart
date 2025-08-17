import 'package:flutter/material.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/setting.dart';

class ICSettingsModel extends ChangeNotifier {
  Setting setting = Setting();
  bool isLoading = false;
  // App States
  bool isContentEdited = false;

  Future<void> loadFromFile() async {
    isLoading = true;
    notifyListeners();
    await FileHandler.loadSetting().then((Setting setting) {
      this.setting.themeMode = setting.themeMode;
      this.setting.fontFamily = setting.fontFamily;
      this.setting.colorCode = setting.colorCode;
      this.setting.toolTipsEnabled = setting.toolTipsEnabled;
    });
    isLoading = false;
    notifyListeners();
  }

  void setContentEditedState(bool isEdited) {
    isContentEdited = isEdited;
    // notifyListeners();
  }

  void changeBrightness(ThemeMode thememode) {
    setting.themeMode = thememode;
    saveSetting(setting);
  }

  void changeFontFamily(String fontFamily) {
    setting.fontFamily = fontFamily;
    saveSetting(setting);
  }

  void changeColorCode(int code) {
    setting.colorCode = code;
    saveSetting(setting);
  }

  void changeTooltipsEnabled(bool enable) {
    setting.toolTipsEnabled = enable;
    saveSetting(setting);
  }

  Future<void> saveSetting(Setting setting) async {
    await FileHandler.saveSetting(setting);
    notifyListeners();
  }
}
