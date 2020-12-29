import 'package:fari/app/hex_color.dart';
import 'package:fari/app/models/category.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryWidget extends StatelessWidget {
  CategoryWidget(
      {@required this.category, @required this.tasksPerCategory, this.onTap});

  final Category category;
  final Map<String, int> tasksPerCategory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130.0,
        decoration: BoxDecoration(
          color: HexColor(category.color),
          border: Border.all(color: HexColor(category.color).withAlpha(150)),
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: HexColor(category.color),
              offset: Offset(0.0, 10.0),
              blurRadius: 15.0,
              spreadRadius: -10.0,
            ),
          ],
        ),
        margin: EdgeInsets.only(left: 20.0, bottom: 20.0),
        child: Stack(
          children: <Widget>[
            Wrap(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          // color: HexColor(category.color),
                          // color: Colors.black.withAlpha(200),
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 15.0,
                        ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 10.0,
              left: 10.0,
              child: Text(
                (tasksPerCategory[category.id] ?? "No").toString() +
                    (tasksPerCategory[category.id] != null &&
                            tasksPerCategory[category.id] == 1
                        ? " task"
                        : " tasks"),
                style: Theme.of(context).textTheme.headline6.copyWith(
                      // color: HexColor(category.color),
                      // color: Colors.black.withAlpha(200),
                      color: Colors.white.withAlpha(220),
                      fontWeight: FontWeight.w300,
                      fontSize: 10.0,
                    ),
              ),
            ),
            // If the category is selected inside of 'EditTaskPage(...)'
          ],
        ),
      ),
    );
  }
}
