import 'package:flutter/material.dart';
import 'custom_default_styles.dart' show defaultHeaderTextStyle;

class CustomCalendarHeader extends StatelessWidget {
  /// Passing in values for [leftButtonIcon] or [rightButtonIcon] will override [headerIconColor]
  CustomCalendarHeader(
      {@required this.headerTitle,
      this.headerMargin,
      this.showHeader,
      this.headerTextStyle,
      this.showHeaderButtons,
      this.headerIconColor,
      this.leftButtonIcon,
      this.rightButtonIcon,
      @required this.onLeftButtonPressed,
      @required this.onRightButtonPressed,
      this.isTitleTouchable,
      @required this.onHeaderTitlePressed});

  final String headerTitle;
  final EdgeInsetsGeometry headerMargin;
  final bool showHeader;
  final TextStyle headerTextStyle;
  final bool showHeaderButtons;
  final Color headerIconColor;
  final Widget leftButtonIcon;
  final Widget rightButtonIcon;
  final VoidCallback onLeftButtonPressed;
  final VoidCallback onRightButtonPressed;
  final bool isTitleTouchable;
  final VoidCallback onHeaderTitlePressed;

  TextStyle get getTextStyle =>
      headerTextStyle != null ? headerTextStyle : defaultHeaderTextStyle;

  Widget _leftButton() => IconButton(
        onPressed: onLeftButtonPressed,
        icon: leftButtonIcon ?? Icon(Icons.chevron_left, color: headerIconColor),
      );

  Widget _rightButton() => IconButton(
        onPressed: onRightButtonPressed,
        icon: rightButtonIcon ?? Icon(Icons.chevron_right, color: headerIconColor),
      );

  Widget _headerTouchable() => FlatButton(
        onPressed: onHeaderTitlePressed,
        child: Text(headerTitle, 
          semanticsLabel: headerTitle,
          style: getTextStyle,
        ),
      );

  @override
  Widget build(BuildContext context) => showHeader
      ? Container(
          margin: headerMargin,
          child: DefaultTextStyle(
              style: getTextStyle,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    isTitleTouchable
                        ? _headerTouchable()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            Text(
                              headerTitle.split(" ")[1], 
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w100,
                              )
                            ),
                            Text(headerTitle.split(" ")[0], style: getTextStyle)
                          ],
                        ),
                    Spacer(),
                    showHeaderButtons ? _leftButton() : Container(),
                    showHeaderButtons ? _rightButton() : Container(),
                  ])),
        )
      : Container();
}
