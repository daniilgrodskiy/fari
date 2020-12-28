import 'package:flutter/material.dart';

class HomePageModel extends ChangeNotifier {
  HomePageModel({
    @required this.selectedDate,
    @required this.showCategories,
  });
  
  DateTime selectedDate;
  bool showCategories;

  /// Convenient methods
  
  void updateSelectedDate(DateTime selectedDate) => updateWith(selectedDate: selectedDate);
  void updateShowCategories(bool showCategories) => updateWith(showCategories: showCategories);

  /// Updates the model object

  void updateWith({
    DateTime selectedDate,
    bool showCategories,
  }) {
      this.selectedDate = selectedDate ?? this.selectedDate;
      this.showCategories = showCategories ?? this.showCategories;
      notifyListeners();
  }
}