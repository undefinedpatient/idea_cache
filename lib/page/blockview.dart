import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Map<String, String> _fontFamilies = {
    'Abel': "Abel",
    'Annie': 'Annie Use Your Telescope',
    'Coda': "Coda",
    'EB Garamond': 'EB Garamond',
    'Fira Code': 'FiraCode Nerd Font',
    'Noto Sans': "Noto Sans Thin",
    'Noto Serif': 'Noto Serif Thin',
    'Roboto': 'Roboto Thin',
  };

  Future<void> _onSave(BuildContext context) async {
    ICBlock? oldBlock = await FileHandler.findBlockById(widget.blockid);
    if (oldBlock == null) {
      throw Exception("Block is Null");
    }
    oldBlock.setContent(jsonEncode(_controller.document.toDelta().toJson()));
    FileHandler.updateBlock(oldBlock);
    final SnackBar snackBar = SnackBar(
      content: Text(
        "Saved!",
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _loadBlockContent() async {
    ICBlock? block = await FileHandler.findBlockById(widget.blockid);
    if (block == null) {
      // throw Exception("Block is Null");
      return;
    }
    if (block.content == "") {
      _controller.document = Document();
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
  void didUpdateWidget(covariant ICBlockView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadBlockContent();

    log(name: runtimeType.toString(), widget.blockid);
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MenuItemButton(
                onPressed: () {
                  _onSave(context);
                },
                requestFocusOnHover: false,
                child: Text(" Save "),
              ),
              // Text(widget.blockid),
            ],
          ),
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              buttonOptions: QuillSimpleToolbarButtonOptions(
                fontFamily: QuillToolbarFontFamilyButtonOptions(
                  items: _fontFamilies,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                fontSize: QuillToolbarFontSizeButtonOptions(
                  items: Map.from({
                    '16': '16',
                    '18': '18',
                    '24': '24',
                    '32': '32',
                    'Clear': '0',
                  }),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                selectHeaderStyleDropdownButton:
                    QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
              ),
              color: Theme.of(context).colorScheme.onSurface,
              sectionDividerColor: Theme.of(context).colorScheme.onSurface,
              showInlineCode: false,
              showSubscript: false,
              showSuperscript: false,
            ),
          ),
          Expanded(
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                LogicalKeySet(
                  LogicalKeyboardKey.controlLeft,
                  LogicalKeyboardKey.keyS,
                ): () {
                  _onSave(context);
                },
              },
              child: QuillEditor(
                controller: _controller,
                config: QuillEditorConfig(
                  customStyles: DefaultStyles(
                    quote: DefaultTextBlockStyle(
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                      HorizontalSpacing.zero,
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(20),
                        border: BoxBorder.fromLTRB(
                          left: BorderSide(
                            width: 4,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    lists: DefaultListBlockStyle(
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                      HorizontalSpacing.zero,
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      null,
                      null,
                    ),
                    sizeSmall: TextStyle(fontSize: 16),
                    sizeLarge: TextStyle(fontSize: 20),
                    sizeHuge: TextStyle(fontSize: 24),

                    color: Colors.amber,
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Roboto Thin',
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                      HorizontalSpacing.zero,
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      null,
                    ),
                  ),
                  paintCursorAboveText: true,
                  padding: EdgeInsetsGeometry.all(18),
                  placeholder: "Write Something",
                  // onKeyPressed: (event, node) {
                  // },
                ),
                focusNode: _focusNode,
                scrollController: _scrollController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
