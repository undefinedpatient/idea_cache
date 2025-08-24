import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/component/preview.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:idea_cache/model/settingsmodel.dart';
import 'package:idea_cache/model/status.dart';
import 'package:idea_cache/model/statusmodel.dart';
import 'package:idea_cache/page/managestatuspage.dart';
import 'package:provider/provider.dart';

// The Status will be following colorScheme.surfaceDim if it is an empty status
class ICBlockCard extends StatefulWidget {
  final Function() onTap;
  final Axis axis;
  final int index;
  final ICBlock block;
  const ICBlockCard({
    super.key,
    required this.index,
    required this.block,
    required this.onTap,
    this.axis = Axis.horizontal,
  });

  @override
  State<ICBlockCard> createState() => _ICBlockCardState();
}

class _ICBlockCardState extends State<ICBlockCard> {
  ICStatus? status;
  FocusNode _focusNode = FocusNode();
  TextEditingController _textEditingController = TextEditingController(
    text: "",
  );
  OverlayEntry? manageStatusOverlay;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    manageStatusOverlay?.remove();
    manageStatusOverlay?.dispose();
    manageStatusOverlay = null;
    super.dispose();
  }

  Widget _previewWidget(BuildContext ctx, ICSettingsModel settingModel) {
    return Builder(
      builder: (ctx) {
        return Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Consumer<ICStatusModel>(
            builder: (context, model, child) {
              ICStatus? currentStatus = model.findStatusByBlock(widget.block);
              return Tooltip(
                message: (settingModel.setting.toolTipsEnabled)
                    ? "Preview"
                    : "",
                child: ListTile(
                  tileColor: (currentStatus != null)
                      ? Color(currentStatus.colorCode).withAlpha(100)
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
              );
            },
          ),
        );
      },
    );
  }

  Widget _popupMenuWidget(
    BuildContext ctx,
    ICCacheModel cacheModel,
    ICBlockModel blockModel,
  ) {
    return Builder(
      builder: (ctx) {
        return PopupMenuButton(
          menuPadding: EdgeInsets.all(0),
          tooltip: "",
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () {
                _textEditingController.text = widget.block.name;
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
                                blockModel.updateBlock(widget.block);

                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              onPressed: () async {
                                widget.block.name = _textEditingController.text;
                                blockModel.updateBlock(widget.block);
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
                children: [Icon(Icons.edit_outlined, size: 16), Text("Rename")],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return KeyboardListener(
                      focusNode: _focusNode,
                      autofocus: true,
                      onKeyEvent: (KeyEvent keyEvent) async {
                        if (keyEvent.logicalKey.keyLabel == "Y" ||
                            keyEvent.logicalKey.keyLabel == "Enter") {
                          await blockModel.deleteBlock(widget.block);
                          cacheModel.loadFromFileSlient();
                          final SnackBar snackBar = SnackBar(
                            content: Text(
                              "Block ${widget.block.name} Deleted!",
                            ),
                            duration: Durations.extralong3,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pop(context);
                        }
                        if (keyEvent.logicalKey.keyLabel == "N") {
                          Navigator.pop(context);
                        }
                      },
                      child: Dialog(
                        shape: BeveledRectangleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Confirm Block Deletion?",
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      await blockModel.deleteBlock(
                                        widget.block,
                                      );
                                      cacheModel.loadFromFileSlient();
                                      final SnackBar snackBar = SnackBar(
                                        content: Text(
                                          "Block ${widget.block.name} Deleted!",
                                        ),
                                        duration: Durations.extralong3,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(snackBar);
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Delete (Y)",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Close (n)"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Row(
                spacing: 8,
                children: [
                  Icon(Icons.delete_outline, size: 16),
                  Text("Delete"),
                ],
              ),
            ),
          ].toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ICSettingsModel appState = context.watch<ICSettingsModel>();
    ICCacheModel cacheModel = context.read<ICCacheModel>();
    return Consumer<ICBlockModel>(
      builder: (context, model, child) {
        return ReorderableDelayedDragStartListener(
          index: widget.index,
          child: SizedBox(
            height: (widget.axis == Axis.horizontal) ? 90 : 160,
            width: (widget.axis == Axis.horizontal) ? 360 : 200,
            child: Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: (widget.axis == Axis.horizontal)
                  ? Flex(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      direction: widget.axis,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 3,
                          child: ClipRRect(
                            clipBehavior: Clip.antiAlias,
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
                              trailing: _popupMenuWidget(
                                context,
                                cacheModel,
                                model,
                              ),
                              onTap: widget.onTap,
                              title: ClipRect(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 8,
                                  children: [
                                    Text(
                                      widget.block.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Status Indicator here
                                    Consumer<ICStatusModel>(
                                      builder: (context, statusModel, child) {
                                        List<ICStatus> availableStatus =
                                            statusModel.findAvailableByCacheId(
                                              widget.block.cacheId,
                                            );
                                        ICStatus? currentStatus = statusModel
                                            .findStatusByBlock(widget.block);
                                        return PopupMenuButton(
                                          tooltip: "",
                                          menuPadding: EdgeInsets.all(0),
                                          elevation: 2,
                                          clipBehavior: Clip.antiAlias,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          itemBuilder: (context) => availableStatus
                                              .map(
                                                (status) => PopupMenuItem(
                                                  onTap: () async {
                                                    ICBlock block =
                                                        widget.block;
                                                    block.statusId = status.id;
                                                    model.updateBlock(block);
                                                  },
                                                  child: Row(
                                                    spacing: 8,
                                                    children: [
                                                      Icon(
                                                        Icons.circle,
                                                        color: Color(
                                                          status.colorCode,
                                                        ),
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
                                                    ICBlock block =
                                                        widget.block;
                                                    block.statusId = "";
                                                    model.updateBlock(block);
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    spacing: 8,
                                                    children: [
                                                      Icon(
                                                        Icons.circle,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceDim,
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
                                                          child:
                                                              ICManageStatusPage(
                                                                calleeBlock:
                                                                    widget
                                                                        .block,
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
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                color: Color(
                                                  currentStatus?.colorCode ??
                                                      0xFF000000,
                                                ).withAlpha(100),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        8,
                                                        4,
                                                        8,
                                                        4,
                                                      ),
                                                  child: Text(
                                                    currentStatus?.statusName ??
                                                        "No status",
                                                    style: TextStyle(
                                                      color:
                                                          (currentStatus !=
                                                              null)
                                                          ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .surfaceContainerHighest,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        _previewWidget(context, appState),
                      ],
                    )
                  : Flex(
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: InkWell(
                            onTap: widget.onTap,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ReorderableDragStartListener(
                                        index: widget.index,
                                        child: Icon(
                                          Icons.reorder,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface.withAlpha(50),
                                        ),
                                      ),
                                      _popupMenuWidget(
                                        context,
                                        cacheModel,
                                        model,
                                      ),
                                    ],
                                  ),
                                  ClipRect(
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 8,
                                      children: [
                                        Text(
                                          widget.block.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // Status Indicator here
                                        Consumer<ICStatusModel>(
                                          builder: (context, statusModel, child) {
                                            List<ICStatus> availableStatus =
                                                statusModel
                                                    .findAvailableByCacheId(
                                                      widget.block.cacheId,
                                                    );
                                            ICStatus? currentStatus =
                                                statusModel.findStatusByBlock(
                                                  widget.block,
                                                );
                                            return PopupMenuButton(
                                              tooltip: "",
                                              menuPadding: EdgeInsets.all(0),
                                              elevation: 2,
                                              clipBehavior: Clip.antiAlias,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              itemBuilder: (context) => availableStatus
                                                  .map(
                                                    (status) => PopupMenuItem(
                                                      onTap: () async {
                                                        ICBlock block =
                                                            widget.block;
                                                        block.statusId =
                                                            status.id;
                                                        model.updateBlock(
                                                          block,
                                                        );
                                                      },
                                                      child: Row(
                                                        spacing: 8,
                                                        children: [
                                                          Icon(
                                                            Icons.circle,
                                                            color: Color(
                                                              status.colorCode,
                                                            ),
                                                            size: 16,
                                                          ),
                                                          Text(
                                                            status.statusName,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                  .followedBy([
                                                    PopupMenuItem(
                                                      onTap: () async {
                                                        ICBlock block =
                                                            widget.block;
                                                        block.statusId = "";
                                                        model.updateBlock(
                                                          block,
                                                        );
                                                        setState(() {});
                                                      },
                                                      child: Row(
                                                        spacing: 8,
                                                        children: [
                                                          Icon(
                                                            Icons.circle,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surfaceDim,
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
                                                          builder:
                                                              (
                                                                BuildContext
                                                                context,
                                                              ) {
                                                                return Dialog(
                                                                  child: ICManageStatusPage(
                                                                    calleeBlock:
                                                                        widget
                                                                            .block,
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
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface,
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    color: Color(
                                                      currentStatus
                                                              ?.colorCode ??
                                                          0xFF000000,
                                                    ).withAlpha(100),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                            8,
                                                            4,
                                                            8,
                                                            4,
                                                          ),
                                                      child: Text(
                                                        currentStatus
                                                                ?.statusName ??
                                                            "No status",
                                                        style: TextStyle(
                                                          color:
                                                              (currentStatus !=
                                                                  null)
                                                              ? Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary
                                                              : Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surfaceContainerHighest,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _previewWidget(context, appState),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
