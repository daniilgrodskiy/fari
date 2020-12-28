import 'dart:io';
import 'package:flutter/material.dart';

abstract class PlatformWidget extends StatelessWidget {
  // Any subclass that inherits PlatformWidget will need to have its own buildCupertinoWidget and buildMaterialWidget methods!
  Widget buildCuptertinoWidget(BuildContext context);
  Widget buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return buildCuptertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }
}