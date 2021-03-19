import 'package:flutter/material.dart';

class LauncherIcon extends StatelessWidget {
  dynamic _icon;
  final String label;
  final void Function() onPressed;

  LauncherIcon({this.label, @required dynamic icon, @required this.onPressed}) {
    if (icon is ImageProvider)
      this._icon = ImageIcon(icon, size: 48);
    else if (icon is IconData)
      this._icon = Icon(icon, size: 48);
    else
      throw new Exception('Invalid image type');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      IconButton(icon: this._icon, onPressed: this.onPressed)
    ];
    if (this.label != null) {
      children
          .add(Text(this.label, style: Theme.of(context).textTheme.bodyText2));
    }
    return Align(
        alignment: Alignment.center,
        child: Column(
          children: children,
        ));
  }
}
