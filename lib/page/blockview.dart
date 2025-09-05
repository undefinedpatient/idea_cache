import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_cache/model/fileHandler.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/settingsmodel.dart';
import 'package:idea_cache/page/importdocumentview.dart';
import 'package:idea_cache/userpreferences.dart';
import 'package:provider/provider.dart';

class ICBlockView extends StatefulWidget {
  final ICBlock block;
  const ICBlockView({super.key, required this.block});
  @override
  State<StatefulWidget> createState() {
    return _ICBlockView();
  }
}

class _ICBlockView extends State<ICBlockView> {
  bool canRevert = false;
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
    widget.block.setContent(
      jsonEncode(_controller.document.toDelta().toJson()),
    );
    FileHandler.updateBlock(widget.block);
    final SnackBar snackBar = SnackBar(
      content: Text("Saved!"),
      duration: Durations.long4,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _loadBlockContent() async {
    if (widget.block.content == "") {
      _controller.document = Document();
      return;
    }
    _controller.document = Document.fromJson(jsonDecode(widget.block.content));
  }

  @override
  void initState() {
    super.initState();
    _loadBlockContent();
    _controller.document.changes.listen((event) {
      if (!mounted) return;
      context.read<ICAppState>().setContentEditedState(true);
      setState(() {
        canRevert = true;
      });
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

  Widget _mobileEditor() {
    ICAppState appState = context.watch<ICAppState>();
    ICUserPreferences pref = context.read<ICUserPreferences>();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 16,
        children: [
          FloatingActionButton(
            onPressed: (!canRevert)
                ? null
                : () {
                    _loadBlockContent();
                    appState.setContentEditedState(false);
                    setState(() {});
                  },
            elevation: 4,
            child: Icon(Icons.restore),
          ),
          FloatingActionButton(
            onPressed: () {
              _onSave(context);
              appState.setContentEditedState(false);
              setState(() {});
            },
            elevation: 4,
            child: Icon(Icons.save),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: TapRegion(
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        onTapInside: (event) {
          _focusNode.requestFocus();
          setState(() {});
        },
        child: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  if (Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux)
                    _desktopActionBar(appState, pref),
                  QuillSimpleToolbar(
                    controller: _controller,
                    config: QuillSimpleToolbarConfig(
                      multiRowsDisplay: false,
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        fontFamily: QuillToolbarFontFamilyButtonOptions(
                          tooltip: (pref.toolTips) ? "Font Family" : "",
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
                          tooltip: (pref.toolTips) ? "Redo" : "",
                        ),
                        undoHistory: QuillToolbarHistoryButtonOptions(
                          tooltip: (pref.toolTips) ? "Undo" : "",
                        ),
                        bold: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Bold" : "",
                        ),
                        italic: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Italic" : "",
                        ),
                        underLine: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Underline" : "",
                        ),
                        clearFormat: QuillToolbarClearFormatButtonOptions(
                          tooltip: (pref.toolTips) ? "Clear Format" : "",
                        ),
                        listNumbers: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Numbered List" : "",
                        ),
                        listBullets: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Bulleted List" : "",
                        ),
                        toggleCheckList:
                            QuillToolbarToggleCheckListButtonOptions(
                              tooltip: (pref.toolTips)
                                  ? "Toggle Check List"
                                  : "",
                            ),
                        quote: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Quote" : "",
                        ),
                        search: QuillToolbarSearchButtonOptions(
                          tooltip: (pref.toolTips) ? "Search" : "",
                        ),
                        fontSize: QuillToolbarFontSizeButtonOptions(
                          tooltip: (pref.toolTips) ? "Font Size" : "",
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

                      color: Theme.of(context).colorScheme.surfaceContainer,
                      sectionDividerColor: Theme.of(
                        context,
                      ).colorScheme.onSurface,
                      showStrikeThrough: false,
                      showAlignmentButtons: true,
                      showInlineCode: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showColorButton: false,
                      showHeaderStyle: false,
                      showCodeBlock: false,
                      showBackgroundColorButton: false,
                      showIndent: false,
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
                      padding: EdgeInsets.fromLTRB(24, 24, 64, 128),
                      placeholder: "Write Something",
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
      ),
    );
  }

  Widget _desktopEditor() {
    ICAppState appState = context.watch<ICAppState>();
    ICUserPreferences pref = context.read<ICUserPreferences>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: TapRegion(
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        onTapInside: (event) {
          _focusNode.requestFocus();
          setState(() {});
        },
        child: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  if (Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux)
                    _desktopActionBar(appState, pref),
                  QuillSimpleToolbar(
                    controller: _controller,
                    config: QuillSimpleToolbarConfig(
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        fontFamily: QuillToolbarFontFamilyButtonOptions(
                          tooltip: (pref.toolTips) ? "Font Family" : "",
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
                          tooltip: (pref.toolTips) ? "Redo" : "",
                        ),
                        undoHistory: QuillToolbarHistoryButtonOptions(
                          tooltip: (pref.toolTips) ? "Undo" : "",
                        ),
                        bold: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Bold" : "",
                        ),
                        italic: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Italic" : "",
                        ),
                        underLine: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Underline" : "",
                        ),
                        clearFormat: QuillToolbarClearFormatButtonOptions(
                          tooltip: (pref.toolTips) ? "Clear Format" : "",
                        ),
                        listNumbers: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Numbered List" : "",
                        ),
                        listBullets: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Bulleted List" : "",
                        ),
                        toggleCheckList:
                            QuillToolbarToggleCheckListButtonOptions(
                              tooltip: (pref.toolTips)
                                  ? "Toggle Check List"
                                  : "",
                            ),
                        quote: QuillToolbarToggleStyleButtonOptions(
                          tooltip: (pref.toolTips) ? "Quote" : "",
                        ),
                        search: QuillToolbarSearchButtonOptions(
                          tooltip: (pref.toolTips) ? "Search" : "",
                        ),
                        fontSize: QuillToolbarFontSizeButtonOptions(
                          tooltip: (pref.toolTips) ? "Font Size" : "",
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
                      showStrikeThrough: false,
                      showAlignmentButtons: true,
                      showInlineCode: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showColorButton: false,
                      showHeaderStyle: false,
                      showCodeBlock: false,
                      showBackgroundColorButton: false,
                      showIndent: false,
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
                      padding: EdgeInsets.all(18),
                      placeholder: "Write Something",
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return _desktopEditor();
    } else {
      return _mobileEditor();
    }
  }

  Widget _desktopActionBar(ICAppState appState, ICUserPreferences pref) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        MenuItemButton(
          onPressed: (!canRevert)
              ? null
              : () {
                  _loadBlockContent();
                  appState.setContentEditedState(false);
                  setState(() {});
                },
          requestFocusOnHover: false,
          child: Text(" Revert"),
        ),
        MenuItemButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: ICImportDocumentView(quillController: _controller),
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

        // Text(widget.blockid),
      ],
    );
  }
}
