import 'package:flutter/material.dart';

class ICCacheCard extends StatelessWidget {
  final String name;
  final int numOfBlocks;
  final void Function() onSetPage;
  final TextEditingController _textEditingController = TextEditingController();
  ICCacheCard({
    super.key,
    required this.name,
    required this.numOfBlocks,
    required this.onSetPage,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        leading: Icon(Icons.pages_outlined),
        title: Text(name),
        subtitle: Text("# of Blocks: $numOfBlocks"),
        onTap: onSetPage,
      ),
    );
  }
}
