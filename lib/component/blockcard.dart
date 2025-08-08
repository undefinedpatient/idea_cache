import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/fileHandler.dart';
import 'package:idea_cache/model/status.dart';
import 'package:idea_cache/page/managestatuspage.dart';

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

  // void _toggleManageStatusView(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       content: ICManageStatus(
  //         // stateSetter: setOverlayState,
  //         onStatusClicked: (String selectedStatusId) async {
  //           ICBlock block = widget.block;
  //           block.statusId = selectedStatusId;
  //           await FileHandler.updateBlock(block);
  //           await _loadStatus();
  //           widget.onBlockUpdated?.call();
  //         },
  //         onStatusDeleted: (String selectedStatusId) async {
  //           ICBlock block = widget.block;
  //           if (block.statusId == selectedStatusId) {
  //             block.statusId = "";
  //             await FileHandler.updateBlock(block);
  //             await _loadStatus();
  //           }
  //           widget.onBlockUpdated?.call();
  //         },
  //         onTogglePicker: (String selectedStatusId) async {
  //           List<Color> colors = [
  //             Colors.purple,
  //             Colors.pink,
  //             Colors.red,
  //             Colors.orange,
  //             Colors.yellow,
  //             Colors.green,
  //             Colors.cyan,
  //             Colors.blue,
  //           ];
  //           manageStatusOverlay?.remove();
  //           manageStatusOverlay?.dispose();
  //           manageStatusOverlay = null;
  //           await showDialog(
  //             context: context,
  //             builder: (context) => AlertDialog(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(0),
  //               ),
  //               content: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: colors.map((color) {
  //                   return IconButton(
  //                     color: color,
  //                     onPressed: () async {
  //                       Navigator.of(context).pop();
  //                       ICStatus? status = await FileHandler.findStatusById(
  //                         selectedStatusId,
  //                       );
  //                       if (status != null) {
  //                         status.colorCode = color.toARGB32();
  //                         await FileHandler.updateStatus(status);
  //                         await _loadStatus();
  //                       }

  //                       widget.onBlockUpdated?.call();
  //                     },
  //                     icon: Icon(Icons.square, color: color),
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  //   // if (manageStatusOverlay != null) {
  //   //   manageStatusOverlay?.remove();
  //   //   manageStatusOverlay?.dispose();
  //   //   manageStatusOverlay = null;
  //   //   return;
  //   // }
  //   // manageStatusOverlay = OverlayEntry(
  //   //   builder: (BuildContext context) {
  //   //     return StatefulBuilder(
  //   //       builder: (BuildContext context, StateSetter setOverlayState) {
  //   //         return GestureDetector(
  //   //           onTap: () {
  //   //             manageStatusOverlay?.remove();
  //   //             manageStatusOverlay?.dispose();
  //   //             manageStatusOverlay = null;
  //   //           },
  //   //           child: ICManageStatus(
  //   //             stateSetter: setOverlayState,
  //   //             onStatusClicked: (String selectedStatusId) async {
  //   //               ICBlock block = widget.block;
  //   //               block.statusId = selectedStatusId;
  //   //               await FileHandler.updateBlock(block);
  //   //               await _loadStatus();
  //   //               widget.onBlockUpdated?.call();
  //   //             },
  //   //             onStatusDeleted: (String selectedStatusId) async {
  //   //               ICBlock block = widget.block;
  //   //               if (block.statusId == selectedStatusId) {
  //   //                 block.statusId = "";
  //   //                 await FileHandler.updateBlock(block);
  //   //                 await _loadStatus();
  //   //               }
  //   //               widget.onBlockUpdated?.call();
  //   //             },
  //   //             onTogglePicker: (String selectedStatusId) async {
  //   //               List<Color> colors = [
  //   //                 Colors.purple,
  //   //                 Colors.pink,
  //   //                 Colors.red,
  //   //                 Colors.orange,
  //   //                 Colors.yellow,
  //   //                 Colors.green,
  //   //                 Colors.cyan,
  //   //                 Colors.blue,
  //   //               ];
  //   //               manageStatusOverlay?.remove();
  //   //               manageStatusOverlay?.dispose();
  //   //               manageStatusOverlay = null;
  //   //               await showDialog(
  //   //                 context: context,
  //   //                 builder: (context) => AlertDialog(
  //   //                   shape: RoundedRectangleBorder(
  //   //                     borderRadius: BorderRadius.circular(0),
  //   //                   ),
  //   //                   content: Row(
  //   //                     mainAxisSize: MainAxisSize.min,
  //   //                     children: colors.map((color) {
  //   //                       return IconButton(
  //   //                         color: color,
  //   //                         onPressed: () async {
  //   //                           Navigator.of(context).pop();
  //   //                           ICStatus? status =
  //   //                               await FileHandler.findStatusById(
  //   //                                 selectedStatusId,
  //   //                               );
  //   //                           if (status != null) {
  //   //                             status.colorCode = color.toARGB32();
  //   //                             await FileHandler.updateStatus(status);
  //   //                             await _loadStatus();
  //   //                           }

  //   //                           widget.onBlockUpdated?.call();
  //   //                         },
  //   //                         icon: Icon(Icons.square, color: color),
  //   //                       );
  //   //                     }).toList(),
  //   //                   ),
  //   //                 ),
  //   //               );
  //   //             },
  //   //           ),
  //   //         );
  //   //       },
  //   //     );
  //   //   },
  //   // );
  //   // Overlay.of(context, rootOverlay: true).insert(manageStatusOverlay!);
  // }

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
    // when list view use this
    // ListTile(
    //             onTap: widget.onTap,
    //             leading: Icon(Icons.square_outlined),
    //             title: Text(widget.block.name),
    //           ),
    return LayoutBuilder(
      builder: (context, contraint) {
        return SizedBox(
          height: (widget.direction == Axis.horizontal) ? 80 : 160,
          width: (widget.direction == Axis.horizontal) ? 360 : 180,
          child: Card(
            elevation: 2,
            clipBehavior: Clip.hardEdge,
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
                      onTap: widget.onTap,
                      // leading: Icon(Icons.square_outlined),
                      // subtitle: PopupMenuButton(
                      //   tooltip: "",
                      //   menuPadding: EdgeInsets.all(0),
                      //   elevation: 2,
                      //   clipBehavior: Clip.hardEdge,
                      //   borderRadius: BorderRadius.circular(8),
                      //   itemBuilder: (context) => statuses
                      //       .map(
                      //         (status) => PopupMenuItem(
                      //           child: Row(
                      //             spacing: 8,
                      //             children: [
                      //               Icon(
                      //                 Icons.circle,
                      //                 color: Color(status.colorCode),
                      //                 size: 16,
                      //               ),
                      //               Text(status.statusName),
                      //             ],
                      //           ),
                      //         ),
                      //       )
                      //       .followedBy([PopupMenuItem(child: Text("No"))])
                      //       .toList(),

                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       if (status != null)
                      //         Icon(
                      //           Icons.circle,
                      //           color: Color(status!.colorCode),
                      //         ),
                      //       Text(
                      //         status?.statusName ?? "No status",
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.block.name),
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
                                    child: Text("Empty Status"),
                                  ),
                                ])
                                .toList(),

                            child: Row(
                              spacing: 8,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (status != null)
                                  Icon(
                                    Icons.circle,
                                    size: 16,
                                    color: Color(status!.colorCode),
                                  ),
                                Text(
                                  status?.statusName ?? "No status",
                                  style: TextStyle(
                                    color: (status != null)
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
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
                    child: ListTile(
                      tileColor: (status != null)
                          ? Color(status!.colorCode).withAlpha(100)
                          : Theme.of(context).colorScheme.surfaceDim,
                      onTap: widget.onTap,
                      title: (status != null) ? Text("") : Text(""),
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
