import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/model/fileHandler.dart';
import 'package:idea_cache/model/block.dart';

class ICBlockView extends StatefulWidget {
  final String blockid;
  const ICBlockView({super.key, required String blockid}) : blockid = blockid;

  @override
  State<StatefulWidget> createState() {
    return _ICBlockView();
  }
}

class _ICBlockView extends State<ICBlockView> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Future<void> _onSave() async {
    ICBlock? oldBlock = await FileHandler.findBlockById(widget.blockid);
    if (oldBlock == null) {
      throw Exception("Block is Null");
    }
    oldBlock.setContent(jsonEncode(_controller.document.toDelta().toJson()));
    FileHandler.updateBlock(oldBlock);
  }

  void _loadBlockContent() async {
    ICBlock? block = await FileHandler.findBlockById(widget.blockid);
    if (block == null) {
      throw Exception("Block is Null");
    }
    if (block.content == "") {
      return;
    }
    _controller.document = Document.fromJson(jsonDecode(block.content));
  }

  @override
  void initState() {
    super.initState();
    _loadBlockContent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {}); // Triggers rebuild after first frame
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(widget.blockid),
              MenuItemButton(onPressed: _onSave, child: Text("Save")),
            ],
          ),
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(),
          ),
          Expanded(
            child: QuillEditor.basic(
              controller: _controller,
              config: const QuillEditorConfig(
                padding: EdgeInsetsGeometry.all(16),
                placeholder: "Write Something",
              ),
              focusNode: _focusNode,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}
