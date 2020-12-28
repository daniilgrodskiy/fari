import 'package:fari/app/custom_widgets/common_widgets/sort_tasks_bottom_sheet.dart';
import 'package:flutter/foundation.dart';

class TasksPageModel extends ChangeNotifier {
  TasksPageModel({
    this.search = "",
    this.sortType = SortType.DueDate,
    this.selectedCategories = const [], // Have to add this 'const' keyword
  });
  
  String search;
  SortType sortType;
  List<String> selectedCategories;

  /// Convenient methods
  
  void updateSearch(String search) => updateWith(search: search);

  void updateSortType(SortType sortType) => updateWith(sortType: sortType);
  
  /// Updates the model object
  void updateWith({
    String search,
    SortType sortType,
  }) {
      this.search = search ?? this.search;
      this.sortType = sortType ?? this.sortType;
      notifyListeners();
  }
}