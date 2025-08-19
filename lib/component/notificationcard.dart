import 'package:flutter/material.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:idea_cache/model/notification.dart';
import 'package:idea_cache/model/status.dart';
import 'package:idea_cache/model/statusmodel.dart';
import 'package:provider/provider.dart';

class ICNotificationCard extends StatelessWidget {
  final int index;
  final ICNotification notification;
  final void Function() onTapNotification;
  final void Function(String) onTapCache;
  final void Function(String, String) onTapBlock;
  const ICNotificationCard({
    super.key,
    required this.index,
    required this.notification,
    required this.onTapNotification,
    required this.onTapCache,
    required this.onTapBlock,
  });
  @override
  Widget build(BuildContext context) {
    // Might throw no element error
    Cache? cache;
    ICBlock? block;
    ICStatus? status;
    if (notification.cacheId != "") {
      cache = context.read<ICCacheModel>().caches.firstWhere(
        (cache) => cache.id == notification.cacheId,
      );
    }

    if (notification.blockId != "" && cache != null) {
      block = context.read<ICBlockModel>().cacheBlocksMap[cache.id]!.firstWhere(
        (block) => block.id == notification.blockId,
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
                    onTapNotification();
                  },
                  title: Text(notification.name, textAlign: TextAlign.center),
                  subtitle: Text(
                    notification.description,
                    textAlign: TextAlign.center,
                  ),
                  trailing: Text(
                    (notification.status == notificationStatus.SCHEDULED)
                        ? "Scheduled"
                        : (notification.status == notificationStatus.TRIGGERED)
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
