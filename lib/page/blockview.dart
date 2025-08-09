import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/model/fileHandler.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/page/importdocumentview.dart';
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

  Future<void> _loadBlockContent() async {
    ICBlock? block = await FileHandler.findBlockById(widget.blockid);
    if (block == null) {
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
    _controller.document.changes.listen((event) {
      appState.setContentEditedState(true);
      setState(() {}); //Trigger Rebuild
    });
    // Rebuild the widget when the focus change, used to indicate whether the editor is being edited
    _focusNode.addListener(() {
      setState(() {});
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: SizedBox(
                        width: 190,
                        child: ListTile(
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          selected: isAdvancedToolBarOn,
                          onTap: () {
                            setState(() {
                              isAdvancedToolBarOn = !isAdvancedToolBarOn;
                            });
                          },
                          title: Text("Advanced Tool Bar"),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          MenuItemButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: ICImportDocumentView(
                                      quillController: _controller,
                                    ),
                                  );
                                },
                              );
                            },
                            requestFocusOnHover: false,
                            child: Text(" Import "),
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
                        ],
                      ),
                    ),

                    // Text(widget.blockid),
                  ],
                ),
                QuillSimpleToolbar(
                  controller: _controller,
                  config: QuillSimpleToolbarConfig(
                    buttonOptions: QuillSimpleToolbarButtonOptions(
                      fontFamily: QuillToolbarFontFamilyButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Font Family"
                            : "",
                        items: _fontFamilies,
                      ),
                      selectAlignmentButtons:
                          QuillToolbarSelectAlignmentButtonOptions(
                            tooltips: QuillSelectAlignmentValues(
                              leftAlignment: "",
                              centerAlignment: "",
                              rightAlignment: "",
                              justifyAlignment: "",
                            ),
                          ),
                      redoHistory: QuillToolbarHistoryButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Redo" : "",
                      ),
                      undoHistory: QuillToolbarHistoryButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Undo" : "",
                      ),
                      bold: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Bold" : "",
                      ),
                      italic: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Italic" : "",
                      ),
                      underLine: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Underline" : "",
                      ),
                      strikeThrough: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Strike Through"
                            : "",
                      ),
                      clearFormat: QuillToolbarClearFormatButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Clear Format"
                            : "",
                      ),
                      listNumbers: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Numbered List"
                            : "",
                      ),
                      listBullets: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Bulleted List"
                            : "",
                      ),
                      toggleCheckList: QuillToolbarToggleCheckListButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Toggle Check List"
                            : "",
                      ),
                      quote: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Quote" : "",
                      ),
                      indentDecrease: QuillToolbarIndentButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Decrease Indent"
                            : "",
                      ),
                      indentIncrease: QuillToolbarIndentButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Increase Indent"
                            : "",
                      ),
                      codeBlock: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Code Block" : "",
                      ),
                      search: QuillToolbarSearchButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Search" : "",
                      ),
                      inlineCode: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Inline Code"
                            : "",
                      ),
                      color: QuillToolbarColorButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Text Color" : "",
                      ),
                      backgroundColor: QuillToolbarColorButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Background Color"
                            : "",
                      ),

                      subscript: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Subscript" : "",
                      ),
                      superscript: QuillToolbarToggleStyleButtonOptions(
                        tooltip: (appState.toolTipsEnabled)
                            ? "Superscript"
                            : "",
                      ),
                      selectHeaderStyleDropdownButton:
                          QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                            tooltip: (appState.toolTipsEnabled)
                                ? "Select Header Style"
                                : "",
                          ),
                      fontSize: QuillToolbarFontSizeButtonOptions(
                        tooltip: (appState.toolTipsEnabled) ? "Font Size" : "",
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
                    ),

                    color: Theme.of(context).colorScheme.onSurface,
                    sectionDividerColor: Theme.of(
                      context,
                    ).colorScheme.onSurface,
                    showAlignmentButtons: isAdvancedToolBarOn,
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
              ],
            ),
          ),

          Expanded(
            child: ColorFiltered(
              colorFilter: (_focusNode.hasPrimaryFocus)
                  ? ColorFilter.srgbToLinearGamma()
                  : ColorFilter.matrix(<double>[
                      1, 0.0, 0.0, 0.0, 0.0,
                      //
                      0.0, 1, 0.0, 0.0, 0.0,
                      //
                      0.0, 0.0, 1, 0.0, 0.0,
                      //
                      0.0, 0.0, 0.0, 0.3, 0.0,
                      //
                    ]),
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
                    expands: true,
                  ),

                  focusNode: _focusNode,
                  scrollController: _scrollController,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
