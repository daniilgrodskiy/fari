// import 'package:fari/app/custom_widgets/calendar/custom_calendar_carousel.dart';
// import 'package:fari/app/custom_widgets/common_widgets/task_widget.dart';
// import 'package:fari/app/custom_widgets/top_bar/top_bar.dart';
// import 'package:fari/app/models/task.dart';
// import 'package:fari/app/task_sort_methods.dart';
// import 'package:fari/services/auth.dart';
// import 'package:fari/services/database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class HomePage extends StatefulWidget {

//   HomePage({
//     this.tasks
//   });

//   final List<Task> tasks;


//   @override
//   _HomePageState createState() => _HomePageState();

//   static Widget create(BuildContext context)  {
//     final database = Provider.of<Database>(context, listen: false);

//     return StreamBuilder<List<Task>>(
//       stream: database.tasksStream(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final tasks = snapshot.data;
//           tasks.sort(TaskSortMethods.dueDate);
//           return HomePage(tasks: tasks);
//         }
//         return Container();
//       }
//     );
//   }
// }

// class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

//   /// Instance variables
    
//   DateTime _selectedDate = new DateTime.now();
//   double _scrollOffset = 1.0;
//   /// Getter methods

//   List<Task> get tasks => widget.tasks;


//   /// Stateful methods
  


//   /// Build method

//   @override
//   Widget build(BuildContext context) {
//     final database = Provider.of<Database>(context);
//     final user = Provider.of<User>(context);

//     return Scaffold(
//       // color: Colors.transparent,
//       body: Stack(
//         children: <Widget>[
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//             child: Transform.scale(
//               scale: (-1 / 6) * (1 - _scrollOffset) + 1, 
//               // Squeezed the function so that the two points on this linear graph are are (0.0, 1.0) and (0.6, 0.9)
//               // This makes the _scrollOffset still occur while squeezing the scale into a range!
//               child: ClipRRect( // Clips the body so that we the Container will have rounded corners
//                 borderRadius: BorderRadius.circular(20),
//                 child: Scaffold(
//                   // extendBodyBehindAppBar: true,
//                   backgroundColor: Colors.white,
//                   appBar: _buildTopBar(),
//                   body: Stack(
//                     children: [
//                       Container(
//                         margin: EdgeInsets.only(top: 20.0),
//                         child: _buildCalendar(context)
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           NotificationListener<DraggableScrollableNotification>(
//             onNotification: (notification) {
//               setState(() {
//                 _scrollOffset = 1.0 - notification.extent + 0.35;
//               });

//               // TODO: Handle these correctly (they're futures and should be treated as such)
//               if (notification.extent <= 0.7) {
//                 FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
//                 FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
//               } else {
//                 FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
//                 FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
//               }
//               return true;
//             },
//             child: DraggableScrollableActuator(
//               child: DraggableScrollableSheet(
//                 key: Key(initialExtent.toString()),
//                 minChildSize: minExtent,
//                 maxChildSize: maxExtent,
//                 initialChildSize: initialExtent,
//                 // key: Key(0.5.toString()),
//                 // minChildSize: 0.35,
//                 // initialChildSize: 0.5,
//                 // maxChildSize: 0.95,
//                 builder: (BuildContext context, ScrollController scrollController) {
//                   return _buildContent(context, database, scrollController);
//                 },
//               ),
//             ),
//           ),
//           // AddButton(onTap: () => EditTaskPage.show(context))
//         ],
//       ),
//     );
//   }


//   Widget _buildTopBar() {
//     return TopBar(
//       title: "Home",
//       // actions: <TopBarButton>[
//       //   TopBarButton(
//       //     text: "Daily", 
//       //       icon: FontAwesomeIcons.solidClock,
//       //       onTap: () {}
//       //     ),
//       //   TopBarButton(
//       //     text: "Calendar", 
//       //     icon: FontAwesomeIcons.solidCalendarAlt,
//       //     onTap: () {}
//       //   ),
//       // ],
//     );
//   }
  
//   static const double minExtent = 0.35;
//   static const double maxExtent = 0.92;

//   bool isExpanded = false;
//   double initialExtent = minExtent;
//   BuildContext draggableSheetContext;

//   void _toggleDraggableScrollableSheet() {
//     if (draggableSheetContext != null) {
//       setState(() {
//         initialExtent = isExpanded ? minExtent : maxExtent;
//         isExpanded = !isExpanded;
//       });
//       DraggableScrollableActuator.reset(draggableSheetContext);
//     }
//   }


//   Widget _buildContent(BuildContext context, Database database, ScrollController scrollController, ) {
//     // TODO: Have the dates show up by heading via "Today", "Tomorrow", "Saturday", ""
//     // TODO: Figure out how to handle showing time
//     // TODO: Implement a 'swipe to complete' system and add a 'isCompleted' property
//     // TODO: Implement the calendar and the ability to automatically select which days to show (maybe combine it all into one view with calendar on top, and a scrollable sheet of tasks on the bottom?)
//     // TODO: Change the 'Categories' tab into much nicer horizontal tiles?
//     // TODO: Implement the ability to repeat tasks
//     // TODO: Implement custom alert dialogs
//     // TODO: Implement animations

//     draggableSheetContext = context;

//     return Container(
//       decoration: BoxDecoration(
//       color: Colors.blueGrey[50],
//       borderRadius: BorderRadius.only(topLeft:  Radius.circular(20.0), topRight: Radius.circular(20.0)),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withAlpha(50),
//           blurRadius: 10.0,
//           spreadRadius: 5.0,
//         )
//       ]
//     ),
//       child: Stack(
//         children: <Widget>[
//           ListView(
//             controller: scrollController,
//             physics: ClampingScrollPhysics(),
//             children: <Widget>[
//               SizedBox(height: 50.0,),
//               _buildTasks(scrollController, database),
//                SizedBox(height: 200.0,)
//             ],
//           ),
//           _buildSheetHeader(scrollController),
//         ],
//       ),
//     );
//   }

//   Widget _buildTasks(ScrollController scrollController, Database database) {
//      return ListView.builder(
//       // controller: scrollController,
//       shrinkWrap: true,
//       physics: ClampingScrollPhysics(),
//       itemCount: tasks.length,
//       itemBuilder: (context, index) {                       
//         if (tasks[index].day != null) {
//           // Only show the task if it has a date
//           if (
//             tasks[index].day.year == _selectedDate.year &&
//             tasks[index].day.month == _selectedDate.month &&
//             tasks[index].day.day == _selectedDate.day
//           ) {
//             // Only show the tasks that match up with the selected date
//             return TaskWidget(task: tasks[index], database: database,);
//           }
//         }
//         return Container();
//       }
//     );
//   }


//   Widget _buildSheetHeader(ScrollController scrollController) {
//     return SingleChildScrollView(
//       controller: scrollController,
//       physics: ClampingScrollPhysics(),
//       child: Column(
//         children: <Widget>[
//           Container(
//             margin: EdgeInsets.only(bottom: 20.0,),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
//               color: Colors.blueGrey[50],
//               // boxShadow: [
//               //   BoxShadow(
//               //     offset: Offset(0.0, 10.0),
//               //     color: Colors.black.withAlpha(25),
//               //     blurRadius: 5.0,
//               //     spreadRadius: -5.0
//               //   ),
//               // ],
//             ),
//             height: 90.0, // TODO: Hardcoded pixel value. Dangerous?
//             child: Column(
//               children: <Widget>[
//                 SizedBox(height: 20.0,),
//                 Align(
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     height: 8.0,
//                     width: 80.0,
//                     decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10.0)),
//                   ),
//                 ),
//                 SizedBox(height: 10.0,),
//                 Row(
//                   children: <Widget>[
//                     Container(
//                       margin: EdgeInsets.only(left: 20),
//                       child: Text(
//                         'Tasks', 
//                         style: Theme.of(context).textTheme.headline6.copyWith(
//                           fontSize: 25.0,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                     Spacer(),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//                       margin: EdgeInsets.only(right: 20.0),
//                       decoration: BoxDecoration(
//                         color: Colors.indigo[900],
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                       child: Text(
//                         // DateFormat.MMMd().format(task.day) + " @ " + DateFormat.MMMd().format(task.time),
//                         DateFormat.MMMMEEEEd().format(_selectedDate),
//                         style: Theme.of(context).textTheme.headline6.copyWith(
//                           fontSize: 16.0,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCalendar(BuildContext context) {
//     final double dayFontSize = 15.0;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.indigo[900],
//         borderRadius: BorderRadius.circular(20.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.indigo[400],
//             offset: Offset(0.0, 10.0),
//             blurRadius: 20.0,
//             spreadRadius: -5.0,
//           ),
//         ],
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
//       margin: EdgeInsets.symmetric(horizontal: 20.0),
//       height: 450.0,
//       child: CustomCalendarCarousel<Task>(
//         markedDatesMap: populateTaskEventMap(),
//         selectedDateTime: _selectedDate,
//         onDayPressed: (day, tasksList) {
//           setState(() {
//             _selectedDate = day;
//           });
//         },
//         onDayLongPressed: (day) {},
//         customGridViewPhysics: NeverScrollableScrollPhysics(),
//         weekDayFormat: CustomWeekdayFormat.narrow,
//         // Colors
//         selectedDayBorderColor: Colors.transparent,
//         todayBorderColor: Colors.transparent,
//         selectedDayButtonColor: Colors.red[400],
//         todayButtonColor: Colors.indigo[400],
//         // Styles
//         headerTextStyle: Theme.of(context).textTheme.headline6.copyWith(
//           color: Colors.white,
//           fontWeight: FontWeight.w700,
//           fontSize: 35.0,
//         ),
//         weekdayTextStyle: Theme.of(context).textTheme.headline6.copyWith(
//           color: Colors.indigo[200],
//           fontWeight: FontWeight.w800,
//           fontSize: dayFontSize
//         ),
//         daysTextStyle: Theme.of(context).textTheme.headline6.copyWith(
//           color: Colors.white,
//           fontWeight: FontWeight.w500,
//           fontSize: dayFontSize
//         ),
//         weekendTextStyle: Theme.of(context).textTheme.headline6.copyWith(
//           color: Colors.white,
//           fontWeight: FontWeight.w500,
//           fontSize: dayFontSize
//         ),
//         inactiveDaysTextStyle: Theme.of(context).textTheme.headline6.copyWith(
//           color: Colors.white,
//           fontSize: dayFontSize
//         ),
//         selectedDayTextStyle: Theme.of(context).textTheme.headline6.copyWith(
//           color: Colors.white,
//           fontSize: dayFontSize
//         ),
//         prevDaysTextStyle: Theme.of(context).textTheme.headline6.copyWith(
//           color: Colors.white24,
//           fontWeight: FontWeight.w300,
//           fontSize: dayFontSize
//         ),
//         nextDaysTextStyle: Theme.of(context).textTheme.headline6.copyWith(
//           color: Colors.white24,
//           fontSize: dayFontSize,
//         ),
//         todayTextStyle: Theme.of(context).textTheme.headline6.copyWith(
//           color: Colors.white,
//           fontSize: dayFontSize
//         ),
//         // Buttons
//         leftButtonIcon: _buildTopButton(FontAwesomeIcons.arrowLeft),
//         rightButtonIcon: _buildTopButton(FontAwesomeIcons.arrowRight),
//       ),
//     );
//   }

//   EventList<Task> populateTaskEventMap() {
//     // Populates the taskEventMap which keeps track of all the events that are shown in the calendar.

//     EventList<Task> eventsList = new EventList<Task>();

//     for (Task task in tasks) {
//       if (task.day == null) continue; // Nothing to add if task has no date
//       eventsList.add(task.day, task);
//     }
//     return eventsList;
//   }

//   Widget _buildTopButton(IconData icon) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.indigo[400],
//         // shape: BoxShape.circle,
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: Icon(icon, color: Colors.white, size: 15.0,),
//     );
//   }

//   // Widget _buildTasksLeftBar(Database database) {
//   //   return Container(
//   //     decoration: BoxDecoration(
//   //       color: Colors.indigo[800],
//   //       borderRadius: BorderRadius.circular(5.0),
//   //     ),
//   //     padding: EdgeInsets.symmetric(vertical: 15.0),
//   //     margin: EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 10.0),
//   //     child: Center(
//   //       child: Text(
//   //         "You only have 5 tasks left to do today! 😊",
//   //         style: TextStyle(
//   //           color: Colors.white,
//   //           fontSize: 15.0,
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Widget _buildCategoriesHeading(BuildContext context) {
//   //   return Container(
//   //     margin: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
//   //     child: Row(
//   //       children: <Widget>[
//   //         Text(
//   //           "Categories",
//   //           style: Theme.of(context).textTheme.headline2
//   //         ),
//   //         SizedBox(width: 10.0,),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Widget _buildCategories(Database database) {
//   //   return StreamBuilder<List<Category>>(
//   //     stream: database.categoriesStream(),
//   //     builder: (context, snapshot) {
//   //       if (snapshot.hasData) {
//   //         final categories = snapshot.data;
//   //         // No tasks added yet
//   //         if (categories.isEmpty) {
//   //           return Center(
//   //             child: _buildNoCategoriesContainer(context)
//   //           );
//   //         }
//   //         // Data loaded and exists
//   //         return Column(
//   //           children: <Widget>[
//   //             Container(
//   //               height: 200.0,
//   //               child: ListView.builder(
//   //                 scrollDirection: Axis.horizontal,
//   //                 itemCount: categories.length + 1,
//   //                 itemBuilder: (context, index) {
//   //                   index = index - 1;
//   //                   if (index == -1) {
//   //                     return SizedBox(width: 30.0,);
//   //                   }
//   //                   return CategoryWidget(
//   //                     category: categories[index], 
//   //                     onTap: () => CategoryPage.create(context, category: categories[index])
//   //                   );
//   //                 }
//   //               ),
//   //             ),
//   //           ],
//   //         );
//   //       }
//   //       // Loading state
//   //       return Center(
//   //         child: Container()
//   //       );
//   //     }
//   //   );
//   // }

//   // Widget _buildNoCategoriesContainer(BuildContext context) {
//   //   return Expanded(
//   //     child: Container(
//   //       decoration: BoxDecoration(
//   //         color: Colors.indigo[400],
//   //         boxShadow: [
//   //           BoxShadow(
//   //             color: Colors.indigo[400].withAlpha(150),
//   //             offset: Offset(0.0, 15.0),
//   //             blurRadius: 10.0,
//   //             spreadRadius: -10.0
//   //           ),
//   //         ],
//   //         borderRadius: BorderRadius.circular(10.0),
//   //       ),
//   //       padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
//   //       margin: EdgeInsets.all(20.0),
//   //       child: Center(
//   //         child: Text(
//   //           "Click the button to the left to create your first category!",
//   //           textAlign: TextAlign.center,
//   //           style: Theme.of(context).textTheme.headline6.copyWith(
//   //             fontSize: 20.0,
//   //             fontWeight: FontWeight.w200,
//   //             color: Colors.white
//   //           ),
//   //         )
//   //       ),
//   //     ),
//   //   );
//   // }
//   //
//   // Widget _buildTasksHeading(BuildContext context) {
//   //   return Container(
//   //     margin: EdgeInsets.only(left: 20.0, bottom: 10.0),
//   //     child: Text(
//   //       "Tasks",
//   //       style: Theme.of(context).textTheme.headline2
//   //     ),
//   //   );
//   // }
//   //
//   // Widget _buildNoTasksContainer(BuildContext context) {
//   //   return Container(
//   //     decoration: BoxDecoration(
//   //       color: Colors.indigo[400],
//   //         boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.indigo[400].withAlpha(150),
//   //           offset: Offset(0.0, 15.0),
//   //           blurRadius: 10.0,
//   //           spreadRadius: -10.0
//   //         ),
//   //       ],
//   //       borderRadius: BorderRadius.circular(10.0),
//   //     ),
//   //     padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
//   //     margin: EdgeInsets.all(20.0),
//   //     child: Center(
//   //       child: Text(
//   //         "Click the plus button below to create your first task!",
//   //         textAlign: TextAlign.center,
//   //         style: Theme.of(context).textTheme.headline6.copyWith(
//   //           fontSize: 20.0,
//   //           fontWeight: FontWeight.w100,
//   //           color: Colors.white
//   //         ),
//   //       )
//   //     ),
//   //   );
//   // }
// }