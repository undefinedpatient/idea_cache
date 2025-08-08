import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/status.dart';

class ICManageStatusPage extends StatefulWidget {
  const ICManageStatusPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ICManageStatus();
  }
}

class _ICManageStatus extends State<ICManageStatusPage> {
  TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  List<Cache> _caches = List.empty(growable: true);
  List<ICStatus> statuses = List.empty(growable: true);
  OverlayEntry? colorPickerOverlay;
  Future<void> _readStatuses() async {
    List<ICStatus> readStatuses = await FileHandler.readStatus();
    setState(() {
      statuses = readStatuses;
    });
  }

  Future<void> _readCaches() async {
    List<Cache> readCaches = await FileHandler.readCaches();
    setState(() {
      _caches = readCaches;
    });
  }

  @override
  void initState() {
    super.initState();
    _readStatuses();
    _readCaches();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      appBar: AppBar(
        title: Text("Statuses Manager"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [],
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
              children: statuses.asMap().entries.map((entry) {
                List<Color> colors = [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.purple,
                  Colors.orange,
                ];
                return ReorderableDragStartListener(
                  index: entry.key,
                  key: ValueKey(entry.value.id),
                  child: ListTile(
                    hoverColor: Theme.of(context).focusColor,
                    key: ValueKey(entry.value.id),
                    leading: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: colors
                                    .map(
                                      (color) => IconButton(
                                        onPressed: () async {
                                          ICStatus status = entry.value;
                                          status.colorCode = color.toARGB32();
                                          await FileHandler.updateStatus(
                                            status,
                                          );
                                          await _readStatuses();
                                          await _readCaches();
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.square, color: color),
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.circle),
                      color: Color(entry.value.colorCode),
                    ),
                    title: Text(
                      entry.value.statusName,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton(
                          value: entry.value.cacheId,
                          items: _caches
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
                            await FileHandler.updateStatus(newStatus);
                            await _readStatuses();
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            _textEditingController.text =
                                entry.value.statusName;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                child: Container(
                                  width: 400,
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: _textEditingController,
                                        decoration: InputDecoration(
                                          labelText: "Edit Status Name",
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          entry.value.statusName =
                                              _textEditingController.text;
                                          await FileHandler.updateStatus(
                                            entry.value,
                                          );
                                          await _readStatuses();
                                          Navigator.pop(context);
                                        },
                                        child: Text("Save"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () async {
                            await FileHandler.deleteStatusById(entry.value.id);
                            await _readStatuses();
                          },
                          icon: Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                statuses.insert(newIndex, statuses.removeAt(oldIndex));
                setState(() {});
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () async {
                  ICStatus status = ICStatus(statusName: "UnnamedStatus");

                  await FileHandler.appendStatus(status);
                  await _readStatuses();
                },
                child: Text("Add Status"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
