import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/app.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/blockmodel.dart';
import 'package:provider/provider.dart';

class ICBlockListTile extends StatefulWidget {
  final bool isSelected;
  final Function() onTap;
  final ICBlock block;
  const ICBlockListTile({
    super.key,
    required this.block,
    required this.onTap,
    required this.isSelected,
  });
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
      _controller.text = widget.block.name;
    });
  }

  @override
  void didUpdateWidget(covariant ICBlockListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _inputText = widget.block.name;
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
        style: MenuItemButton.styleFrom(
          backgroundColor: (widget.isSelected)
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surfaceContainer,
        ),
        onPressed: widget.onTap,
        clipBehavior: Clip.hardEdge,
        requestFocusOnHover: false,
        leadingIcon: Icon(
          (widget.isSelected) ? Icons.square : Icons.square_outlined,
        ),
        child: Consumer<ICBlockModel>(
          builder: (context, model, child) {
            return SizedBox(
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
                        ICBlock? oldBlock = widget.block;
                        oldBlock.name = _inputText;
                        model.updateBlock(oldBlock);
                      },
                    )
                  : GestureDetector(
                      onSecondaryTap: _toggleEditMode,
                      child: Text(
                        widget.block.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
