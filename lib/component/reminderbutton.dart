import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:idea_cache/notificationhandler.dart';
import 'package:provider/provider.dart';

class ICReminderButton extends StatefulWidget {
  final void Function() onTap;
  const ICReminderButton({super.key, required this.onTap});

  @override
  State<ICReminderButton> createState() => _ICReminderButtonState();
}

class _ICReminderButtonState extends State<ICReminderButton> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 1000), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ICReminder? currentAlarm = .firstOrNull;

    // If there's an active alarm and we haven't shown it yet, show dialog
    ICNotificationHandler handler = Provider.of<ICNotificationHandler>(
      context,
      listen: true,
    );
    for (var currentAlarm in handler.alarmList) {
      // _previouslyShownAlarm = currentAlarm;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Reminder"),
              content: Text(currentAlarm.name),
              actions: [
                TextButton(
                  onPressed: () {
                    handler.alarmCallBack(currentAlarm);
                    currentAlarm.status = reminderStatus.DISMISSED;
                    handler.updateReminder(currentAlarm);
                    Navigator.pop(context);
                  },
                  child: const Text("Dismiss"),
                ),
                TextButton(
                  onPressed: () {
                    handler.alarmCallBack(currentAlarm);
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ICReminder? reminder =
        ICNotificationHandler.oldestTriggeredReminder ??
        ICNotificationHandler.upcomingReminder;
    String? timeDisplay = reminder?.time
        .difference(DateTime.now())
        .toString()
        .split('.')[0];
    return Consumer<ICNotificationHandler>(
      builder: (context, handler, child) {
        return IconButton.filled(
          style: ButtonStyle(
            backgroundColor: WidgetStateColor.fromMap({
              WidgetState.any: (reminder?.status == reminderStatus.TRIGGERED)
                  ? Colors.yellow.shade700
                  : Theme.of(context).colorScheme.primary,
            }),
          ),
          onPressed: widget.onTap,

          icon: (reminder != null)
              ? Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (reminder.status == reminderStatus.TRIGGERED)
                          ? Icons.notifications_active
                          : Icons.notifications,
                      size: 32,
                    ),
                    Text(
                      reminder.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      textScaler: TextScaler.linear(1.2),
                    ),
                    Text(
                      timeDisplay!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                )
              : const Icon(Icons.notifications, size: 32),
        );
      },
    );
  }
}
