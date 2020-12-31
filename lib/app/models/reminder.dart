import 'package:flutter/foundation.dart';

class Reminder {
  Reminder({
    @required this.id,
    @required this.performAt,
    @required this.status,
    @required this.taskName,
    @required this.token,
  });

  final String id;
  final DateTime performAt;
  final String status;
  final String taskName;
  final String token;

  // When connecting to a db, this is the format that the data comes back in
  factory Reminder.fromMap(Map<dynamic, dynamic> dataMap, String documentId) {
    return Reminder(
      id: documentId,
      performAt: DateTime.parse(dataMap["performAt"]),
      status: dataMap["status"],
      taskName: dataMap["taskName"],
      token: dataMap["token"],
    );
  }

  // Making a map of the properties so that they can be sent to the db
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // "id": this.id,
      "performAt": this.performAt,
      "worker":
          "sendReminder", // TODO: Change this so that reminders with no time are a bit different ("sendReminderToday")
      "status": this.status,
      "options": {
        "taskName": this.taskName,
        "token": this.token,
        "taskId": this.id,
      }
    };
  }
}
