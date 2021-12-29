import 'package:fari/utils/hex_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

class Task implements EventInterface {
  Task(
      {@required this.id,
      @required this.name,
      this.categoryId,
      this.description,
      this.day,
      this.time,
      this.isCompleted,
      this.hasReminder});

  final String id;
  final String name;
  final String categoryId;
  final String description;
  final DateTime day;
  final DateTime time;
  final bool isCompleted;
  final bool hasReminder;

  // When connecting to a db, this is the format that the data comes back in
  factory Task.fromMap(Map<dynamic, dynamic> dataMap, String documentId) {
    return Task(
      id: documentId,
      name: dataMap["name"],
      description: dataMap["description"],
      categoryId: dataMap["categoryId"],
      // day: dataMap["day"] ?? DateTime.now(),
      // Making sure that we aren't calling a method (DateTime.parse) on a null object
      day: dataMap["day"] != null ? DateTime.parse(dataMap["day"]) : null,
      time: dataMap["time"] != null ? DateTime.parse(dataMap["time"]) : null,
      isCompleted: dataMap["isCompleted"] ?? false,
      hasReminder: dataMap["hasReminder"] ?? false,
    );
  }

  // Making a map of the properties so that they can be sent to the db
  Map<String, dynamic> toMap() {
    Map<String, dynamic> dataMap = {
      "name": name, // Should ALWAYS be non-null
    };

    // Need to make sure that both any properties are NOT empty or null; we're only adding them to the dataMap if they have an actual value
    if (this.description != "" && this.description != null) {
      dataMap.update("description", (value) => {value = this.description},
          ifAbsent: () => this.description);
    }

    if (this.categoryId != "" && this.categoryId != null) {
      dataMap.update("categoryId", (value) => {value = this.categoryId},
          ifAbsent: () => this.categoryId);
    }

    // Converting to ISO 8601 standard before adding to database
    if (this.day != null) {
      dataMap.update("day", (value) => {value = this.day.toIso8601String()},
          ifAbsent: () => this.day.toIso8601String());
    }

    if (this.time != null) {
      dataMap.update("time", (value) => {value = this.time.toIso8601String()},
          ifAbsent: () => this.time.toIso8601String());
    }

    if (this.isCompleted != null) {
      dataMap.update("isCompleted", (value) => {value = this.isCompleted},
          ifAbsent: () => this.isCompleted);
    }

    if (this.hasReminder != null) {
      dataMap.update("hasReminder", (value) => {value = this.hasReminder},
          ifAbsent: () => this.hasReminder);
    }
    
    return dataMap;
  }

  /// EventInterface methods (needed for the calendar)
  @override
  DateTime getDate() {
    return this.day ?? null;
  }

  @override
  Widget getDot() {
    return new Container(
      height: 5.0,
      width: 5.0,
      decoration: BoxDecoration(
          // TODO: Maybe incorporate the category color somewhere in the category document id? Lol, this'll let us use it for the calendar at least.
          // color: categoryId != null ? HexColor(categoryId) : Colors.yellow[500],
          color: Colors.yellow[500],
          shape: BoxShape.circle),
    );
  }

  @override
  Widget getIcon() {
    // TODO: implement getIcon
    throw UnimplementedError();
  }

  @override
  String getTitle() {
    // TODO: implement getTitle
    throw UnimplementedError();
  }
}
