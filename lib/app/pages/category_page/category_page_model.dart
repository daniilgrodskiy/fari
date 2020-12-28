import 'package:fari/app/custom_widgets/common_widgets/sort_tasks_bottom_sheet.dart';
import 'package:flutter/foundation.dart';

class CategoryPageModel extends ChangeNotifier {
  CategoryPageModel({
    this.search = "",
    this.sortType = SortType.DueDate,
  });
  
  String search;
  SortType sortType;

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