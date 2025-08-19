import 'package:flutter/material.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:idea_cache/model/status.dart';
import 'package:idea_cache/model/statusmodel.dart';
import 'package:provider/provider.dart';

class ICReminderCard extends StatelessWidget {
  final int index;
  final ICReminder reminder;
  final void Function() onTapReminder;
  final void Function(String) onTapCache;
  final void Function(String, String) onTapBlock;
  const ICReminderCard({
    super.key,
    required this.index,
    required this.reminder,
    required this.onTapReminder,
    required this.onTapCache,
    required this.onTapBlock,
  });
  @override
  Widget build(BuildContext context) {
    // Might throw no element error
    Cache? cache;
    ICBlock? block;
    ICStatus? status;
    if (reminder.cacheId != "") {
      cache = context.read<ICCacheModel>().caches.firstWhere(
        (cache) => cache.id == reminder.cacheId,
      );
    }

    if (reminder.blockId != "" && cache != null) {
      block = context.read<ICBlockModel>().cacheBlocksMap[cache.id]!.firstWhere(
        (block) => block.id == reminder.blockId,
      );
      status = context.read<ICStatusModel>().findStatusByBlock(block);
    }
    return ReorderableDragStartListener(
      index: index,
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
                flex: 3,
                child: ListTile(
                  onTap: () {
                    onTapReminder();
                  },
                  title: Text(reminder.name, textAlign: TextAlign.center),
                  subtitle: Text(
                    reminder.description,
                    textAlign: TextAlign.center,
                  ),
                  trailing: Text(
                    (reminder.status == reminderStatus.SCHEDULED)
                        ? "Scheduled"
                        : (reminder.status == reminderStatus.TRIGGERED)
                        ? "Triggered"
                        : "Dismissed",
                  ),
                ),
              ),
              if (cache != null)
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.surfaceDim,
                    onTap: () {},
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
                    onTap: () {},
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
  }
}
