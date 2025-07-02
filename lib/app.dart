import 'package:flutter/material.dart';

class ICApp extends StatelessWidget {
  const ICApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ICMainView());
  }
}

class ICMainView extends StatelessWidget {
  const ICMainView({super.key});
  @override
  Widget build(BuildContext buildContext) {
    final width = MediaQuery.of(buildContext).size.width;
    final height = MediaQuery.of(buildContext).size.height;
    if (width > height) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 320,
          minWidth: 320,
          maxHeight: 640,
        ),
        child: Scaffold(
          appBar: AppBar(title: Text("IdeaCache")),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.add),
          ),
          body: Row(
            children: [
              NavigationRail(
                extended: true,
                minWidth: 96,
                elevation: 4,
                groupAlignment: -1,
                trailing: IconButton(onPressed: () {}, icon: Icon(Icons.add)),
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard),
                    label: Text("Dashboard"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.label),
                    label: Text("Cache00"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.label),
                    label: Text("Cache01"),
                  ),
                ],
                selectedIndex: 0,
              ),
              Placeholder(),
            ],
          ),
        ),
      );
    } else {
      return Placeholder();
    }
  }
}
