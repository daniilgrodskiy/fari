import 'package:fari/app/custom_widgets/calendar/custom_calendar_carousel.dart';
import 'package:fari/app/models/task.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'edit_task_page_model.dart';

class DateSection extends StatelessWidget {

  DateSection({
    @required this.model,
  });

  final EditTaskPageModel model;

  final dayFontSize = 15.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            offset: Offset(0.0, 10.0),
            blurRadius: 20.0,
            spreadRadius: -5.0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      height: 450.0,
      child: _buildCalendar(context)
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return CustomCalendarCarousel<Task>(
      selectedDateTime: model.day,
      onDayPressed: (day, tasksList) {
        model.updateDay(day);
      },
      onDayLongPressed: (day) {},
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      weekDayFormat: CustomWeekdayFormat.narrow,
      // Colors
      selectedDayBorderColor: Colors.transparent,
      todayBorderColor: Colors.transparent,
      selectedDayButtonColor: Colors.indigo[400],
      todayButtonColor: Colors.red[400],
      // Styles
      headerTextStyle: Theme.of(context).textTheme.headline6.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 35.0,
      ),
      weekdayTextStyle: Theme.of(context).textTheme.headline6.copyWith(
        color: Colors.black.withAlpha(150),
        fontWeight: FontWeight.w800,
        fontSize: dayFontSize
      ),
      daysTextStyle: Theme.of(context).textTheme.headline6.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: dayFontSize
      ),
      weekendTextStyle: Theme.of(context).textTheme.headline6.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: dayFontSize
      ),
      inactiveDaysTextStyle: Theme.of(context).textTheme.headline6.copyWith(
        color: Colors.black,
        fontSize: dayFontSize
      ),
      selectedDayTextStyle: Theme.of(context).textTheme.headline6.copyWith(
        color: Colors.white,
        fontSize: dayFontSize
      ),
      prevDaysTextStyle: Theme.of(context).textTheme.headline6.copyWith(
        color: Colors.black26,
        fontWeight: FontWeight.w300,
        fontSize: dayFontSize
      ),
      nextDaysTextStyle: Theme.of(context).textTheme.headline6.copyWith(
        color: Colors.black26,
        fontSize: dayFontSize,
      ),
      todayTextStyle: Theme.of(context).textTheme.headline6.copyWith(
        color: Colors.white,
        fontSize: dayFontSize
      ),
      // Buttons
      leftButtonIcon: _buildTopButton(FontAwesomeIcons.arrowLeft),
      rightButtonIcon: _buildTopButton(FontAwesomeIcons.arrowRight),
    );
  }

  Widget _buildTopButton(IconData icon) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.indigo[400],
        // shape: BoxShape.circle,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Icon(icon, color: Colors.white, size: 15.0,),
    );
  }
}