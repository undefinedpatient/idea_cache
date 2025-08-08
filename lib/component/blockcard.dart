import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/fileHandler.dart';
import 'package:idea_cache/model/status.dart';
import 'package:idea_cache/page/managestatusview.dart';

class ICBlockCard extends StatefulWidget {
  final Function() onTap;
  final Axis direction;
  final Function()? onBlockUpdated;
  final ICBlock block;
  const ICBlockCard({
    super.key,
    required this.block,
    required this.onTap,
    this.direction = Axis.horizontal,
    this.onBlockUpdated,
  });

  @override
  State<ICBlockCard> createState() => _ICBlockCardState();
}

class _ICBlockCardState extends State<ICBlockCard> {
  ICStatus? status;
  OverlayEntry? manageStatusOverlay;
  Future<void> _loadStatus() async {
    ICStatus? readStatus = await FileHandler.findStatusById(
      widget.block.statusId,
    );
    if (readStatus != null) {
      setState(() {
        status = readStatus;
      });
    }
  }

  void _toggleManageStatusView(BuildContext context) {
    if (manageStatusOverlay != null) {
      manageStatusOverlay?.remove();
      manageStatusOverlay?.dispose();
      manageStatusOverlay = null;
      return;
    }
    manageStatusOverlay = OverlayEntry(
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setOverlayState) {
            return GestureDetector(
              onTap: () {
                manageStatusOverlay?.remove();
                manageStatusOverlay?.dispose();
                manageStatusOverlay = null;
              },
              child: ICManageStatus(
                stateSetter: setOverlayState,
                onStatusClicked: (String selectedStatusId) async {
                  ICBlock block = widget.block;
                  block.statusId = selectedStatusId;
                  await FileHandler.updateBlock(block);
                  await _loadStatus();
                  if (selectedStatusId == "") {}
                },
                onStatusDeleted: (String selectedStatusId) async {
                  ICBlock block = widget.block;
                  if (block.statusId == selectedStatusId) {
                    block.statusId = "";
                    await FileHandler.updateBlock(block);
                    await _loadStatus();
                  }
                  widget.onBlockUpdated?.call();
                },
                onTogglePicker: (String selectedStatusId) async {
                  List<Color> colors = [
                    Colors.purple,
                    Colors.pink,
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.cyan,
                    Colors.blue,
                  ];
                  manageStatusOverlay?.remove();
                  manageStatusOverlay?.dispose();
                  manageStatusOverlay = null;
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: colors.map((color) {
                          return IconButton(
                            color: color,
                            onPressed: () async {
                              Navigator.of(context).pop();
                              ICStatus? status =
                                  await FileHandler.findStatusById(
                                    selectedStatusId,
                                  );
                              if (status != null) {
                                status.colorCode = color.toARGB32();
                                await FileHandler.updateStatus(status);
                                await _loadStatus();
                              }

                              widget.onBlockUpdated?.call();
                            },
                            icon: Icon(Icons.square, color: color),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(manageStatusOverlay!);
  }

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    manageStatusOverlay?.remove();
    manageStatusOverlay?.dispose();
    manageStatusOverlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (widget.direction == Axis.horizontal) ? 80 : 160,
      width: (widget.direction == Axis.horizontal) ? 360 : 180,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        child: Flex(
          direction: widget.direction,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: ListTile(
                onTap: widget.onTap,
                leading: Icon(Icons.square_outlined),
                title: Text(widget.block.name),
                // trailing: PopupMenuButton(
                //   tooltip: "",
                //   itemBuilder: (context) => [
                //     PopupMenuItem(
                //       child: Text("Assign Status"),
                //       onTap: () {
                //         _toggleManageStatusView(context);
                //       },
                //     ),
                //   ],
                // ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: ListTile(
                title: (status == null) ? Text("") : Text(status!.statusName),
                tileColor: (status != null)
                    // Use Alpha 0.5 for the color to make it semi-transparent, so as to not obscure the text
                    ? Color(status!.colorCode).withValues(alpha: 0.7)
                    : Theme.of(context).colorScheme.surfaceDim,
                onTap: () {
                  _toggleManageStatusView(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
