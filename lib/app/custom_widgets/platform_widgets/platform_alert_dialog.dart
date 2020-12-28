import 'dart:io';
import 'package:fari/app/custom_widgets/platform_widgets/platform_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformAlertDialog extends PlatformWidget {
  // This is just platform-specific alert dialog WIDGET (emphasize on the 'widget' because at the end of the day this class inherits PlatformWidget, which in turn inherits the StatelessWidget class, meaning that the 'build' exists for these types of classes and that they're all technically widgets)

  PlatformAlertDialog({
    @required this.title, 
    @required this.content, 
    this.cancelActionText,
    @required this.defaultActionText
  })  : assert(title != null),
        assert(content != null),
        assert(defaultActionText != null);

  final String title;
  final String content;
  final String cancelActionText;
  final String defaultActionText;

  Future<bool> show(BuildContext context) async {
    // This is the method that is actually going to go ahead and SHOW these platform-aware dialog widgets
    // 'showDialog' only returns a future bool when it's dismissed

    return Platform.isIOS 
      ? await showCupertinoDialog(
          context: context,
          // The 'this' is in reference to the instantiated object of this class; we are returning an actual widget
          builder: (context) => this,
        )
      : await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => this
        );
  }

  @override
  Widget buildCuptertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    // Always adding the 'okay'/defaultActionText button because it's @required
    actions.add(PlatformAlertDialogAction(
        child: Text(defaultActionText),
        onPressed: () => Navigator.of(context).pop(true)
      )
    );

    if (cancelActionText != null) {
      // We're only adding the 'cancel' button if we actually have some cancelActionText passed into this object
      actions.add(PlatformAlertDialogAction(
          child: Text(cancelActionText),
          onPressed: () => Navigator.of(context).pop(false)
        )
      );
    }

    return actions;
  }
}

class PlatformAlertDialogAction extends PlatformWidget {
  // These are the actual "action" buttons that show up at the bottom of the dialog; they inherit PlatformWidget, which inherits from the StatelessWidget class, so these are WIDGETS that have 'build' method
  PlatformAlertDialogAction({this.child, this.onPressed});

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget buildCuptertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      child: child,
      onPressed: onPressed,
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      onPressed: onPressed,
    );
  }

}