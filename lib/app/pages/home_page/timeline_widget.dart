import 'package:fari/utils/useful_time_methods.dart';
import 'package:fari/app/pages/home_page/home_page_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineWidget extends StatelessWidget {
  TimelineWidget({
    @required this.currentDate,
    @required this.model,
    @required this.tasksPerDay,
    @required this.onTap,
  });

  final DateTime currentDate;
  final HomePageModel model;
  final Map<DateTime, int> tasksPerDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        model.updateSelectedDate(currentDate);
        onTap();
      },
      child: AnimatedContainer(
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
        width: 50.0,
        decoration: BoxDecoration(
          color: isSameDay(currentDate, model.selectedDate)
              ? Colors.indigo[400]
              : isToday(currentDate)
                  ? Colors.blueGrey[50]
                  : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: isSameDay(currentDate, model.selectedDate)
                  ? Colors.transparent
                  : Colors.black.withAlpha(10)),
        ),
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Text(DateFormat.MMMM().format(currentDate).substring(0, 3),
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: isSameDay(currentDate, model.selectedDate)
                            ? Colors.white
                            : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.0,
                      )),
              Text(
                DateFormat.d().format(currentDate),
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: isSameDay(currentDate, model.selectedDate)
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                    ),
              ),
              Text(
                DateFormat.EEEE().format(currentDate).substring(0, 3),
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: isSameDay(currentDate, model.selectedDate)
                          ? Colors.white
                          : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.0,
                    ),
              ),
              SizedBox(
                height: 5.0,
              ),
              tasksPerDay[DateTime(currentDate.year, currentDate.month,
                          currentDate.day)] !=
                      null
                  ? Container(
                      height: 5.0,
                      width: 5.0,
                      decoration: BoxDecoration(
                        color: Colors.indigo[900],
                        shape: BoxShape.circle,
                      ),
                      // child: Center(
                      //   child: Text(
                      //     tasksPerDay[DateTime(currentDate.year, currentDate.month, currentDate.day)].toString() + "2",
                      //     style: Theme.of(context).textTheme.headline6.copyWith(
                      //       color: Colors.white,
                      //       fontSize: 10.0,
                      //       fontWeight: FontWeight.w800,
                      //     )
                      //   ),
                      // ),
                    )
                  : Container(
                      height: 5.0,
                      width: 5.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
