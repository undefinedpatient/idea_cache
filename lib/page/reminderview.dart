import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:idea_cache/component/remindercard.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:idea_cache/model/remindermodel.dart';
import 'package:idea_cache/page/editreminderview.dart';
import 'package:provider/provider.dart';

class ICReminderView extends StatefulWidget {
  final void Function(String) onTapCache;
  final void Function(String, String) onTapBlock;
  const ICReminderView({
    super.key,
    required this.onTapBlock,
    required this.onTapCache,
  });
  @override
  State<StatefulWidget> createState() {
    return _ICNotificationState();
  }
}

class _ICNotificationState extends State<ICReminderView> {
  bool isCreationView = false;
  ICReminder? activeNotification;
  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.black.withAlpha(0),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Scaffold(
        primary: false,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        // padding: EdgeInsets.all(16),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (isCreationView) {
                setState(() {
                  isCreationView = !isCreationView;
                });
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(
            (isCreationView)
                ? (activeNotification == null)
                      ? "Create Reminders"
                      : "Edit Reminders"
                : "Reminders",
          ),
          actionsPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  activeNotification = null;
                  isCreationView = !isCreationView;
                });
              },
              icon: (isCreationView)
                  ? Icon(Icons.cancel_outlined)
                  : Icon(Icons.notification_add),
            ),
          ],
        ),
        body: Consumer<ICReminderModel>(
          builder: (context, model, child) {
            if (isCreationView) {
              return ICEditNotificationView(
                onSubmitted: () {
                  setState(() {
                    isCreationView = !isCreationView;
                  });
                },
                reminder: activeNotification,
              );
            }
            if (model.reminders.isNotEmpty) {
              return ReorderableListView(
                padding: EdgeInsets.all(8),
                proxyDecorator: proxyDecorator,
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                children: model.reminders
                    .asMap()
                    .entries
                    .map(
                      (entry) => ICReminderCard(
                        key: ValueKey(entry.value.id),
                        index: entry.key,
                        reminder: entry.value,
                        onTapReminder: () {
                          setState(() {
                            isCreationView = !isCreationView;
                            activeNotification = entry.value;
                          });
                        },
                        onTapCache: widget.onTapCache,
                        onTapBlock: widget.onTapBlock,
                      ),
                    )
                    .toList(),
                onReorder: (oldIndex, newIndex) async {
                  await model.reorderReminder(oldIndex, newIndex);
                },
              );
            }
            return Center(
              child: Text("You do not have any upcoming notification yet 0w0"),
            );
          },
        ),
      ),
    );
  }
}
