import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class ToggleFieldButton extends StatelessWidget {
  ToggleFieldButton(this.isEnabled, this.onTap);

  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.0),
        // margin: EdgeInsets.only(left: 10.0, bottom: 15.0),
        decoration: BoxDecoration(
          color: Colors.indigo[400],
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: AnimatedRotation(
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 200),
          turns: isEnabled ? 0.25 : 0.0,
          child: Icon(
            FontAwesomeIcons.chevronRight,
            size: 10,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
