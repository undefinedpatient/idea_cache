import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:idea_cache/notificationhandler.dart';
import 'package:provider/provider.dart';

class ICReminderButton extends StatefulWidget {
  final void Function() onTap;
  final void Function() onReminderTriggered;
  const ICReminderButton({
    super.key,
    required this.onTap,
    required this.onReminderTriggered,
  });

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
                  ? Colors.yellowAccent.shade700
                  : Theme.of(context).colorScheme.primary,
            }),
          ),
          onPressed: widget.onTap,

          icon: (reminder != null)
              ? Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications, size: 32),
                    Text(
                      reminder!.name,
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
