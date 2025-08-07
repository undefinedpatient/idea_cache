import 'package:flutter/material.dart';
import 'package:idea_cache/model/filehandler.dart';
import 'package:idea_cache/model/status.dart';

class ICManageStatus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ICManageStatus();
  }
}

class _ICManageStatus extends State<ICManageStatus> {
  List<ICStatus> statuses = List.empty(growable: true);
  Future<void> _readStatuses() async {
    List<ICStatus> readStatuses = await FileHandler.readStatus();
    setState(() {
      statuses = readStatuses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            // Clamping
            height: (MediaQuery.of(context).size.height < 600)
                ? MediaQuery.of(context).size.height - 24
                : 600,
            width: (MediaQuery.of(context).size.width < 800)
                ? MediaQuery.of(context).size.width - 96
                : 800,
            child: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status", textScaler: TextScaler.linear(1.4)),
                Expanded(
                  child: ReorderableListView(
                    children: [],
                    onReorder: (int oldIndex, int newIndex) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
