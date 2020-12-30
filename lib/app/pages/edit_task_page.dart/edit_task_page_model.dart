import 'package:fari/app/models/task.dart';
import 'package:fari/app/pages/edit_task_page.dart/toggle_model.dart';
import 'package:fari/services/database.dart';
import 'package:flutter/material.dart';

class EditTaskPageModel extends ChangeNotifier {
  EditTaskPageModel({
    @required this.database,
    this.id,
    this.name,
    this.description,
    this.categoryId,
    this.day,
    this.time,
    this.isLoading = false,
    this.toggleModel,
    this.isCompleted,
    this.hasReminder,
  });

  // TODO: Figure out if you should consolidate day and time. Might be easier not to because we're treating them as two separate fields essentially. Also handling "all-day" events is easier this way?
  final Database database;
  String id;
  String name;
  String description;
  String categoryId;
  DateTime day;
  DateTime time;
  bool isLoading;
  ToggleModel toggleModel;
  bool isCompleted;
  bool hasReminder;

  /// Convenient methods

  void updateName(String name) => updateWith(name: name);

  void updateDescription(String description) =>
      updateWith(description: description);

  void updateCategoryId(String categoryId) =>
      updateWith(categoryId: categoryId);

  void updateDay(DateTime day) => updateWith(day: day);

  void updateTime(DateTime time) => updateWith(time: time);

  void updateHasReminder(bool hasReminder) =>
      updateWith(hasReminder: hasReminder);

  // ToggleModel methods
  void toggleShowDescription() => updateWith(
      toggleModel:
          new ToggleModel(showDescription: !toggleModel.showDescription));

  void toggleShowCategories() => updateWith(
      toggleModel:
          new ToggleModel(showCategories: !toggleModel.showCategories));

  void toggleShowDay() =>
      updateWith(toggleModel: new ToggleModel(showDay: !toggleModel.showDay));

  void toggleShowTime() =>
      updateWith(toggleModel: new ToggleModel(showTime: !toggleModel.showTime));

  /// BLoC methods

  Future<void> submit() async {
    updateWith(isLoading: true);
    print("Try");

    try {
      id = id ?? documentIdFromCurrentDate();

      // TODO: Go on dribble and just look at a bunch of designs for date and time pickers lol because right now this is all janky!

      // Convert 'day' into only year, month, and day
      day = new DateTime(day.year, day.month, day.day, 0, 0);

      // Convert 'time' into only hours and minutes
      time = new DateTime(0, 0, 0, time.hour, time.minute);

      // Check to make sure it's enabled via ToggleModel's properties, THEN check to see that it's not null or empty!
      Task savedTask = new Task(
          id: id,
          name: name,
          description: toggleModel.showDescription
              ? (description == null || description == "" ? null : description)
              : null,
          categoryId: toggleModel.showCategories
              ? (categoryId == null || categoryId == "" ? null : categoryId)
              : null,
          // Doing this just in case we type something and delete it after; we don't want to save an an empty ("") categoryId or description into the database
          day: toggleModel.showDay ? (day == null ? null : day) : null,
          time: toggleModel.showTime ? (time == null ? null : time) : null,
          isCompleted: isCompleted,
          hasReminder: hasReminder);

      /// DEBUGGING:
      // await Future.delayed(Duration(seconds: 3));
      // throw new PlatformException(code: "Test", message: "Really testing only!");
      await database.setTask(savedTask);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(Task task) async {
    updateWith(isLoading: true);
    try {
      await database.deleteTask(task);
    } catch (e) {
      rethrow;
    }
  }

  // Updates the model object
  void updateWith(
      {String name,
      String description,
      String categoryId,
      DateTime day,
      DateTime time,
      bool isLoading,
      ToggleModel toggleModel,
      bool isCompleted,
      bool hasReminder}) {
    this.name = name ?? this.name;
    this.description = description ?? this.description;
    this.categoryId = categoryId ?? this.categoryId;
    this.day = day ?? this.day;
    this.time = time ?? this.time;
    this.isLoading = isLoading ?? this.isLoading;
    this.toggleModel.update(newToggleModel: toggleModel ?? new ToggleModel());
    this.isCompleted = isCompleted ?? this.isCompleted;
    this.hasReminder = hasReminder ?? this.hasReminder;

    // VERY IMPORTANT! This is what tells the ChangeNotifierProvider(...) to actually rebuild the widget tree!
    notifyListeners();
  }
}
