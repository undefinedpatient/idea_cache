import 'dart:async';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:idea_cache/model/remindermodel.dart';
import 'package:idea_cache/model/status.dart';
import 'package:idea_cache/model/statusmodel.dart';
import 'package:idea_cache/notificationhandler.dart';
import 'package:provider/provider.dart';

class ICReminderCard extends StatefulWidget {
  final int index;

  final ICReminder reminder;
  final void Function() onTapReminder;
  final void Function(String) onTapCache;
  final void Function(String, String) onTapBlock;
  ICReminderCard({
    super.key,
    required this.index,
    required this.reminder,
    required this.onTapReminder,
    required this.onTapCache,
    required this.onTapBlock,
  });

  @override
  State<ICReminderCard> createState() => _ICReminderCardState();
}

class _ICReminderCardState extends State<ICReminderCard> {
  late Timer timer;
  int timeReminding = 0;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 1000), (_) {
      setState(() {
        // timeReminding = ;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Might throw no element error

    Cache? cache;
    ICBlock? block;
    ICStatus? status;
    if (widget.reminder.cacheId != "") {
      int index = context.read<ICCacheModel>().caches.indexWhere(
        (cache) => cache.id == widget.reminder.cacheId,
      );
      if (index != -1) {
        cache = context.read<ICCacheModel>().caches[index];
      }
    }

    if (widget.reminder.blockId != "" && cache != null) {
      int index = context
          .read<ICBlockModel>()
          .cacheBlocksMap[cache.id]!
          .indexWhere((block) => block.id == widget.reminder.blockId);
      if (index != -1) {
        block = context.read<ICBlockModel>().cacheBlocksMap[cache.id]![index];
        status = context.read<ICStatusModel>().findStatusByBlock(block);
      }
    }
    return Consumer2<ICReminderModel, ICNotificationHandler>(
      builder: (context, reminderModel, notificationHandler, child) {
        return ReorderableDelayedDragStartListener(
          index: widget.index,
          child: SizedBox(
            width: 180,
            height: 120,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Flex(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: ListTile(
                      onTap: () {
                        widget.onTapReminder();
                      },
                      title: Text(
                        widget.reminder.name,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: ListTile(
                      // tileColor: Theme.of(context).colorScheme.surfaceDim,
                      onTap: widget.onTapReminder,
                      title:
                          (widget.reminder.status != reminderStatus.DISMISSED)
                          ? Text(
                              widget.reminder.time
                                  .difference(DateTime.now())
                                  .toString()
                                  .split('.')[0],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            )
                          : Text(textAlign: TextAlign.center, "0:00:00"),
                      subtitle: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateColor.fromMap({
                            WidgetState.any:
                                (widget.reminder.status ==
                                    reminderStatus.SCHEDULED)
                                ? Theme.of(context).colorScheme.primary
                                : (widget.reminder.status ==
                                      reminderStatus.NOTACTIVE)
                                ? Theme.of(context).colorScheme.primaryContainer
                                : (widget.reminder.status ==
                                      reminderStatus.TRIGGERED)
                                ? Colors.yellow.shade700
                                : Colors.grey,
                          }),
                        ),
                        onPressed: () async {
                          if (widget.reminder.status ==
                              reminderStatus.SCHEDULED) {
                            widget.reminder.status = reminderStatus.NOTACTIVE;
                            notificationHandler.updateReminder(widget.reminder);
                          } else if (widget.reminder.status ==
                              reminderStatus.NOTACTIVE) {
                            widget.reminder.status = reminderStatus.SCHEDULED;
                            notificationHandler.updateReminder(widget.reminder);
                          } else if (widget.reminder.status ==
                              reminderStatus.TRIGGERED) {
                            widget.reminder.status = reminderStatus.DISMISSED;
                            notificationHandler.updateReminder(widget.reminder);
                          }
                          await reminderModel.updateReminder(widget.reminder);
                        },
                        child: Text(
                          (widget.reminder.status == reminderStatus.SCHEDULED)
                              ? "SCHEDULED"
                              : (widget.reminder.status ==
                                    reminderStatus.NOTACTIVE)
                              ? "MUTED"
                              : (widget.reminder.status ==
                                    reminderStatus.TRIGGERED)
                              ? "TRIGGERED"
                              : "DISMISSED",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (cache != null)
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.surfaceDim,
                        onTap: () {
                          widget.onTapCache(cache!.id);
                        },
                        title: Text(
                          cache.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Icon(Icons.pages),
                      ),
                    ),
                  if (block != null)
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: ListTile(
                        tileColor: (status != null)
                            ? Color(status.colorCode)
                            : Theme.of(context).colorScheme.surfaceDim,
                        onTap: () {
                          widget.onTapBlock(cache!.id, block!.id);
                        },
                        subtitle: Icon(Icons.square_outlined),
                        title: Text(
                          block.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
