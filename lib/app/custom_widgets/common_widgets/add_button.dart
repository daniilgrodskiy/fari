import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class AddButton extends StatefulWidget {
  final VoidCallback onTap;
  
  AddButton({
    this.onTap,
  });

  @override
  _AddButtonState createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  KeyboardVisibilityNotification _keyboardVisibility = new KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId;
  bool _keyboardState;

  @protected
  void initState() {
    super.initState();

    _keyboardState = _keyboardVisibility.isKeyboardVisible;

    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        setState(() {
          _keyboardState = visible;
        });
      },
    );
  }

  @override
  void dispose() {
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10.0,
      // bottom: _keyboardState ? 15 : 110.0,
      bottom: _keyboardState ? 15 : MediaQuery.of(context).padding.bottom,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 60.0,
          width: 60.0,
          decoration: BoxDecoration(
            color: Colors.indigo[400],
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color:Colors.indigo.withAlpha(150),
                offset: Offset(0.0, 5.0),
                blurRadius: 10.0,
                spreadRadius: -2.0,
              ),
            ]
          ),
          child: Icon(FontAwesomeIcons.plus, color: Colors.white,),
        ),
      ),
    );
  }
}