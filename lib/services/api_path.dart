// SERVICE ONLY USED BY database.dart
class APIPath {
  // General paths for the API will exist here; will make it easier to access paths immediately; makes the process fairly modular and easier to maintain
  // You can now see every API path possible!

  // Task path
  static String task(String uid, String taskId) => 'users/$uid/tasks/$taskId';

  // Tasks path
  static String tasks(String uid) => 'users/$uid/tasks';

  // Category path
  static String category(String uid, String categoryId) =>
      'users/$uid/categories/$categoryId';

  // Categories path
  static String categories(String uid) => 'users/$uid/categories';

  // Reminder path
  static String reminder(String taskId) => 'reminders/$taskId';

  // Reminders path
  static String reminders() => 'reminders/';
}
