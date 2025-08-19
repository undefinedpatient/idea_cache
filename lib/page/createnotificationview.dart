import 'package:flutter/material.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:idea_cache/model/notificationmodel.dart';
import 'package:provider/provider.dart';

class ICCreateNotificationView extends StatefulWidget {
  const ICCreateNotificationView({super.key});

  @override
  State<ICCreateNotificationView> createState() =>
      _ICCreateNotificationViewState();
}

class _ICCreateNotificationViewState extends State<ICCreateNotificationView> {
  String userSelectedCacheId = "";
  String userSelectedBlockId = "";
  TimeOfDay userSelectedTime = TimeOfDay.now();
  DateTime userSelectDate = DateTime.now();
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController descriptionEditingController =
      TextEditingController();
  // final TextEditingController _hourEditingController = TextEditingController(
  //   text: TimeOfDay.now().hour.toString(),
  // );
  // final TextEditingController _minuteEditingController = TextEditingController(
  //   text: TimeOfDay.now().minute.toString(),
  // );
  @override
  void initState() {
    super.initState();
    // Init the editing controller
    // setState(() {
    //   _hourEditingController.text = userSelectedTime.hour.toString();
    //   _minuteEditingController.text = userSelectedTime.minute.toString();
    // });
  }

  @override
  Widget build(BuildContext context) {
    ICNotificationModel notificationModel = context.read<ICNotificationModel>();
    ICCacheModel cacheModel = context.read<ICCacheModel>();
    ICBlockModel blockModel = context.read<ICBlockModel>();
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              TextField(
                controller: nameEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: descriptionEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Decription (Optional)',
                ),
              ),
              Divider(),
              Row(
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
                          hint: Text("ss"),
                          padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                          value: userSelectedCacheId,
                          items: cacheModel.caches
                              .map(
                                (cache) => DropdownMenuItem(
                                  value: cache.id,
                                  child: Text(cache.name),
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
                              : blockModel.cacheBlocksMap[userSelectedCacheId]!
                                    .map(
                                      (cache) => DropdownMenuItem(
                                        value: cache.id,
                                        child: Text(cache.name),
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
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Time: ", textScaler: TextScaler.linear(1.2)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Text(
                          userSelectedTime.format(context),
                          textScaler: TextScaler.linear(1.2),
                        ),
                      ),
                      // SizedBox(
                      //   width: 64,
                      //   child: TextField(
                      //     controller: _hourEditingController,
                      //     decoration: InputDecoration(labelText: "Hour"),
                      //   ),
                      // ),
                      // Text(":"),
                      // SizedBox(
                      //   width: 64,
                      //   child: TextField(
                      //     controller: _minuteEditingController,
                      //     decoration: InputDecoration(labelText: "Minute"),
                      //   ),
                      // ),
                      IconButton(
                        onPressed: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            confirmText: "Confirm",
                          );
                          if (time != null) {
                            setState(() {
                              userSelectedTime = time;
                            });
                          }
                        },
                        icon: Icon(Icons.punch_clock),
                      ),
                    ],
                  ),
                  VerticalDivider(),
                  Row(
                    children: [
                      Text("Date: ", textScaler: TextScaler.linear(1.2)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "${userSelectDate.year}-${userSelectDate.month}-${userSelectDate.day}",
                          textScaler: TextScaler.linear(1.2),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          DateTime? time = await showDatePicker(
                            confirmText: "Confirm",
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 42)),
                          );
                          if (time != null) {
                            setState(() {
                              userSelectDate = time;
                            });
                          }
                        },
                        icon: Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Create Notification"),
        ),
      ],
    );
  }
}
