import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/settingsmodel.dart';
import 'package:idea_cache/model/status.dart';
import 'package:idea_cache/model/statusmodel.dart';
import 'package:idea_cache/userpreferences.dart';
import 'package:provider/provider.dart';

class ICManageStatusPage extends StatefulWidget {
  final ICBlock? calleeBlock;
  const ICManageStatusPage({super.key, this.calleeBlock});

  @override
  State<StatefulWidget> createState() {
    return _ICManageStatus();
  }
}

class _ICManageStatus extends State<ICManageStatusPage> {
  final TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  OverlayEntry? colorPickerOverlay;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ICStatusModel>(context, listen: false).loadFromFile();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.black,
      Colors.grey,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.cyanAccent,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];
    ICUserPreferences pref = context.watch<ICUserPreferences>();
    String userSelectedCacheId = "";
    return Consumer3<ICStatusModel, ICBlockModel, ICCacheModel>(
      builder: (context, statusModel, blockModel, cacheModel, child) {
        return SizedBox(
          height: 600,
          width: 480,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            appBar: AppBar(
              title: Text("Statuses Manager"),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              actions: [
                Tooltip(
                  message: (pref.toolTips) ? "Create Status" : "",
                  child: IconButton(
                    onPressed: () async {
                      statusModel.createStatus();
                    },
                    icon: Icon(Icons.add),
                  ),
                ),
              ],
              actionsPadding: EdgeInsets.fromLTRB(0, 0, 16, 0),
            ),
            body: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ReorderableListView(
                    buildDefaultDragHandles: false,
                    children: statusModel.statuses.asMap().entries.map((entry) {
                      return ListTile(
                        hoverColor: Theme.of(context).focusColor,
                        key: ValueKey(entry.value.id),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReorderableDragStartListener(
                              index: entry.key,
                              child: Icon(
                                Icons.drag_handle,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(50),
                              ),
                            ),
                            Tooltip(
                              message: (pref.toolTips)
                                  ? "Change Status Color"
                                  : "",
                              child: PopupMenuButton(
                                onOpened: () {},
                                icon: Icon(
                                  Icons.circle,
                                  color: Color(entry.value.colorCode),
                                ),
                                itemBuilder: (BuildContext context) {
                                  return colors
                                      .map(
                                        (color) => PopupMenuItem(
                                          onTap: () async {
                                            ICStatus status = entry.value;
                                            status.colorCode = color.toARGB32();
                                            await FileHandler.updateStatus(
                                              status,
                                            );
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.circle,
                                            color: color,
                                          ),
                                        ),
                                      )
                                      .toList();
                                },
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          entry.value.statusName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (Platform.isWindows ||
                                Platform.isLinux ||
                                Platform.isMacOS)
                              Tooltip(
                                message: (pref.toolTips)
                                    ? "Change the Visibility of this Status"
                                    : "",
                                child: DropdownButton(
                                  autofocus: false,
                                  value: entry.value.cacheId,
                                  items: cacheModel.caches
                                      .map(
                                        (cache) => DropdownMenuItem(
                                          value: cache.id,
                                          child: Text(cache.name),
                                        ),
                                      )
                                      .followedBy([
                                        DropdownMenuItem(
                                          value: "",
                                          child: Text("Global Status"),
                                        ),
                                      ])
                                      .toList(),
                                  onChanged: (value) async {
                                    ICStatus newStatus = entry.value;
                                    newStatus.cacheId = value ?? "";
                                    await statusModel.updateStatus(newStatus);
                                    if (widget.calleeBlock != null) {
                                      await blockModel
                                          .updateLocalBlockMapByCacheId(
                                            widget.calleeBlock!.cacheId,
                                          );
                                    }
                                  },
                                ),
                              ),
                            Tooltip(
                              message: (pref.toolTips)
                                  ? "Change Status Name"
                                  : "",
                              child: IconButton(
                                onPressed: () {
                                  _textEditingController.text =
                                      entry.value.statusName;
                                  setState(() {
                                    userSelectedCacheId = entry.value.cacheId;
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (context, setDialogState) {
                                          return Dialog(
                                            child: Container(
                                              width: 240,
                                              padding: EdgeInsets.all(16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                spacing: 8,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        _textEditingController,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          "Edit Status Name",
                                                    ),
                                                    onSubmitted: (value) async {
                                                      ICStatus status =
                                                          entry.value;
                                                      status.statusName = value;
                                                      statusModel.updateStatus(
                                                        status,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  SizedBox(height: 8),
                                                  if (Platform.isAndroid ||
                                                      Platform.isIOS)
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text("Visibility: "),
                                                        Tooltip(
                                                          message:
                                                              (pref.toolTips)
                                                              ? "Change the Visibility of this Status"
                                                              : "",
                                                          // It is saved on confirm, different from desktop
                                                          child: DropdownButton(
                                                            isDense: true,
                                                            autofocus: false,
                                                            value:
                                                                userSelectedCacheId,
                                                            items: cacheModel
                                                                .caches
                                                                .map(
                                                                  (
                                                                    cache,
                                                                  ) => DropdownMenuItem(
                                                                    value: cache
                                                                        .id,
                                                                    child: Text(
                                                                      cache
                                                                          .name,
                                                                    ),
                                                                  ),
                                                                )
                                                                .followedBy([
                                                                  DropdownMenuItem(
                                                                    value: "",
                                                                    child: Text(
                                                                      "Global Status",
                                                                    ),
                                                                  ),
                                                                ])
                                                                .toList(),
                                                            onChanged: (value) async {
                                                              setDialogState(() {
                                                                userSelectedCacheId =
                                                                    value ?? "";
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      ICStatus status =
                                                          entry.value;
                                                      status.statusName =
                                                          _textEditingController
                                                              .text;
                                                      statusModel.updateStatus(
                                                        status,
                                                      );

                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Save"),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.edit_outlined),
                              ),
                            ),
                            Tooltip(
                              message: (pref.toolTips) ? "Delete Status" : "",
                              child: IconButton(
                                onPressed: () async {
                                  statusModel.deleteStatusById(entry.value.id);
                                },
                                icon: Icon(Icons.delete_outline),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onReorder: (int oldIndex, int newIndex) async {
                      statusModel.reorderStatus(oldIndex, newIndex);
                    },
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
