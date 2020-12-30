import 'package:flutter/material.dart';

class ToggleFieldButton extends StatelessWidget {
  ToggleFieldButton(
      this.isEnabled, this.onTap, this.enabledText, this.disabledText);

  final bool isEnabled;
  final VoidCallback onTap;
  final String enabledText;
  final String disabledText;

  /// build method

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        margin: EdgeInsets.only(left: 10.0, bottom: 15.0),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.red[400] : Colors.green[400],
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          isEnabled ? enabledText : disabledText,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.white, fontSize: 10.0),
        ),
      ),
    );
  }
}
