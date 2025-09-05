import 'package:flutter/material.dart';
import 'package:idea_cache/component/renamecachedialog.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:provider/provider.dart';

class ICCacheCard extends StatefulWidget {
  final int index;
  final Axis scrollDirection;
  final String cacheId;
  final void Function() onSetPage;

  const ICCacheCard({
    super.key,
    required this.index,
    required this.scrollDirection,
    required this.cacheId,
    required this.onSetPage,
  });

  @override
  State<ICCacheCard> createState() => _ICCacheCardState();
}

class _ICCacheCardState extends State<ICCacheCard> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ICCacheModel>(
      builder: (context, model, child) {
        /**
         * Local Cache is required for updating the cache directly via cache model
         */
        Cache localCache = model.caches.firstWhere(
          (cache) => cache.id == widget.cacheId,
        );
        return (widget.scrollDirection == Axis.horizontal)
            ? ReorderableDelayedDragStartListener(
                index: widget.index,
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.onSetPage,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      height: 60,
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localCache.name,
                            overflow: TextOverflow.ellipsis,
                            textScaler: TextScaler.linear(1.2),
                          ),
                          Text(
                            overflow: TextOverflow.ellipsis,
                            "# of Blocks: ${localCache.blockIds.length}",
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ReorderableDragStartListener(
                                index: widget.index,
                                child: Icon(
                                  Icons.pages_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceTint,
                                ),
                              ),
                              PopupMenuButton(
                                padding: EdgeInsetsGeometry.all(0),
                                menuPadding: EdgeInsets.all(0),
                                tooltip: "",
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    onTap: () {
                                      _textEditingController.text =
                                          localCache.name;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ICRenameCacheDialog(
                                            targetCache: localCache,
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
                                  PopupMenuItem(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return KeyboardListener(
                                            focusNode: _focusNode,
                                            autofocus: true,
                                            onKeyEvent: (KeyEvent keyEvent) {
                                              if (keyEvent
                                                          .logicalKey
                                                          .keyLabel ==
                                                      "Y" ||
                                                  keyEvent
                                                          .logicalKey
                                                          .keyLabel ==
                                                      "Enter") {
                                                model.deleteCacheById(
                                                  widget.cacheId,
                                                );
                                                final SnackBar
                                                snackBar = SnackBar(
                                                  content: Text(
                                                    "Block ${localCache.name} Deleted!",
                                                  ),
                                                  duration:
                                                      Durations.extralong3,
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(snackBar);
                                                Navigator.pop(context);
                                              }
                                              if (keyEvent
                                                      .logicalKey
                                                      .keyLabel ==
                                                  "N") {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Dialog(
                                              shape: BeveledRectangleBorder(),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                child: Column(
                                                  spacing: 8,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      "Confirm Cache Deletion?",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .secondary,
                                                          ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () async {
                                                            model
                                                                .deleteCacheById(
                                                                  widget
                                                                      .cacheId,
                                                                );
                                                            final SnackBar
                                                            snackBar = SnackBar(
                                                              content: Text(
                                                                "Cache ${localCache.name} Deleted!",
                                                              ),
                                                              duration: Durations
                                                                  .extralong3,
                                                            );
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              snackBar,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: const Text(
                                                            "Delete (Y)",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .redAccent,
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: const Text(
                                                            "Close (n)",
                                                          ),
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
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : ReorderableDelayedDragStartListener(
                index: widget.index,
                child: SizedBox(
                  height: 96,
                  width: 200,
                  child: Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: ReorderableDragStartListener(
                        index: widget.index,
                        child: Icon(
                          Icons.pages_outlined,
                          color: Theme.of(context).colorScheme.surfaceTint,
                        ),
                      ),
                      title: Text(
                        localCache.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton(
                        padding: EdgeInsetsGeometry.all(0),
                        menuPadding: EdgeInsets.all(0),
                        tooltip: "",
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: () {
                              _textEditingController.text = localCache.name;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ICRenameCacheDialog(
                                    targetCache: localCache,
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
                          PopupMenuItem(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return KeyboardListener(
                                    focusNode: _focusNode,
                                    autofocus: true,
                                    onKeyEvent: (KeyEvent keyEvent) {
                                      if (keyEvent.logicalKey.keyLabel == "Y" ||
                                          keyEvent.logicalKey.keyLabel ==
                                              "Enter") {
                                        model.deleteCacheById(widget.cacheId);
                                        final SnackBar snackBar = SnackBar(
                                          content: Text(
                                            "Block ${localCache.name} Deleted!",
                                          ),
                                          duration: Durations.extralong3,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(snackBar);
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              "Confirm Cache Deletion?",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                  ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton(
                                                  onPressed: () async {
                                                    model.deleteCacheById(
                                                      widget.cacheId,
                                                    );
                                                    final SnackBar
                                                    snackBar = SnackBar(
                                                      content: Text(
                                                        "Cache ${localCache.name} Deleted!",
                                                      ),
                                                      duration:
                                                          Durations.extralong3,
                                                    );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(snackBar);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    "Delete (Y)",
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    "Close (n)",
                                                  ),
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
                        ],
                      ),
                      subtitle: Text(
                        "# of Blocks: ${localCache.blockIds.length}",
                      ),
                      onTap: widget.onSetPage,
                    ),
                  ),
                ),
              );
      },
    );
  }
}
