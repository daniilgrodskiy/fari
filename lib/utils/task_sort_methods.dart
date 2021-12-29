import '../app/models/task.dart';

class TaskSortMethods {
  // Methods to sort tasks

  static int dateCreation(Task task1, Task task2) =>
      task1.id.toLowerCase().compareTo(task2.id.toLowerCase()) == 1 ? -1 : 1;

  static int alphabetically(Task task1, Task task2) =>
      task1.name.toLowerCase().compareTo(task2.name.toLowerCase());

  static int category(Task task1, Task task2) {
    if (task1.categoryId != null && task2.categoryId != null) {
      // Both have a category
      return task1.categoryId
          .toLowerCase()
          .compareTo(task2.categoryId.toLowerCase());
    }

    if (task1.categoryId == null && task2.categoryId == null) {
      // Neither have a category, so just sort by date created
      return dateCreation(task1, task2);
    }
    // At least one task has a category
    if (task1.categoryId == null) {
      // task1 has no category so return task2
      return 1;
    } else {
      return -1;
    }
  }

  static int dueDate(Task task1, Task task2) {
    if (task1.day != null && task2.day != null) {
      // Both tasks have a date
      if (task1.day.year == task2.day.year &&
          task1.day.month == task2.day.month &&
          task1.day.day == task2.day.day) {
        // Both share the same day, so check to make sure both have a time
        if (task1.time != null && task2.time != null) {
          // Both have time, so sort by it and return opposite
          return task1.time.compareTo(task2.time) == 1 ? -1 : 1;
        } else {
          // One task does NOT have a time; put the general tasks on top
          if (task1.time == null) {
            return -1;
          } else {
            // Since task1 does not have a time, we want it to be returned SECOND
            return 1;
          }
        }
      }
      // You can just sort by day because they have different days
      return task1.day.compareTo(task2.day) == 1 ? -1 : 1;
    } else {
      // At least one task does not have a date
      if (task1.day == null) {
        if (task2.day == null) {
          // Both tasks don't have a day, so sort by their creation date (id)
          return task1.id.compareTo(task2.id) == 1 ? -1 : 1;
        }
        return -1;
      }
      return 1;
    }
  }
}
