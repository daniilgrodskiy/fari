import 'package:fari/app/custom_widgets/calendar/custom_calendar_carousel.dart';
import 'package:flutter/material.dart';
import 'custom_default_styles.dart'
    show defaultWeekdayTextStyle;
import 'package:intl/intl.dart';

class CustomWeekdayRow extends StatelessWidget {
  CustomWeekdayRow(
      this.firstDayOfWeek,
      this.customWeekdayBuilder,
      {@required this.showWeekdays,
      @required this.weekdayFormat,
      @required this.weekdayMargin,
      @required this.weekdayPadding,
      @required this.weekdayBackgroundColor,
      @required this.weekdayTextStyle,
      @required this.localeDate});

  final WeekdayBuilder customWeekdayBuilder;
  final bool showWeekdays;
  final CustomWeekdayFormat weekdayFormat;
  final EdgeInsets weekdayMargin;
  final EdgeInsets weekdayPadding;
  final Color weekdayBackgroundColor;
  final TextStyle weekdayTextStyle;
  final DateFormat localeDate;
  final int firstDayOfWeek;

  Widget _weekdayContainer(int weekday, String weekDayName) {
    return customWeekdayBuilder != null ? customWeekdayBuilder(weekday, weekDayName) :
    Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: weekdayBackgroundColor),
            color: weekdayBackgroundColor,
          ),
          margin: weekdayMargin,
          padding: weekdayPadding,
          child: Center(
            child: DefaultTextStyle(
              style: defaultWeekdayTextStyle,
              child: Text(
                weekDayName,
                semanticsLabel: weekDayName,
                style: weekdayTextStyle,
              ),
            ),
          ),
        )
    );
  }

//  List<Widget> _generateWeekdays() {
//    switch (CustomWeekdayFormat) {
//      case CustomWeekdayFormat.weekdays:
//        return localeDate.dateSymbols.WEEKDAYS
//            .map<Widget>(_weekdayContainer)
//            .toList();
//      case CustomWeekdayFormat.standalone:
//        return localeDate.dateSymbols.STANDALONEWEEKDAYS
//            .map<Widget>(_weekdayContainer)
//            .toList();
//      case CustomWeekdayFormat.short:
//        return localeDate.dateSymbols.SHORTWEEKDAYS
//            .map<Widget>(_weekdayContainer)
//            .toList();
//      case CustomWeekdayFormat.standaloneShort:
//        return localeDate.dateSymbols.STANDALONESHORTWEEKDAYS
//            .map<Widget>(_weekdayContainer)
//            .toList();
//      case CustomWeekdayFormat.narrow:
//        return localeDate.dateSymbols.NARROWWEEKDAYS
//            .map<Widget>(_weekdayContainer)
//            .toList();
//      case CustomWeekdayFormat.standaloneNarrow:
//        return localeDate.dateSymbols.STANDALONENARROWWEEKDAYS
//            .map<Widget>(_weekdayContainer)
//            .toList();
//      default:
//        return localeDate.dateSymbols.STANDALONEWEEKDAYS
//            .map<Widget>(_weekdayContainer)
//            .toList();
//    }
//  }

  // TODO - locale issues
  List<Widget> _renderWeekDays() {
    List<Widget> list = [];

    /// because of number of days in a week is 7, so it would be easier to count it til 7.
    for (var i = firstDayOfWeek, count = 0;
    count < 7;
    i = (i + 1) % 7, count++) {
      String weekDay;

      switch (weekdayFormat) {
        case CustomWeekdayFormat.weekdays:
          weekDay = localeDate.dateSymbols.WEEKDAYS[i];
          break;
        case CustomWeekdayFormat.standalone:
          weekDay = localeDate.dateSymbols.STANDALONEWEEKDAYS[i];
          break;
        case CustomWeekdayFormat.short:
          weekDay = localeDate.dateSymbols.SHORTWEEKDAYS[i];
          break;
        case CustomWeekdayFormat.standaloneShort:
          weekDay = localeDate.dateSymbols.STANDALONESHORTWEEKDAYS[i];
          break;
        case CustomWeekdayFormat.narrow:
          weekDay = localeDate.dateSymbols.NARROWWEEKDAYS[i];
          break;
        case CustomWeekdayFormat.standaloneNarrow:
          weekDay = localeDate.dateSymbols.STANDALONENARROWWEEKDAYS[i];
          break;
        default:
          weekDay = localeDate.dateSymbols.STANDALONEWEEKDAYS[i];
          break;
      }
      list.add(_weekdayContainer(count, weekDay));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) => showWeekdays
      ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _renderWeekDays(),
        )
      : Container();
}
