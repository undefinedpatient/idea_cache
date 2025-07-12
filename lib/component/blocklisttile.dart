import 'package:flutter/material.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/fileHandler.dart';

class ICBlockListTile extends StatefulWidget {
  final String _name;
  final String _blockid;
  final bool _isSelected;
  final Function() _onTap;
  final Function() _onEditName;
  const ICBlockListTile({
    super.key,
    required String name,
    required String blockid,
    required Function() onTap,
    required Function() onEditName,
    required bool isSelected,
  }) : _name = name,
       _blockid = blockid,
       _onTap = onTap,
       _onEditName = onEditName,
       _isSelected = isSelected;
  @override
  State<StatefulWidget> createState() {
    return _ICBlockListTile();
  }
}

class _ICBlockListTile extends State<ICBlockListTile> {
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
      _inputText = widget._name;
      _controller.text = _inputText;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: MenuItemButton(
        onPressed: widget._onTap,
        style: MenuItemButton.styleFrom(
          backgroundColor: widget._isSelected
              ? Theme.of(context).focusColor
              : Theme.of(context).cardColor,
        ),
        clipBehavior: Clip.hardEdge,
        requestFocusOnHover: false,
        leadingIcon: Icon(Icons.square),
        child: SizedBox(
          width: 120,
          child: _isEditing
              ? TextField(
                  autofocus: true,
                  autocorrect: false,
                  controller: _controller,
                  onTapOutside: (_) {
                    _interruptEditMode();
                    FocusScope.of(context).unfocus();
                  },
                  onSubmitted: (value) async {
                    _toggleEditMode();
                    ICBlock? oldBlock = await FileHandler.findBlockById(
                      widget._blockid,
                    );
                    oldBlock?.name = _inputText;
                    await FileHandler.updateBlock(oldBlock!);

                    // After update the name might be name.001 so need to fetch again
                    ICBlock? updatedBlock = await FileHandler.findBlockById(
                      widget._blockid,
                    );
                    setState(() {
                      _inputText = updatedBlock!.name;
                      _controller.text = _inputText;
                    });
                    await widget._onEditName();
                  },
                )
              : GestureDetector(
                  onSecondaryTap: _toggleEditMode,
                  child: Text(widget._name),
                ),
        ),
      ),
    );
  }
}
