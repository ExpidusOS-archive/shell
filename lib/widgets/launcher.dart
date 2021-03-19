import 'package:flutter/material.dart';

class LauncherIcon extends StatelessWidget {
  final ImageProvider icon;
  final String label;
  final void Function() onPressed;

  LauncherIcon({this.label, @required this.icon, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      IconButton(icon: ImageIcon(this.icon), onPressed: this.onPressed)
    ];
    if (this.label != null) {
      children.add(Text(this.label));
    }
    return Column(
      children: children,
    );
  }
}
