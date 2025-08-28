
import 'package:flutter/material.dart';

class ICOptionCard<T> extends StatefulWidget {
  final String title;
  final String? description;
  final T initialValue;
  final Map<String, T> options;
  final void Function(T) onChanged;
  const ICOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.initialValue,
    required this.options,
    required this.onChanged,
  });

  @override
  State<ICOptionCard> createState() => _ICOptionCardState<T>();
}

class _ICOptionCardState<T> extends State<ICOptionCard<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraint) {
          return ListTile(
            leading: (constraint.maxWidth < 240)
                ? null
                : Text(
                    widget.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
            trailing: Switch(
              value: value as bool,
              onChanged: (value) {
                setState(() {
                  this.value = value as T;
                });
                widget.onChanged.call(value as T);
              },
            ),
          );
        },
      );
    }
    return LayoutBuilder(
      builder: (context, constraint) {
        return ListTile(
          leading: (constraint.maxWidth < 300)
              ? null
              : Text(
                  widget.title,
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
          trailing: DropdownButton(
            value: value,
            items: widget.options.entries.map((entry) {
              return DropdownMenuItem<T>(
                value: entry.value,
                child: Text(entry.key),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                this.value = value as T;
              });
              widget.onChanged.call(value as T);
            },
          ),
        );
      },
    );
  }
}
