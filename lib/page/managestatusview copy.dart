import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/status.dart';

class ICManageStatus extends StatefulWidget {
  final void Function(String) onStatusClicked;
  final void Function(String) onTogglePicker;
  final void Function(String) onStatusDeleted;
  final StateSetter? _stateSetter;
  const ICManageStatus({
    super.key,
    StateSetter? stateSetter,
    required this.onStatusClicked,
    required this.onTogglePicker,
    required this.onStatusDeleted,
  }) : _stateSetter = stateSetter;

  @override
  State<StatefulWidget> createState() {
    return _ICManageStatus();
  }
}

class _ICManageStatus extends State<ICManageStatus> {
  TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  List<ICStatus> statuses = List.empty(growable: true);
  OverlayEntry? colorPickerOverlay;
  Future<void> _readStatuses() async {
    List<ICStatus> readStatuses = await FileHandler.readStatus();
    setState(() {
      statuses = readStatuses;
    });
  }

  @override
  void initState() {
    super.initState();
    _readStatuses();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            // Clamping
            height: (MediaQuery.of(context).size.height < 480)
                ? MediaQuery.of(context).size.height - 24
                : 480,
            width: (MediaQuery.of(context).size.width < 360)
                ? MediaQuery.of(context).size.width - 96
                : 360,
            child: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status", textScaler: TextScaler.linear(1.4)),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: ReorderableListView(
                      children: statuses.asMap().entries.map((entry) {
                        return ListTile(
                          hoverColor: Theme.of(context).focusColor,
                          onTap: () {
                            widget.onStatusClicked(entry.value.id);
                          },
                          key: ValueKey(entry.value.id),
                          leading: IconButton(
                            onPressed: () {
                              widget.onTogglePicker(entry.value.id);
                            },
                            color: Color(entry.value.colorCode),
                            icon: Icon(Icons.circle),
                          ),
                          title: Text(
                            entry.value.statusName,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              await FileHandler.deleteStatusById(
                                entry.value.id,
                              );
                              await _readStatuses();
                              widget.onStatusDeleted(entry.value.id);
                            },
                            icon: Icon(Icons.delete_outline),
                          ),
                        );
                      }).toList(),
                      onReorder: (int oldIndex, int newIndex) {},
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TextButton(
                    //   onPressed: () {
                    //     // widget._stateSetter(() {
                    //     //   colorPickerOverlay?.remove();
                    //     //   colorPickerOverlay = null;
                    //     // });
                    //   },
                    //   child: Text("Confirm"),
                    // ),
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
          ),
        ),
      ),
    );
  }
}
