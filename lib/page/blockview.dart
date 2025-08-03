import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/model/fileHandler.dart';
import 'package:idea_cache/model/block.dart';
import 'package:provider/provider.dart';

class ICBlockView extends StatefulWidget {
  final String blockid;
  const ICBlockView({super.key, required String blockid}) : blockid = blockid;

  @override
  State<StatefulWidget> createState() {
    return _ICBlockView();
  }
}

class _ICBlockView extends State<ICBlockView> {
  bool isAdvancedToolBarOn = false;
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
      content: Text("Saved!"),
      duration: Durations.long4,
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
    ICAppState appState = context.watch<ICAppState>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  children: [
                    Text("Advanced Tool Bar"),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: isAdvancedToolBarOn,

                        onChanged: (value) {
                          setState(() {
                            isAdvancedToolBarOn = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              MenuItemButton(
                onPressed: () {
                  _onSave(context);
                  appState.setContentEditedState(false);
                  setState(() {});
                },
                requestFocusOnHover: false,
                child: (appState.isContentEdited)
                    ? Text(" Not Saved! ")
                    : Text(" Save "),
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
              showInlineCode: isAdvancedToolBarOn,
              showSubscript: isAdvancedToolBarOn,
              showSuperscript: isAdvancedToolBarOn,
              showColorButton: isAdvancedToolBarOn,
              showHeaderStyle: isAdvancedToolBarOn,
              showLink: isAdvancedToolBarOn,
              showCodeBlock: isAdvancedToolBarOn,
              showBackgroundColorButton: isAdvancedToolBarOn,
            ),
          ),
          Expanded(
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                LogicalKeySet(
                  LogicalKeyboardKey.controlLeft,
                  LogicalKeyboardKey.keyS,
                ): () async {
                  appState.setContentEditedState(false);
                  await _onSave(context);
                  setState(() {}); // Trigger Rebuild
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
                  padding: EdgeInsets.all(18),
                  placeholder: "Write Something",
                  enableAlwaysIndentOnTab: true,
                  onTapDown:
                      (
                        TapDownDetails details,
                        TextPosition Function(Offset) ValueKey,
                      ) {
                        appState.setContentEditedState(true);
                        setState(() {}); //Trigger Rebuild
                        return false;
                      },
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
