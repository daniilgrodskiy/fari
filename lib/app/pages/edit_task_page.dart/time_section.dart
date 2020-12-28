import 'package:fari/app/pages/edit_task_page.dart/edit_task_page_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class TimeSection extends StatelessWidget {

  TimeSection({
    @required this.model,
  });

  final EditTaskPageModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          // alignment: Alignment.centerLeft,
          // width: 100.0,
          margin: EdgeInsets.only(left: 20.0),
          padding: EdgeInsets.only(left: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                offset: Offset(0.0, 10.0),
                blurRadius: 5.0,
                spreadRadius: -5.0
              ),
            ]
          ),
          child: new TimePickerSpinner(
            time: model.time,
            alignment: Alignment.centerLeft,
            isForce2Digits: true,
            minutesInterval: 5,
            is24HourMode: false,
            normalTextStyle: Theme.of(context).textTheme.headline6.copyWith(
              color: Colors.black.withAlpha(100),
              fontWeight: FontWeight.w500,
              fontSize: 15.0
            ),
            highlightedTextStyle: Theme.of(context).textTheme.headline6.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 20.0
            ),
            spacing: 30.0,
            itemHeight: 40.0,
            onTimeChange: model.updateTime
          ),
        ),
      ],
    );
  }
}