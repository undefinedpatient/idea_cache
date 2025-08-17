import 'package:flutter/material.dart';

class ICNavigationBarButton extends StatelessWidget {
  final String title;
  final String? cacheid;
  final Icon icon;
  final Function() onTap;
  final Function()? onEditName;
  final bool selected;
  final bool collapsed;
  const ICNavigationBarButton({
    super.key,
    required this.title,
    required this.icon,
    this.cacheid,
    required this.onTap,
    this.onEditName,
    required this.selected,
    required this.collapsed,
  });

  @override
  Widget build(BuildContext buildContext) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: SizedBox.expand(
          child: (collapsed)
              ? Center(child: icon)
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  spacing: 8,
                  children: [SizedBox(width: 4), icon, Text(title)],
                ),
        ),
      ),
    );
  }
}
