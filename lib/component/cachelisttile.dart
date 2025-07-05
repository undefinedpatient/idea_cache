import 'package:flutter/material.dart';

class ICCacheListTile extends StatelessWidget {
  final String _title;
  final Function() _onTap;
  final bool _selected;
  const ICCacheListTile({
    super.key,
    required String title,
    required Function() onTap,
    required bool selected,
  }) : _title = title,
       _onTap = onTap,
       _selected = selected;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_selected ? Icons.pages : Icons.pages_outlined),
      // trailing: IconButton(
      //   iconSize: 16,
      //   onPressed: () {},
      //   icon: Icon(Icons.edit),
      // ),
      title: Text(_title),
      selected: _selected,
      onTap: _onTap,
    );
  }
}
