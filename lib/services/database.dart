import 'dart:async';
import 'package:fari/app/models/reminder.dart';
import 'package:fari/app/models/task.dart';
import 'package:fari/app/models/category.dart';
import 'package:fari/services/api_path.dart';
import 'package:meta/meta.dart'; // TODO: I want to use 'foundation.dart', but a Category class already exists in there!
import 'firestore_service.dart';

// PROVIDER USED BY CERTAIN WIDGETS IN THE APP
abstract class Database {
  // Task
  Future<void> setTask(Task task);
  Future<void> deleteTask(Task task);
  Stream<List<Task>> tasksStream({String categoryId, String search});
  Stream<Task> taskStream({String taskId});

  // Category
  Future<void> setCategory(Category category);
  Future<void> deleteCategory(Category category);
  Stream<List<Category>> categoriesStream();
  Stream<Category> categoryStream({String categoryId});

  // Reminder
  Future<void> setReminder({Reminder reminder, String status});
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);

  final String uid;

  final _service = FirestoreService.instance;

  // TASK METHODS
  @override
  Stream<Task> taskStream({@required String taskId}) {
    // Might not be clear that we want type 'String' and NOT category, so we're gonna make it a named, but REQUIRED parameter

    // TODO: Might want to combine streams!
    return _service.documentStream(
        path: APIPath.task(uid, taskId),
        builder: (data, documentId) => Task.fromMap(data, documentId));
  }

  @override
  Stream<List<Task>> tasksStream({String categoryId, String search}) =>
      _service.collectionStream(
        queryBuilder: categoryId != null
            ? (query) => query.where('categoryId', isEqualTo: categoryId)
            : null,
        path: APIPath.tasks(uid),
        builder: (data, documentId) => Task.fromMap(data, documentId),
      );

  @override
  Future<void> setTask(Task task) async => await _service.setData(
        path: APIPath.task(uid, task.id),
        data: task.toMap(),
        // TODO: If task.hasReminder, add it to 'reminders'
        // TODO: Check and compare old value of 'hasReminder'
        // -> find old and
        //  -> if not found then add new reminder cron job
        //  -> if found, then edit it to either say 'cancelled' or delete it altogether
      );

  @override
  Future<void> deleteTask(Task task) async {
    await _service.deleteData(path: APIPath.task(uid, task.id));

    // Delete any reminders with that task too
    try {
        // See if the reminder actually exists (might have been already deleted)
        await _service.deleteData(
          path: APIPath.reminder(task.id),
        );
      } catch (e) {
        print(e);
      }

  }

  // CATEGORY METHODS
  @override
  Stream<Category> categoryStream({@required String categoryId}) =>
      // Might not be clear that we want type 'String' and NOT category, so we're gonna make it a named, but REQUIRED parameter
      _service.documentStream(
          path: APIPath.category(uid, categoryId),
          builder: (data, documentId) => Category.fromMap(data, documentId));

  @override
  Stream<List<Category>> categoriesStream() => _service.collectionStream(
        path: APIPath.categories(uid),
        builder: (data, documentId) => Category.fromMap(data, documentId),
      );

  @override
  Future<void> setCategory(Category category) async => await _service.setData(
        path: APIPath.category(uid, category.id),
        data: category.toMap(),
      );

  @override
  Future<void> deleteCategory(Category category) async {
    // Delete category but also delete all delete the 'categoryId' property off any task that referenced this category!
    // Get all tasks
    final tasksList = await tasksStream(categoryId: category.id).first;

    // Change the 'categoryId' property to be null (we're handling this null value and not actually sending it to the db because of the '.toMap()' method I created inside of 'task.dart') :)
    for (Task task in tasksList) {
      // Go through all the categories and delete the 'categoryId' property

      // Making new task to replace old one
      // TODO: Maybe create a '.copyWith()' method?
      Task newTask = new Task(
        id: task.id,
        name: task.name,
        description: task.description,
        hasReminder: task.hasReminder,
        categoryId: null,
      );
      await setTask(newTask);
    }

    // Delete category itself
    await _service.deleteData(path: APIPath.category(uid, category.id));
  }

  @override
  Future<void> setReminder({Reminder reminder, String status}) async {
    if (status == "cancelled") {
      // reminder = new Reminder(
      //   id: reminder.id,
      //   performAt: reminder.performAt,
      //   status: "cancelled",
      //   taskName: reminder.taskName,
      //   token: reminder.token,
      // );

      // Delete the reminder from the db.
      try {
        // See if the reminder actually exists (might have been already deleted)
        await _service.deleteData(
          path: APIPath.reminder(reminder.id),
        );
      } catch (e) {
        print(e);
      }

      return;
    }

    try {
      await _service.setData(
        path: APIPath.reminder(reminder.id),
        data: reminder.toMap(),
      );
    } catch (e) {
      print(e);
    }
  }
}
