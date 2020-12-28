import 'package:flutter/foundation.dart';

class Category {
  Category({
    @required this.id,
    @required this.name,
    @required this.color,
  });

  final String id;
  final String name;
  final String color;

  // When connecting to a db, this is the format that the data comes back in
  factory Category.fromMap(Map<dynamic, dynamic> dataMap, String documentId) {
    return Category(
      id: documentId,
      name: dataMap["name"],
      color: dataMap["color"],
    );
  }

  // Making a map of the properties so that they can be sent to the db
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "name" : this.name,
      "color" : this.color
    };
  }
}