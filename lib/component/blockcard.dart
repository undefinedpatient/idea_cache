import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/component/preview.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/fileHandler.dart';
import 'package:idea_cache/model/status.dart';
import 'package:idea_cache/page/managestatuspage.dart';
import 'package:provider/provider.dart';

// The Status will be following colorScheme.surfaceDim if it is an empty status
class ICBlockCard extends StatefulWidget {
  final Function() onTap;
  final Axis direction;
  final Function()? updateCallBack;
  final int index;
  final ICBlock block;
  const ICBlockCard({
    super.key,
    required this.index,
    required this.block,
    required this.onTap,
    this.direction = Axis.horizontal,
    this.updateCallBack,
  });

  @override
  State<ICBlockCard> createState() => _ICBlockCardState();
}

class _ICBlockCardState extends State<ICBlockCard> {
  ICStatus? status;
  TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  List<ICStatus> statuses = List.empty(growable: true);
  OverlayEntry? manageStatusOverlay;
  Future<void> _loadCurrentBlockStatus() async {
    ICStatus? readStatus = await FileHandler.findStatusById(
      widget.block.statusId,
    );
    if (readStatus != null) {
      setState(() {
        status = readStatus;
      });
    } else {
      setState(() {
        status = null;
      });
    }
  }

  Future<void> _readStatuses() async {
    List<ICStatus> readStatuses =
        await FileHandler.readAvailableStatusByCacheId(widget.block.cacheId);
    setState(() {
      statuses = readStatuses;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentBlockStatus();
    _readStatuses();
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
    ICSettingsModel appState = context.watch<ICSettingsModel>();
    // when list view use this
    // ListTile(
    //             onTap: widget.onTap,
    //             leading: Icon(Icons.square_outlined),
    //             title: Text(widget.block.name),
    //           ),
    return LayoutBuilder(
      builder: (context, contraint) {
        return SizedBox(
          height: (widget.direction == Axis.horizontal) ? 90 : 160,
          width: (widget.direction == Axis.horizontal) ? 360 : 200,
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: Flex(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              direction: widget.direction,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 3,
                  child: ClipRRect(
                    child: ListTile(
                      leading: ReorderableDragStartListener(
                        index: widget.index,
                        child: Icon(
                          Icons.reorder,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(50),
                        ),
                      ),
                      trailing: PopupMenuButton(
                        tooltip: "",
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // _textEditingController.text = userCache!.name;
                                  return Dialog(
                                    child: Container(
                                      width: 240,
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 8,
                                        children: [
                                          TextField(
                                            controller: _textEditingController,
                                            decoration: InputDecoration(
                                              labelText: "Edit Block Name",
                                            ),
                                            onSubmitted: (value) async {
                                              widget.block.name = value;
                                              await FileHandler.updateBlock(
                                                widget.block,
                                              );
                                              await widget.updateCallBack
                                                  ?.call();

                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              widget.block.name =
                                                  _textEditingController.text;
                                              await FileHandler.updateBlock(
                                                widget.block,
                                              );
                                              await widget.updateCallBack
                                                  ?.call();
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
                            child: Row(
                              spacing: 8,
                              children: [
                                Icon(Icons.edit_outlined, size: 16),
                                Text("Rename"),
                              ],
                            ),
                          ),
                        ].toList(),
                      ),
                      onTap: widget.onTap,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          Text(
                            widget.block.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          PopupMenuButton(
                            tooltip: "",
                            menuPadding: EdgeInsets.all(0),
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
                            borderRadius: BorderRadius.circular(8),
                            itemBuilder: (context) => statuses
                                .map(
                                  (status) => PopupMenuItem(
                                    onTap: () async {
                                      ICBlock block = widget.block;
                                      block.statusId = status.id;
                                      await FileHandler.updateBlock(block);
                                      await _loadCurrentBlockStatus();
                                    },
                                    child: Row(
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Color(status.colorCode),
                                          size: 16,
                                        ),
                                        Text(status.statusName),
                                      ],
                                    ),
                                  ),
                                )
                                .followedBy([
                                  PopupMenuItem(
                                    onTap: () async {
                                      ICBlock block = widget.block;
                                      block.statusId = "";
                                      await FileHandler.updateBlock(block);
                                      await _loadCurrentBlockStatus();
                                    },
                                    child: Row(
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceDim,
                                          size: 16,
                                        ),
                                        Text("Empty Status"),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            child: ICManageStatusPage(
                                              updateCallback: () {
                                                widget.updateCallBack?.call();
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          size: 16,
                                        ),
                                        Text("Edit Status"),
                                      ],
                                    ),
                                  ),
                                ])
                                .toList(),

                            child: Row(
                              spacing: 8,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color: Color(
                                    status?.colorCode ?? 0xFF000000,
                                  ).withAlpha(100),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      4,
                                      8,
                                      4,
                                    ),
                                    child: Text(
                                      status?.statusName ?? "No status",
                                      style: TextStyle(
                                        color: (status != null)
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: ClipRRect(
                    child: Tooltip(
                      message: (appState.toolTipsEnabled) ? "Preview" : "",
                      child: ListTile(
                        tileColor: (status != null)
                            ? Color(status!.colorCode).withAlpha(100)
                            : Theme.of(context).colorScheme.surfaceDim,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: ICPreview(
                                  blockId: widget.block.id,
                                  nagivateToPageCallback: widget.onTap,
                                ),
                              );
                            },
                          );
                        },
                        title: (status != null) ? Text("") : Text(""),
                      ),
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
