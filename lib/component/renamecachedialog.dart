import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:provider/provider.dart';

class ICRenameCacheDialog extends StatefulWidget {
  final Cache _targetCache;
  const ICRenameCacheDialog({super.key, required targetCache})
    : _targetCache = targetCache;

  @override
  State<ICRenameCacheDialog> createState() => _ICRenameCacheDialogState();
}

class _ICRenameCacheDialogState extends State<ICRenameCacheDialog> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    controller.text = widget._targetCache.name;
    return Consumer<ICCacheModel>(
      builder: (context, cacheModel, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(0),
          ),
          child: Container(
            width: 240,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: "Edit Cache Name"),
                  onSubmitted: (value) async {
                    widget._targetCache.name = value;
                    cacheModel.updateCache(widget._targetCache);

                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  onPressed: () async {
                    widget._targetCache.name = controller.text;
                    cacheModel.updateCache(widget._targetCache);
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
