bool isToday(DateTime date) {
    return date.year == DateTime.now().year && date.month == DateTime.now().month &&  date.day == DateTime.now().day;
  }

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year && date2.month == date1.month &&  date1.day == date2.day;
}

bool isTomorrow(DateTime date) {
  return date.year == DateTime.now().year && date.month == DateTime.now().month &&  date.day == DateTime.now().day + 1;
}

bool isMissed(DateTime day, DateTime time) {
  if (time == null) {
    // No time, so we compare it to the end of the day
    DateTime date = new DateTime(day.year, day.month, day.day + 1);
    return DateTime.now().isAfter(date);
  }

  DateTime date = new DateTime(day.year, day.month, day.day, time.hour, time.minute);
  return DateTime.now().isAfter(date);
}