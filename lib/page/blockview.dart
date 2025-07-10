import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

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
  @override
  void initState() {
    super.initState();
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
