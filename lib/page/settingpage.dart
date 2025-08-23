import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/model/setting.dart';
import 'package:idea_cache/model/settingsmodel.dart';
import 'package:provider/provider.dart';

class ICSettingPage extends StatefulWidget {
  const ICSettingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ICSettingPageState();
  }
}

class _ICSettingPageState extends State<ICSettingPage> {
  Setting _localSetting = Setting();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _localSetting = Provider.of<ICSettingsModel>(
        context,
        listen: false,
      ).setting;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ICSettingsModel>(
      builder: (context, model, child) {
        return (model.isLoading)
            ? LinearProgressIndicator()
            : Scaffold(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHigh,
                appBar: AppBar(
                  title: Text("Settings"),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                              DropdownButton(
                                padding: EdgeInsets.all(4),
                                underline: Container(
                                  height: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                value: model.setting.themeMode,
                                items: [
                                  DropdownMenuItem(
                                    value: ThemeMode.system,
                                    child: Text(
                                      "Follow System",
                                      style: TextStyle(
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
                                      style: TextStyle(
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
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _localSetting.themeMode = value!;
                                  });
                                  model.changeBrightness(
                                    (_localSetting.themeMode),
                                  );
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                              DropdownButton(
                                padding: EdgeInsets.all(4),
                                underline: Container(
                                  height: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                value: model.setting.fontFamily,
                                items: [
                                  DropdownMenuItem(
                                    value: "Abel",
                                    child: Text(
                                      "Abel",
                                      style: TextStyle(
                                        fontFamily: "Abel",
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "Annie Use Your Telescope",
                                    child: Text(
                                      "Annie",
                                      style: TextStyle(
                                        fontFamily: "Annie Use Your Telescope",
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "Coda",
                                    child: Text(
                                      "Coda",
                                      style: TextStyle(
                                        fontFamily: "Coda",
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "EB Garamond",
                                    child: Text(
                                      "EB Garamond",
                                      style: TextStyle(
                                        fontFamily: "EB Garamond",
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'FiraCode Nerd Font',
                                    child: Text(
                                      "Fira Code",
                                      style: TextStyle(
                                        fontFamily: 'FiraCode Nerd Font',
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "Noto Sans Thin",
                                    child: Text(
                                      "Noto Sans",
                                      style: TextStyle(
                                        fontFamily: "Noto Sans Thin",
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "Noto Serif Thin",
                                    child: Text(
                                      "Noto Serif",
                                      style: TextStyle(
                                        fontFamily: "Noto Serif Thin",
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "Roboto Thin",
                                    child: Text(
                                      "Roboto",
                                      style: TextStyle(
                                        fontFamily: "Roboto Thin",
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _localSetting.fontFamily = value!;
                                  });
                                  model.changeFontFamily(
                                    (_localSetting.fontFamily),
                                  );
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),

                              DropdownButton(
                                padding: EdgeInsets.all(4),
                                underline: Container(
                                  height: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                value: model.setting.colorCode,
                                items: [
                                  DropdownMenuItem(
                                    value: Colors.purple.toARGB32(),
                                    child: Text(
                                      "Purple",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: Colors.blue.toARGB32(),
                                    child: Text(
                                      "Blue",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: Colors.red.toARGB32(),
                                    child: Text(
                                      "Red",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: Colors.amber.toARGB32(),
                                    child: Text(
                                      "Amber",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: Colors.green.toARGB32(),
                                    child: Text(
                                      "Green",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _localSetting.colorCode = value!;
                                  });
                                  model.changeColorCode(
                                    _localSetting.colorCode,
                                  );
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
                                "Tooltips",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                              Switch(
                                value: model.setting.toolTipsEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _localSetting.toolTipsEnabled = value;
                                  });
                                  model.changeTooltipsEnabled(value);
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
      },
    );
  }
}
