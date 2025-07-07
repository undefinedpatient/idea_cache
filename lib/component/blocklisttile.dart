import 'package:flutter/material.dart';

class ICBlockListTile extends StatefulWidget {
  const ICBlockListTile({super.key});
  @override
  State<StatefulWidget> createState() {
    return _ICBlockListTile();
  }
}

class _ICBlockListTile extends State<ICBlockListTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 32, width: 128, child: Text("data"));
  }
}
