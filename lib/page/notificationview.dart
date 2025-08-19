import 'package:flutter/material.dart';
import 'package:idea_cache/component/notificationcard.dart';
import 'package:idea_cache/model/notificationmodel.dart';
import 'package:idea_cache/page/createnotificationview.dart';
import 'package:provider/provider.dart';

class ICNotificationView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ICNotificationState();
  }
}

class _ICNotificationState extends State<ICNotificationView> {
  bool isCreationView = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // padding: EdgeInsets.all(16),
      appBar: AppBar(
        actionsPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isCreationView = !isCreationView;
              });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<ICNotificationModel>(
        builder: (context, model, child) {
          if (isCreationView) {
            return ICCreateNotificationView();
          }
          if (model.notifications.length > 0) {
            return ReorderableListView(
              children: model.notifications
                  .map(
                    (notification) =>
                        ICNotificationCard(key: ValueKey(notification.id)),
                  )
                  .toList(),
              onReorder: (oldIndex, newIndex) {},
            );
          }
          return Center(
            child: Text("You do not have any upcoming notification yet 0w0"),
          );
        },
      ),
    );
  }
}
