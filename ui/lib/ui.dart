library polkawallet_ui;

import 'package:flutter/material.dart';

class PageWrapperWithBackground extends StatelessWidget {
  PageWrapperWithBackground(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // fit: StackFit.expand,
      children: <Widget>[
        // Container(
        //   width: double.infinity,
        //   height: double.infinity,
        //   color: Theme.of(context).canvasColor,
        // ),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorDark
            ],
            stops: [0.6, 0.9],
          )),
        ),
        child,
      ],
    );
  }
}
