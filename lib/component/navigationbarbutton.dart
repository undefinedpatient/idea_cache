import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/cachemodel.dart';
import 'package:provider/provider.dart';

class ICNavigationBarButton extends StatefulWidget {
  final String title;
  final Cache? cache;
  final IconData icon;
  final Function() onTap;
  final bool enableEdit;
  final bool selected;
  final bool collapsed;
  const ICNavigationBarButton({
    super.key,
    required this.title,
    this.cache,
    required this.icon,
    required this.onTap,
    required this.enableEdit,
    required this.selected,
    required this.collapsed,
  });

  @override
  State<ICNavigationBarButton> createState() => _ICNavigationBarButtonState();
}

class _ICNavigationBarButtonState extends State<ICNavigationBarButton> {
  bool isEditing = false;
  final TextEditingController _textEditingController = TextEditingController();
  late final FocusNode _focusNode;
  void _enterEditMode() {
    if (widget.enableEdit) {
      setState(() {
        isEditing = true;
      });
      // Request focus after entering edit mode
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void _exitEditMode() {
    widget.cache!.name = _textEditingController.text;
    setState(() {
      isEditing = false;
    });
  }

  Widget _editableTitle(BuildContext ctx) {
    if (!isEditing) {
      return GestureDetector(
        onSecondaryTap: () {
          _enterEditMode();
        },
        child: Text(
          _textEditingController.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: (widget.selected)
                ? Theme.of(ctx).colorScheme.surfaceTint
                : Theme.of(ctx).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      return Consumer<ICCacheModel>(
        builder: (context, model, child) {
          return Expanded(
            child: TextField(
              onSubmitted: (value) {
                _exitEditMode();
                Cache cache = widget.cache!;
                cache.name = _textEditingController.text;
                model.updateCache(cache);
              },
              focusNode: _focusNode,
              controller: _textEditingController,
              maxLines: 1,
              style: TextStyle(
                color: (widget.selected)
                    ? Theme.of(ctx).colorScheme.surfaceTint
                    : Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && isEditing) {
        setState(() {
          isEditing = false;
        });
      }
    });
    if (widget.cache != null) {
      _textEditingController.text = widget.cache!.name;
    } else {
      _textEditingController.text = widget.title;
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    if (widget.collapsed) {
      return ClipRect(
        child: InkWell(
          onTap: widget.onTap,
          child: SizedBox(
            height: 48,
            child: SizedBox.expand(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                spacing: 8,
                children: [
                  const SizedBox(width: 4),
                  Icon(
                    widget.icon,
                    color: (widget.selected)
                        ? Theme.of(buildContext).colorScheme.surfaceTint
                        : Theme.of(buildContext).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return ClipRect(
        child: InkWell(
          onTap: widget.onTap,
          child: SizedBox(
            height: 48,
            child: SizedBox.expand(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                spacing: 8,
                children: [
                  const SizedBox(width: 4),
                  Icon(
                    widget.icon,
                    color: (widget.selected)
                        ? Theme.of(buildContext).colorScheme.surfaceTint
                        : Theme.of(buildContext).colorScheme.onSurfaceVariant,
                  ),
                  _editableTitle(context),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
