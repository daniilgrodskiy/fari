// // return Container(
// //       color: Colors.transparent,
// //       child: Stack(
// //         children: <Widget>[
// //           Container(
// //             decoration: BoxDecoration(
// //               color: Colors.black,
// //               borderRadius: BorderRadius.circular(20.0),
// //             ),
// //             child: Transform.scale(
// //               scale: (-1 / 6) * (1 - _scrollOffset) + 1, 
// //               // Squeezed the function so that the two points on this linear graph are are (0.0, 1.0) and (0.6, 0.9)
// //               // This makes the _scrollOffset still occur while squeezing the scale into a range!
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(20),
// //                 child: Scaffold(
// //                   // extendBodyBehindAppBar: true,
// //                   backgroundColor: Colors.white,
// //                   appBar: _buildTopBar(),
// //                   // body: _buildContent(context, database, user),
// //                   body: Stack(
// //                     children: [
// //                       Container(
// //                         margin: EdgeInsets.only(top: 20.0),
// //                         child: _buildCalendar(context)
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //           DefaultTextStyle(
// //             // TODO: Don't know how I feel about this workaround! Only doing it because this child has no material ancestor!
// //             style: TextStyle(decoration: TextDecoration.none),              
// //             child: SlidingUpPanel(
// //               minHeight: 300.0,
// //               maxHeight: 800.0,
// //               onPanelSlide: (position) {
// //                 setState(() {
// //                   _scrollOffset = 1.0 - position;
// //                 });

// //                 // TODO: Handle these correctly (they're futures and should be treated as such)
// //                 if (position <= 0.7) {
// //                   FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
// //                   FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
// //                 } else {
// //                   FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
// //                   FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
// //                 }
// //                 return true;
// //               },
// //               panel: Center(
// //                 child: Text("This is the sliding Widget"),
// //               ),
// //                     panelBuilder: (ScrollController scrollController) {
// //                       return Container(
// //                         decoration: BoxDecoration(
// //                           color: Colors.blueGrey[50],
// //                           borderRadius: BorderRadius.only(topLeft:  Radius.circular(20.0), topRight: Radius.circular(20.0)),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withAlpha(50),
// //                               blurRadius: 10.0,
// //                               spreadRadius: 5.0,
// //                             )
// //                           ]
// //                         ),
// //                         child: _buildTasks(context, database, scrollController),
// //                       );
// //                     },
// //                   ),
// //               ),

// //           // AddButton(onTap: () => EditTaskPage.show(context))
// //         ],
// //       ),
// //     );

// return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Container(
//           padding: EdgeInsets.only(bottom: 10.0),
//           child: SingleChildScrollView(
//             controller: scrollController,
//             physics: ClampingScrollPhysics(),
//             child: GestureDetector(
//               child: Column(
//                 children: <Widget>[
//                   GestureDetector(
//                     onTap: _toggleDraggableScrollableSheet,            
//                     child: Container(
//                       color: Colors.transparent, // Adding this so that the Container is rendered
//                       child: Column(
//                         children: <Widget>[
//                           SizedBox(height: 20.0,),
//                           Align(
//                             alignment: Alignment.topCenter,
//                             child: Container(
//                               height: 8.0,
//                               width: 70.0,
//                               decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10.0)),
//                             ),
//                           ),
//                           SizedBox(height: 10.0,),
//                           Row(
//                             children: <Widget>[
//                               Container(
//                                 margin: EdgeInsets.only(left: 20),
//                                 child: Text(
//                                   'Tasks', 
//                                   style: Theme.of(context).textTheme.headline6.copyWith(
//                                     fontSize: 25.0,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ),
//                               Spacer(),
//                               Container(
//                                 padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//                                 margin: EdgeInsets.only(right: 20.0),
//                                 decoration: BoxDecoration(
//                                   color: Colors.indigo[900],
//                                   borderRadius: BorderRadius.circular(5.0),
//                                 ),
//                                 child: Text(
//                                   // DateFormat.MMMd().format(task.day) + " @ " + DateFormat.MMMd().format(task.time),
//                                   DateFormat.MMMMEEEEd().format(_selectedDate),
//                                   style: Theme.of(context).textTheme.headline6.copyWith(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.white
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             controller: scrollController,
//             // shrinkWrap: true,
//             physics: ClampingScrollPhysics(),
//             itemCount: tasks.length + 1,
//             itemBuilder: (context, index) {            
//               if (index == tasks.length) {
//                 // Extra space at the bottom for the ListView
//                 return SizedBox(height: 200.0,);
//               }              
//               if (tasks[index].day != null) {
//                 if (
//                   tasks[index].day.year == _selectedDate.year &&
//                   tasks[index].day.month == _selectedDate.month &&
//                   tasks[index].day.day == _selectedDate.day
//                 )
//                   return TaskWidget(task: tasks[index], database: database,);
//               }
//               return Container();
//             }
//           ),
//         ),
//       ],
//     );