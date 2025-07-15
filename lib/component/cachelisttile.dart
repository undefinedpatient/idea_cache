
import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/filehandler.dart';

class ICCacheListTile extends StatefulWidget {
  final String _title;
  final String _cacheid;
  final Function() _onTap;
  final Function() _onEditName;
  final bool _selected;
  const ICCacheListTile({
    super.key,
    required String title,
    required String cacheid,
    required Function() onTap,
    required Function() onEditName,
    required bool selected,
  }) : _title = title,
       _cacheid = cacheid,
       _onTap = onTap,
       _onEditName = onEditName,
       _selected = selected;

  @override
  State<ICCacheListTile> createState() => _ICCacheListTileState();
}

class _ICCacheListTileState extends State<ICCacheListTile> {
  bool _isEditing = false;
  String _inputText = "";
  final TextEditingController _controller = TextEditingController();
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save the edited text when exiting edit mode
        _inputText = _controller.text;
      }
    });
  }

  // When saving is not prefered
  void _interruptEditMode() {
    setState(() {
      _isEditing = false;
      _controller.text = _inputText;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _inputText = widget._title;
      _controller.text = _inputText;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return ListTile(
      leading: Icon(widget._selected ? Icons.pages : Icons.pages_outlined),
      title: _isEditing
          ? TextField(
              autofocus: true,
              autocorrect: false,
              controller: _controller,
              onTapOutside: (_) {
                _interruptEditMode();
                FocusScope.of(context).unfocus();
              },
              onSubmitted: (_) async {
                _toggleEditMode();
                Cache? oldCache = await FileHandler.findCacheById(
                  widget._cacheid,
                );
                oldCache?.name = _inputText;
                await FileHandler.updateCache(oldCache!);
                // After update the name might be name.001 so need to fetch again
                Cache? newCache = await FileHandler.findCacheById(
                  widget._cacheid,
                );
                setState(() {
                  _inputText = newCache!.name;
                  _controller.text = _inputText;
                });
                await widget._onEditName();
                FocusScope.of(context).unfocus();
              },
            )
          : GestureDetector(
              onSecondaryTap: _toggleEditMode,
              child: Text(_inputText),
            ),
      selected: widget._selected,
      onTap: widget._onTap,
    );
  }
}
