import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:idea_cache/model/remindermodel.dart';
import 'package:idea_cache/model/reminder.dart';
import 'package:idea_cache/notificationhandler.dart';
import 'package:provider/provider.dart';

class ICEditNotificationView extends StatefulWidget {
  final void Function() onSubmitted;
  final ICReminder? reminder;
  const ICEditNotificationView({
    super.key,
    required this.onSubmitted,
    this.reminder,
  });

  @override
  State<ICEditNotificationView> createState() => _ICEditNotificationViewState();
}

class _ICEditNotificationViewState extends State<ICEditNotificationView> {
  String userSelectedCacheId = "";
  String userSelectedBlockId = "";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController hourEditingController = TextEditingController(
    text: "0",
  );
  final TextEditingController minuteEditingController = TextEditingController(
    text: "0",
  );
  final TextEditingController secondEditingController = TextEditingController(
    text: "0",
  );
  String _trimText(String text, int length) {
    if (text.length > length) {
      return "${text.substring(0, length)}...";
    } else {
      return text;
    }
  }

  @override
  void initState() {
    super.initState();
    ICCacheModel cacheModel = Provider.of<ICCacheModel>(context, listen: false);
    ICBlockModel blockModel = Provider.of<ICBlockModel>(context, listen: false);
    if (widget.reminder != null) {
      nameEditingController.text = widget.reminder!.name;

      if (cacheModel.checkExistance(widget.reminder!.cacheId)) {
        userSelectedCacheId = widget.reminder!.cacheId;
        if (blockModel.checkExistance(
          widget.reminder!.cacheId,
          widget.reminder!.blockId,
        )) {
          userSelectedBlockId = widget.reminder!.blockId;
        }
      }

      hourEditingController.text = widget.reminder!.hours.toString();
      minuteEditingController.text = widget.reminder!.minutes.toString();
      secondEditingController.text = widget.reminder!.seconds.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    ICReminderModel reminderModel = context.read<ICReminderModel>();
    ICCacheModel cacheModel = context.read<ICCacheModel>();
    ICBlockModel blockModel = context.read<ICBlockModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name cannot be Empty";
                        }
                        return null;
                      },
                      controller: nameEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                    ),

                    Flex(
                      direction: (constraints.maxWidth < 480)
                          ? Axis.vertical
                          : Axis.horizontal,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      spacing: 8,
                      children: [
                        Row(
                          children: [
                            Text("Cache:", textScaler: TextScaler.linear(1.2)),
                            SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButton(
                                padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                value: userSelectedCacheId,
                                items: cacheModel.caches
                                    .map(
                                      (cache) => DropdownMenuItem(
                                        value: cache.id,
                                        child: Text(_trimText(cache.name, 12)),
                                      ),
                                    )
                                    .followedBy([
                                      DropdownMenuItem(
                                        value: "",
                                        child: Text("No Cache"),
                                      ),
                                    ])
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    userSelectedBlockId = "";
                                    userSelectedCacheId = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        VerticalDivider(),
                        Row(
                          children: [
                            Text("Block:", textScaler: TextScaler.linear(1.2)),
                            SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButton(
                                padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                value: userSelectedBlockId,
                                items: (userSelectedCacheId == "")
                                    ? [
                                        DropdownMenuItem(
                                          value: "",
                                          child: Text("No Block"),
                                        ),
                                      ]
                                    : blockModel
                                          .cacheBlocksMap[userSelectedCacheId]!
                                          .map(
                                            (block) => DropdownMenuItem(
                                              value: block.id,
                                              child: Text(
                                                _trimText(block.name, 12),
                                              ),
                                            ),
                                          )
                                          .followedBy([
                                            DropdownMenuItem(
                                              value: "",
                                              child: Text("No Block"),
                                            ),
                                          ])
                                          .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    userSelectedBlockId = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Wrap(
                      direction: (constraints.maxWidth < 420)
                          ? Axis.vertical
                          : Axis.horizontal,
                      spacing: 16,
                      children: [
                        Text("CountDown: ", textScaler: TextScaler.linear(1.2)),
                        SizedBox(
                          width: 72,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.isEmpty) {
                                hourEditingController.text = "0";
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^(0|[1-9][0-9]*)$'),
                              ),
                            ],
                            controller: hourEditingController,
                            keyboardType: TextInputType.name,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Hour',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 72,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.isEmpty) {
                                minuteEditingController.text = "0";
                              }
                            },
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^(0|[1-9][0-9]*)$'),
                              ),
                            ],
                            controller: minuteEditingController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Minutes',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 72,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.isEmpty) {
                                secondEditingController.text = "0";
                              }
                            },
                            controller: secondEditingController,
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^(0|[1-9][0-9]*)$'),
                              ),
                            ],
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Seconds',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          persistentFooterButtons: [
            if (widget.reminder != null)
              TextButton(
                onPressed: () {
                  reminderModel.deleteReminderById(widget.reminder!.id);
                  context.read<ICNotificationHandler>().removeReminder(
                    widget.reminder!,
                  );
                  widget.onSubmitted.call();
                },
                child: Text("Delete"),
              ),
            (widget.reminder != null)
                ? TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        int timeAsSec =
                            int.parse(hourEditingController.text) * 3600 +
                            int.parse(minuteEditingController.text) * 60 +
                            int.parse(secondEditingController.text);

                        widget.reminder!.blockId = userSelectedBlockId;
                        widget.reminder!.cacheId = userSelectedCacheId;
                        widget.reminder!.name = nameEditingController.text;
                        widget.reminder!.status = reminderStatus.SCHEDULED;
                        widget.reminder!.time = DateTime.now().add(
                          Duration(seconds: timeAsSec),
                        );
                        await reminderModel.updateReminder(widget.reminder!);
                        context.read<ICNotificationHandler>().updateReminder(
                          widget.reminder!,
                        );

                        widget.onSubmitted.call();
                      }
                    },
                    child: Text("Edit Reminder"),
                  )
                : TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        int timeAsSec =
                            int.parse(hourEditingController.text) * 3600 +
                            int.parse(minuteEditingController.text) * 60 +
                            int.parse(secondEditingController.text);

                        ICReminder reminder = ICReminder(
                          cacheId: userSelectedCacheId,
                          blockId: userSelectedBlockId,
                          name: nameEditingController.text,
                          time: DateTime.now().add(
                            Duration(seconds: timeAsSec),
                          ),
                        );
                        // Do not need to call reminderModel, the addReminder aleady add one
                        await reminderModel.appendReminder(reminder);
                        context.read<ICNotificationHandler>().updateReminder(
                          reminder,
                        );
                        widget.onSubmitted.call();
                      }
                    },
                    child: Text("Create Reminder"),
                  ),
          ],
        );
      },
    );
  }
}
