import 'package:fari/app/models/category.dart';
import 'package:fari/services/database.dart';
import 'package:flutter/material.dart';

class EditCategoryPageModel extends ChangeNotifier {
  EditCategoryPageModel({
    @required this.database,
    this.id,
    this.name, 
    this.color = "1abc9c", 
    this.isLoading = false,
  });
  
  final Database database;
  String id;
  String name;
  String color;
  bool isLoading;

  /// Convenient methods
  
  void updateName(String name) => updateWith(name: name);

  void updateColor(String color) => updateWith(color: color);

  /// BLoC methods
  
  Future<void> submit() async {
    updateWith(isLoading: true);
    
    try {
      id = id ?? documentIdFromCurrentDate();
      Category savedCategory = new Category(
        id: id,
        name: name,
        color: color,
      );
      await database.setCategory(savedCategory);
    } catch(e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(Category category) async {
    updateWith(isLoading: true);
    try {
      await database.deleteCategory(category);
    } catch(e) {
      rethrow;
    }
  }

   // Updates the model object
  void updateWith({
    String name,
    String color,
    bool isLoading,
  }) {
      this.name = name ?? this.name;
      this.color = color ?? this.color;
      this.isLoading = isLoading ?? this.isLoading;

      // VERY IMPORTANT! This is what tells the ChangeNotifierProvider(...) to actually rebuild the widget tree!
      notifyListeners();
  }


   
}