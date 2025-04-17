import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/controller/viewsController.dart';

// ignore: must_be_immutable
class FooterScreens extends StatefulWidget {
  ViewsController views;
  TextTheme textTheme;
  ColorScheme colorScheme;
  FooterScreens({required this.views, required this.textTheme, required this.colorScheme});

  @override
  State<FooterScreens> createState() => _FooterScreensState();
}

class _FooterScreensState extends State<FooterScreens> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showUnselectedLabels: false,
      items: widget.views.carregaBottomBar(),
      currentIndex: ViewsController.instance.viewId,
      // currentIndex: 1,
      onTap: (idx) {
        setState(() {
          // ViewsController.instance.viewId = idx;
          widget.views.carregaViews(context, idx);
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedFontSize: widget.textTheme.bodySmall?.fontSize ?? 0,
      unselectedFontSize: widget.textTheme.bodySmall?.fontSize ?? 0,
      selectedItemColor: widget.colorScheme.onPrimary,
      unselectedItemColor: widget.colorScheme.onPrimary.withOpacity(0.38),
      backgroundColor: widget.colorScheme.primary,
    );
  }
}
