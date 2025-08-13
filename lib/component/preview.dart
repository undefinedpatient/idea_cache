import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/fileHandler.dart';

class ICPreview extends StatelessWidget {
  ICPreview({super.key, required this.blockId});
  final String blockId;
  final QuillController _quillController = QuillController.basic();
  Future<void> loadBlockContent() async {
    ICBlock? block = await FileHandler.findBlockById(blockId);
    if (block?.content == "" || block == null) {
      _quillController.document = Document();
    } else {
      _quillController.document = Document.fromJson(jsonDecode(block.content));
    }
    _quillController.readOnly = true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadBlockContent(),
      builder: (BuildContext context, snapshot) {
        return Container(
          padding: EdgeInsets.all(32),
          height: 480,
          width: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Preview", textScaler: TextScaler.linear(2)),
              Divider(),
              Expanded(child: QuillEditor.basic(controller: _quillController)),
            ],
          ),
        );
      },
    );
  }
}
