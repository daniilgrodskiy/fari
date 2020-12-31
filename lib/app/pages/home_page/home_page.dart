import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fari/app/custom_widgets/common_widgets/add_button.dart';
import 'package:fari/app/custom_widgets/common_widgets/category_widget.dart';
import 'package:fari/app/custom_widgets/common_widgets/task_widget.dart';
import 'package:fari/app/custom_widgets/platform_widgets/platform_alert_dialog.dart';
import 'package:fari/app/custom_widgets/top_bar/top_bar.dart';
import 'package:fari/app/custom_widgets/useful_time_methods.dart';
import 'package:fari/app/models/category.dart';
import 'package:fari/app/models/task.dart';
import 'package:fari/app/pages/calendar/calendar_page.dart';
import 'package:fari/app/pages/category_page/category_page.dart';
import 'package:fari/app/pages/edit_task_page.dart/edit_task_page.dart';
import 'package:fari/app/pages/home_page/home_page_model.dart';
import 'package:fari/app/pages/home_page/timeline_widget.dart';
import 'package:fari/app/pages/tasks_page/tasks_page.dart';
import 'package:fari/app/task_sort_methods.dart';
import 'package:fari/services/auth.dart';
import 'package:fari/services/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({
    this.tasks,
    this.model,
  });

  final List<Task> tasks;
  final HomePageModel model;

  @override
  _HomePageState createState() => _HomePageState();

  static Widget create(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<List<Task>>(
        stream: database.tasksStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final tasks = snapshot.data;
            tasks.sort(TaskSortMethods.dueDate);
            return ChangeNotifierProvider<HomePageModel>(
              create: (context) => HomePageModel(
                selectedDate: DateTime.now(),
                showCategories: true,
              ),
              child: Consumer<HomePageModel>(builder: (context, model, _) {
                return HomePage(
                  model: model,
                  tasks: tasks,
                );
              }),
            );
          }
          return Container(
            color: Colors.grey[50],
          );
        });
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  /// Instance variables

  AnimationController _animationController;

  Map<DateTime, int> _tasksPerDay = {};
  Map<String, int> _tasksPerCategory = {};

  /// Getter methods

  List<Task> get tasks => widget.tasks;
  HomePageModel get model => widget.model;

  /// Stateful methods

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  @override
  void initState() {
    super.initState();
    _fcm.requestNotificationPermissions();

    // Animation
    _animationController = new AnimationController(
        duration: new Duration(milliseconds: 200), vsync: this);
    _animationController.forward();

    // Firebase messaging
    // if (Platform.isIOS) {
    //   iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
    //     print(data);
    //     _saveDeviceToken();
    //   });

    //   _fcm.requestNotificationPermissions(IosNotificationSettings());
    // } else {
    //   _saveDeviceToken();
    // }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final snackbar = SnackBar(
          content:
              Text("Your task ${message['notification']['title']} is due!"),
        );

        Scaffold.of(context).showSnackBar(snackbar);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
  }

  // void _saveDeviceToken() async {
  //   final user = Provider.of<User>(context, listen: false);

  //   // Get the current user
  //   String uid = user.uid;
  //   // FirebaseUser user = await _auth.currentUser();

  //   // Get the token for this device
  //   String fcmToken = await _fcm.getToken();

  //   // Save it to Firestore
  //   if (fcmToken != null) {
  //     var tokens =
  //         _db.collection('users').doc(uid).collection('tokens').doc(fcmToken);

  //     await tokens.set({
  //       'token': fcmToken,
  //       'createdAt': FieldValue.serverTimestamp(), // optional
  //     });
  //   }
  // }

  @override
  void dispose() {
    _animationController.dispose();
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  /// Build method

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    // Category category = new Category(
    //   id: "2020-05-18T15:10:07.161460",
    //   color: "3498db",
    //   name: "School",
    // );

    // CategoryPage.create(context, category: category);

    // CalendarPage.show(context);

    _countTasks();

    return Scaffold(
      // backgroundColor: Colors.blueGrey[50],
      backgroundColor: Colors.grey[50],
      appBar: TopBar.empty(),
      // appBar: TopBar.homePage(context),
      body: Stack(
        children: <Widget>[
          _buildContent(context, database),
          AddButton(
            onTap: () => EditTaskPage.show(context),
          ),
          _buildCalendarButton(),
        ],
      ),
    );
  }

  Widget _buildCalendarButton() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom,
      right: 80.0,
      child: GestureDetector(
        onTap: () {
          CalendarPage.show(context);
        },
        child: Container(
          height: 60.0,
          width: 60.0,
          decoration: BoxDecoration(
              color: Colors.indigo[400],
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withAlpha(150),
                  offset: Offset(0.0, 5.0),
                  blurRadius: 10.0,
                  spreadRadius: -2.0,
                ),
              ]),
          child: Icon(
            FontAwesomeIcons.calendarAlt,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _countTasks() {
    // Creates tasks counter!
    _tasksPerDay = {};
    _tasksPerCategory = {};

    tasks.forEach((task) {
      if (task.day != null) {
        _tasksPerDay.update(
            DateTime(task.day.year, task.day.month, task.day.day),
            (numberOfTasks) => numberOfTasks = numberOfTasks + 1,
            ifAbsent: () => 1);
      }

      if (task.categoryId != null) {
        _tasksPerCategory.update(task.categoryId,
            (numberOfTasks) => numberOfTasks = numberOfTasks + 1,
            ifAbsent: () => 1);
      }
    });
  }

  Widget _buildContent(BuildContext context, Database database) {
    // TODO: Implement the ability to repeat tasks
    // TODO: Implement custom alert dialogs
    // TODO: Implement animations

    return ListView(
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        // Header
        _buildTopHeader(database),
        SizedBox(
          height: 20.0,
        ),
        // Date timeline
        Container(
          // padding: EdgeInsets.symmetric(vertical: 10.0),
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.blueGrey[100].withAlpha(150),
                    offset: Offset(0.0, 10.0),
                    blurRadius: 5.0),
              ]),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: _buildTimelineDay(),
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        _buildTasks(database),
        SizedBox(
          height: 500.0,
        ),
      ],
    );
  }

  Widget _buildTopHeader(Database database) {
    final user = Provider.of<User>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Top part
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Container(
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(user.photoUrl),
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      offset: Offset(0.0, 5.0),
                      blurRadius: 5.0,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Hello, " + (user.displayName.split(" ")[0] + "!"),
                          style: Theme.of(context).textTheme.headline6.copyWith(
                              fontSize: 25.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withAlpha(200)),
                        ),
                      ],
                    ),
                    Text(
                      (_tasksPerDay[DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day)] ??
                                  "No")
                              .toString() +
                          (_tasksPerDay[DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day)] ==
                                  1
                              ? " task due today"
                              : " tasks due today"),
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w300,
                          // color: Colors.white
                          color: Colors.black.withAlpha(150)),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  bool signOut = await PlatformAlertDialog(
                    title: "Are you want to sign out?",
                    content: "",
                    defaultActionText: "Yes",
                    cancelActionText: "No",
                  ).show(context);
                  if (signOut) {
                    final auth = Provider.of<AuthBase>(context, listen: false);
                    await auth.signOut();
                  }
                },
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                      color: Colors.indigo[300],
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withAlpha(150),
                          offset: Offset(0.0, 3.0),
                          blurRadius: 5.0,
                          spreadRadius: -2.0,
                        ),
                      ]),
                  child: Icon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.white,
                    size: 15.0,
                  ),
                ),
              )
            ],
          ),
        ),
        // Bottom part
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text("Categories",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.black.withAlpha(200),
                        fontWeight: FontWeight.w700,
                        fontSize: 25.0,
                      )),
            ),
            SizedBox(
              width: 10.0,
            ),
            GestureDetector(
              onTap: () {
                model.updateShowCategories(!model.showCategories);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 100),
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: model.showCategories
                      ? Colors.red[400]
                      : Colors.green[400],
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  model.showCategories ? "Hide" : "Show",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.white, fontSize: 10.0),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        if (model.showCategories) _buildCategories(database),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text("Tasks",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.black.withAlpha(200),
                        fontWeight: FontWeight.w700,
                        fontSize: 25.0,
                      )),
            ),
            SizedBox(
              width: 10.0,
            ),
            GestureDetector(
              onTap: () {
                TasksPage.show(context, database);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.indigo[400],
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  "View All",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.white, fontSize: 10.0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildTimelineDay() {
    List<Widget> dayWidgets = [];
    int sunday = 7;
    DateTime currentDate = new DateTime.now();

    while (currentDate.weekday != sunday) {
      currentDate = currentDate.subtract(new Duration(days: 1));
    }

    // DateTime end = currentDate.add(Duration(days: 7));

    for (int i = 0; i < 7; i++) {
      dayWidgets.add(new TimelineWidget(
        onTap: () {
          _animationController.reset();
          _animationController.forward();
        },
        currentDate: currentDate,
        model: model,
        tasksPerDay: _tasksPerDay,
      ));
      currentDate = currentDate.add(Duration(days: 1));
    }

    // print(_tasksPerDay.toString());

    return dayWidgets;
  }

  Widget _buildTasks(Database database) {
    return FadeTransition(
      opacity: new Tween<double>(begin: 0.25, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeIn)),
      child: ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            bool isFirst = index ==
                0; // Prevents extra space between "Tasks" heading and actual tasks
            return Column(
              children: <Widget>[
                if (index == 0 ||
                    (index != 0 &&
                        tasks[index - 1].day != null &&
                        tasks[index].day ==
                            null)) // First time we're showing a task with no deadline))
                  SlideTransition(
                    position: new Tween<Offset>(
                      begin: const Offset(0.0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: _animationController, curve: Curves.easeIn)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              left: 20.0, top: index == 0 ? 0.0 : 40.0),
                          child: Text(
                              index == 0
                                  ? _getDateHeader(model.selectedDate) + ":"
                                  : "No deadline:",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                    color: Colors.black.withAlpha(150),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20.0,
                                  )),
                        ),
                        // SizedBox(width: 10.0),
                        Spacer(),
                        if (isFirst)
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.indigo[400],
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                "Filter",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        color: Colors.white, fontSize: 15.0),
                              ),
                            ),
                          ),
                        SizedBox(width: 20.0),
                      ],
                    ),
                  ),
                if ((tasks[index].day != null &&
                        isSameDay(model.selectedDate, tasks[index].day)) ||
                    tasks[index].day ==
                        null) // Show tasks due today and no deadline tasks
                  SlideTransition(
                      position: new Tween<Offset>(
                        begin: const Offset(0.0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: _animationController, curve: Curves.easeIn)),
                      child: FadeTransition(
                          opacity: new Tween<double>(begin: 0.0, end: 1.0)
                              .animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Curves.easeIn)),
                          child: TaskWidget(
                            task: tasks[index],
                            database: database,
                          ))),
              ],
            );
          }),
    );
  }

  /// Gets the custom date to show
  String _getDateHeader(DateTime date) {
    // Today
    if (isToday(date)) {
      return "Today";
    }
    // Tomorrow
    if (isTomorrow(date)) {
      return "Tomorrow";
    }

    // return DateFormat.MMMMEEEEd().format(date);
    return DateFormat.MMMMd().format(date);
  }

  Widget _buildCategories(Database database) {
    return StreamBuilder<List<Category>>(
        stream: database.categoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final categories = snapshot.data;
            // No tasks added yet
            if (categories.isEmpty) {
              return Center(
                  // child: _buildNoCategoriesContainer(context)
                  );
            }
            // Data loaded and exists
            return Column(
              children: <Widget>[
                Container(
                  height: 200.0,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        index = index - 1;
                        if (index == -1) {
                          return SizedBox(
                            width: 30.0,
                          );
                        }
                        return CategoryWidget(
                            tasksPerCategory: _tasksPerCategory,
                            category: categories[index],
                            onTap: () => CategoryPage.create(context,
                                category: categories[index]));
                      }),
                ),
              ],
            );
          }
          // Loading state
          return Center(child: Container());
        });
  }
}
