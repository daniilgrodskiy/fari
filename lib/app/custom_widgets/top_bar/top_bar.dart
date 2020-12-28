import 'dart:ui';

import 'package:fari/app/custom_widgets/top_bar/search_bar.dart';
import 'package:fari/app/custom_widgets/top_bar/top_bar_button.dart';
import 'package:fari/app/models/category.dart';
import 'package:fari/app/models/task.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TopBar extends PreferredSize {
  // final ChangeNotifier model;
  final String title;
  final bool hasBackButton;
  final SearchBar searchBar;
  final Category category;
  final TopBarButton leadingButton;
  final List<TopBarButton> actions;

  TopBar({
    this.title,
    this.hasBackButton = false, 
    this.searchBar,  
    this.category,
    this.actions,
    this.leadingButton,
  }) : super(
        child: Container(),
        preferredSize: Size.fromHeight(searchBar == null ? 60.0 : 110.0)
      );

  // Used only as a short, empty top bar inside of EditTaskPage() and EditCategoryPage()
  static PreferredSize empty() {
    return PreferredSize(
      preferredSize: Size.fromHeight(0.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(30),
              offset: Offset(0.0, 3.0),
              blurRadius: 10.0
            )
          ],
        ),
      ),
    );
  }

  static PreferredSize homePage(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(80),
              offset: Offset(0.0, 3.0),
              blurRadius: 10.0
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,          
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(width: 20.0,),
                GestureDetector(
                  onTap: () {
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.indigo[600],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      "Change View",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.white,
                        fontSize: 15.0
                      ),
                    ),
                  ),
                ),
                // GestureDetector(
                //   onTap: () {
                //   },
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                //     decoration: BoxDecoration(
                //       color: Colors.indigo[600],
                //       borderRadius: BorderRadius.circular(5.0),
                //     ),
                //     child: Text(
                //       "Home",
                //       style: Theme.of(context).textTheme.headline6.copyWith(
                //         color: Colors.white,
                //         fontSize: 15.0
                //       ),
                //     ),
                //   ),
                // ),
                // Spacer(),
                // GestureDetector(
                //   onTap: () {
                //   },
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                //     decoration: BoxDecoration(
                //       color: Colors.indigo[400],
                //       borderRadius: BorderRadius.circular(5.0),
                //     ),
                //     child: Text(
                //       "Timeline",
                //       style: Theme.of(context).textTheme.headline6.copyWith(
                //         color: Colors.white,
                //         fontSize: 15.0
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(width: 10.0),
                // GestureDetector(
                //   onTap: () {
                //   },
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                //     decoration: BoxDecoration(
                //       color: Colors.indigo[400],
                //       borderRadius: BorderRadius.circular(5.0),
                //     ),
                //     child: Text(
                //       "Calendar",
                //       style: Theme.of(context).textTheme.headline6.copyWith(
                //         color: Colors.white,
                //         fontSize: 15.0
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(width: 10.0),
              ],
            ),
            SizedBox(height: 10.0,),
          ],
        ),
      ),
    );
  }

  static PreferredSize searchBarOnly(BuildContext context, SearchBar searchBar) {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(30),
              offset: Offset(0.0, 3.0),
              blurRadius: 10.0
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          offset: Offset(0.0, 2.0),
                          blurRadius: 15.0,
                        ),
                      ]
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0,),
                    child: Container(
                      child: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black, size: 15.0,),
                    )
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: searchBar
                ),
                SizedBox(width: 10.0,),
              ],
            ),
            SizedBox(height: 10.0,),
          ],
        )
      ),
    );
  }

  static PreferredSize edit(BuildContext context, VoidCallback submit, Task task) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(30),
              offset: Offset(0.0, 3.0),
              blurRadius: 10.0
            )
          ],
        ),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 10.0),
                  GestureDetector(
                    onTap: () async { 
                        Navigator.pop(context);
                    },
                    child: Container(
                      height: 30.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        // color: Colors.grey.withAlpha(150),
                      ),
                      child: Icon(FontAwesomeIcons.chevronLeft, color: Colors.black, size: 25.0,),
                    ),
                  ),
                  Spacer(),
                  // Delete task
                  if (task != null)
                    GestureDetector(
                      onTap: submit,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo[400].withAlpha(200),
                              offset: Offset(0.0, 5.0),
                              blurRadius: 15.0,
                              spreadRadius: -5.0
                            ),
                          ]
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        child: Center(
                          child: Text(
                            "Delete task",
                            style: Theme.of(context).textTheme.headline6.copyWith(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // child: Icon(FontAwesomeIcons.check, color: Colors.white,),
                      ),
                    ),
                  SizedBox(width: 10.0,),
                  // Create/Save task
                  GestureDetector(
                    onTap: submit,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[400],
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo[400].withAlpha(200),
                            offset: Offset(0.0, 5.0),
                            blurRadius: 15.0,
                            spreadRadius: -5.0
                          ),
                        ]
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      child: Center(
                        child: Text(
                          // If the passed in task is null -> we're creating a task
                          // If the passed in task exists -> we're editing a task
                          task == null ? "Create task" : "Save task",
                          style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      // child: Icon(FontAwesomeIcons.check, color: Colors.white,),
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // 'padding:' is the space between buttons and status bar
      // 'height:' is overriding 'preferrizedSize' property?
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10.0
      ), 
      height: MediaQuery.of(context).padding.top + (searchBar == null ? 60.0 : 110.0),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(20.0),
        // border: Border(
        //   bottom: BorderSide(
        //     color: Colors.black12,
        //     width: 0.8,
        //   ),
        // ),
        // color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withAlpha(30),
        //     offset: Offset(0.0, 3.0),
        //     blurRadius: 5.0
        //   )
        // ]
        color: Colors.grey[100],
        // color: Colors.blue[900],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(30),
              offset: Offset(0.0, 5.0),
              blurRadius: 10.0
            )
          ],
      ),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: leadingButton == null ? 20.0 : 10.0), // Because TopBarButton already adds margin of 10 to the left

            // Leading button
            if (leadingButton != null)
              leadingButton,
            if (leadingButton != null)
              Spacer(),
            
            // Back button
            if (hasBackButton)
               _buildBackButton(context),
            if (hasBackButton)
              SizedBox(width: 15.0),

            // Title
            if (title != null || category != null) 
              _buildTitle(context),
            
            // Action buttons
            if (actions != null)
              for (TopBarButton button in actions) // Builds all the buttons
                button,

            SizedBox(width: 20.0,),
          ],
        ),
        SizedBox(height: 10.0,),
        searchBar ?? Container(),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
   return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              offset: Offset(0.0, 2.0),
              blurRadius: 15.0,
            ),
          ]
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0,),
        child: Container(
          child: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black, size: 15.0,),
        )
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Expanded(
      child: Container(
        child: Text(
          category?.name ?? title, // If a category is specified, use that as the title (only for CategoryPage())
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline1
        ),
      ),
    );
  }
}