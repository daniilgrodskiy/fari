// import 'package:fari/app/custom_widgets/common_widgets/add_button.dart';
// import 'package:fari/app/custom_widgets/common_widgets/task_widget.dart';
// import 'package:fari/app/custom_widgets/top_bar/top_bar.dart';
// import 'package:fari/app/custom_widgets/top_bar/top_bar_button.dart';
// import 'package:fari/app/models/task.dart';
// import 'package:fari/app/pages/edit_task_page.dart/edit_task_page.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:fari/app/task_sort_methods.dart';
// import 'package:fari/services/auth.dart';
// import 'package:fari/services/database.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class TasksListViewPage extends StatefulWidget {
//   TasksListViewPage({
//     this.tasks
//   });

//   final List<Task> tasks;

//   @override
//   _TasksListViewPageState createState() => _TasksListViewPageState();

//   static Widget create(BuildContext context)  {
//     final database = Provider.of<Database>(context, listen: false);
//     return StreamBuilder<List<Task>>(
//       stream: database.tasksStream(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final tasks = snapshot.data;
//           tasks.sort(TaskSortMethods.dueDate);
//           return TasksListViewPage(tasks: tasks);
//         }
//         return Container();
//       }
//     );
//   }
// }

// class _TasksListViewPageState extends State<TasksListViewPage> with SingleTickerProviderStateMixin {

//   /// Instance variables
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
//       backgroundColor: Colors.blueGrey[50],
//       // appBar: _buildTopBar(),
//       // appBar: AppBar(
//       //   elevation: 1.0,
//       //   backgroundColor: Colors.white,
//       // ),
//       body: Stack(
//         children: <Widget>[
//           _buildContent(context, database),
//           Container(
//             // height: MediaQuery.of(context).padding.top,
//             height: MediaQuery.of(context).padding.top + 60.0,
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blueGrey.withAlpha(30),
//                   offset: Offset(0.0, 5.0),
//                   blurRadius: 10.0
//                 )
//               ],
//             ),
//             child: Stack(
//               fit: StackFit.expand,
//               children: <Widget>[
//                 Positioned(
//                   left: 20.0,
//                   bottom: 10.0,
//                   child: Text(
//                     "Home",
//                     style: Theme.of(context).textTheme.headline6.copyWith(
//                       fontSize: 30.0,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.black.withAlpha(200)
//                       // fontFamily: "helvetica"
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           AddButton(onTap: () => EditTaskPage.show(context),)          
//         ],
//       ),
//     );
//   }

//   Widget _buildTopBar() {
//     return TopBar(
//       // leadingButton: TopBarButton(
//       //   icon: FontAwesomeIcons.arrowDown,
//       //   text: "Now",
//       //   onTap: () {},
//       // ),
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

//   Widget _buildContent(BuildContext context, Database database, ) {
//     // TODO: Have the dates show up by heading via "Today", "Tomorrow", "Saturday", ""
//     // TODO: Figure out how to handle showing time
//     // TODO: Implement a 'swipe to complete' system and add a 'isCompleted' property
//     // TODO: Implement the ability to repeat tasks
//     // TODO: Implement custom alert dialogs
//     // TODO: Implement animations

//     // return ListView(
//     //   children: <Widget>[
//     //     Container(
//     //       margin: EdgeInsets.only(left: 20.0, top: 40.0),
//     //       child: Text(
//     //         'Home',
//     //         style: Theme.of(context).textTheme.headline6.copyWith(
//     //           fontSize: 50.0,
//     //           fontWeight: FontWeight.w800
//     //         ),
//     //       ),
//     //     ),
//     //     _buildTasks(database),
//     //   ],
//     // );

//     return CustomScrollView(
//       slivers: <Widget>[
//         // SliverAppBar(
//         //   pinned: true,
//         //   backgroundColor: Colors.blueGrey[50],
//         //   title: Text(
//         //     "Home",
//         //     style: Theme.of(context).textTheme.headline6.copyWith(
//         //       fontSize: 30.0,
//         //       fontWeight: FontWeight.w700,
//         //       // fontFamily: "helvetica"
//         //     ),
//         //   ),
//         //   centerTitle: false,
//         //   forceElevated: true,
//         //   elevation: 5.0,
//         //   actions: [
//         //     Container(
//         //       margin: EdgeInsets.symmetric(vertical: 10.0),
//         //       child: TopBarButton(
//         //         text: "Filter", 
//         //           icon: FontAwesomeIcons.filter,
//         //           onTap: () {}
//         //         ),
//         //     ),
//         //     // Container(
//         //     //   margin: EdgeInsets.symmetric(vertical: 10.0),
//         //     //   child: TopBarButton(
//         //     //     text: "Calendar", 
//         //     //     icon: FontAwesomeIcons.solidCalendarAlt,
//         //     //     onTap: () {}
//         //     //   ),
//         //     // ),
//         //     SizedBox(width: 10.0,),
//         //   ],
//         // ),
//         SliverToBoxAdapter(
//           child: SizedBox(height: 100.0,),
//         ),
//         SliverToBoxAdapter(
//           child: _buildTasks(database),
//         ),
//         SliverToBoxAdapter(
//           child: SizedBox(height: 300.0,),
//         ),
//       ],
//     );
//   }

//   Widget _buildTasks(Database database) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: ClampingScrollPhysics(),
//       itemCount: tasks.length,
//       itemBuilder: (context, index) {                       
//         if (tasks[index].day != null) {
//           return Column(
//             children: <Widget>[
//               if (index == 0 || tasks[index - 1].day.day != tasks[index].day.day)
//                 Row(
//                   children: <Widget>[
//                     Container(
//                       margin: EdgeInsets.only(left: 20.0, top: index == 0  ? 0.0 : 40.0),
//                       child: Text(
//                         _getDateHeader(tasks[index].day),
//                         style: Theme.of(context).textTheme.headline6.copyWith(
//                           color: Colors.black.withAlpha(200),
//                           fontWeight: FontWeight.w600,
//                           fontSize: 20.0,
//                         )
//                       ),
//                     ),
//                   ],
//                 ),
//               TaskWidget(task: tasks[index], database: database,),
//             ],
//           );
//         }
//         return Container();
//       }
//     );
//   }

//   /// Gets the custom date to show
//   String _getDateHeader(DateTime date) {
//     // Today
//     if (date.year == DateTime.now().year && date.month == DateTime.now().month &&  date.day == DateTime.now().day) {
//       return "Today";
//     }
//     // Tomorrow
//     if (date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day + 1) {
//       return "Tomorrow";
//     }

//     // return DateFormat.MMMMEEEEd().format(date);
//     return DateFormat.MMMMd().format(date);
//   }


// }