import 'package:flutter/material.dart';

class ICNavigationBarButton extends StatelessWidget {
  final String title;
  final String? cacheid;
  final IconData icon;
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
    return ClipRect(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: SizedBox.expand(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              spacing: 8,
              children: [
                const SizedBox(width: 4),
                Icon(
                  icon,
                  color: (selected)
                      ? Theme.of(buildContext).colorScheme.surfaceTint
                      : Theme.of(buildContext).colorScheme.onSurfaceVariant,
                ),
                (collapsed)
                    ? const SizedBox.shrink()
                    : Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: (selected)
                              ? Theme.of(buildContext).colorScheme.surfaceTint
                              : Theme.of(
                                  buildContext,
                                ).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
