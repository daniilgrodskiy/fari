import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fari/app/custom_widgets/common_widgets/add_button.dart';
import 'package:fari/app/custom_widgets/common_widgets/category_widget.dart';
import 'package:fari/app/custom_widgets/common_widgets/task_widget.dart';
import 'package:fari/app/custom_widgets/platform_widgets/platform_alert_dialog.dart';
import 'package:fari/app/custom_widgets/top_bar/top_bar.dart';
import 'package:fari/utils/useful_time_methods.dart';
import 'package:fari/app/models/ad_state.dart';
import 'package:fari/app/models/category.dart';
import 'package:fari/app/models/task.dart';
import 'package:fari/app/pages/calendar/calendar_page.dart';
import 'package:fari/app/pages/category_page/category_page.dart';
import 'package:fari/app/pages/edit_task_page.dart/edit_task_page.dart';
import 'package:fari/app/pages/home_page/home_page_model.dart';
import 'package:fari/app/pages/home_page/timeline_widget.dart';
import 'package:fari/app/pages/tasks_page/tasks_page.dart';
import 'package:fari/utils/task_sort_methods.dart';
import 'package:fari/services/auth.dart';
import 'package:fari/services/database.dart';
// import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_native_admob/flutter_native_admob.dart';
// import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /// Instance variables

  AnimationController _animationController;
  AnimationController _categoriesAnimationController;

  Map<DateTime, int> _tasksPerDay = {};
  Map<String, int> _tasksPerCategory = {};

  /// Getter methods

  List<Task> get tasks => widget.tasks;
  HomePageModel get model => widget.model;

  /// Stateful methods
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Animation<double> _categoriesAnimation;

  @override
  void initState() {
    super.initState();

    // Animation
    _animationController = new AnimationController(
        duration: new Duration(milliseconds: 200), vsync: this);
    _animationController.forward();

    _categoriesAnimationController = new AnimationController(
        duration: new Duration(milliseconds: 500), vsync: this);
    _categoriesAnimationController.forward();

    _categoriesAnimation = CurvedAnimation(
      parent: _categoriesAnimationController,
      curve: Curves.easeOut,
    );

    // Messaging
    try {
      _fcm.requestPermission();
    } catch (e) {
      print("Can't request notifications!");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      final snackbar = SnackBar(
        content: Text("Your task ${message.notification.title} is due!"),
      );

      Scaffold.of(context).showSnackBar(snackbar);
    });
  }

  @override
  void dispose() {
    // _subscription.cancel();
    // _nativeAdController.dispose();
    super.dispose();
    banner?.dispose();
  }

  BannerAd banner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);

    adState.initalization.then((status) {
      setState(() {
        banner = BannerAd(
            adUnitId: adState.bannerAdUnitId,
            size: AdSize.banner,
            request: AdRequest(),
            listener: adState.adListener)
          ..load();
      });
    });
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
        _buildCategorySection(database),
        SizedBox(
          height: 20.0,
        ),
        // Date timeline
        Container(
          // padding: EdgeInsets.symmetric(vertical: 10.0),
          height: 100.0,
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
          child: ListView(
            // mainAxisSize: MainAxisSize.max,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
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
              _buildAvatar(user),
              SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Hello" +
                              ((user.displayName.split(" ")[0] == "null"
                                      ? ""
                                      : ", " +
                                          user.displayName?.split(" ")[0]) +
                                  "!"),
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
                    title: "Are you sure you want to sign out?",
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
      ],
    );
  }

  Widget _buildCategorySection(Database database) {
    return Column(children: [
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
            onTap: () async {
              if (model.showCategories) {
                // TODO: Add an invisible container here that grows and shrinks to make the transition nicer!
                await _categoriesAnimationController.reverse();
                model.updateShowCategories(!model.showCategories);
              } else {
                model.updateShowCategories(!model.showCategories);
                await _categoriesAnimationController.forward();
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
              decoration: BoxDecoration(
                color:
                    model.showCategories ? Colors.red[400] : Colors.green[400],
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
      if (banner == null)
        SizedBox(
          height: 50,
        )
      else
        Container(
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
            height: 50,
            child: AdWidget(ad: banner)),
      SizedBox(height: 20.0),
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
      )
    ]);
  }

  Widget _buildCategories(Database database) {
    return FadeTransition(
      opacity: _categoriesAnimation,
      child: StreamBuilder<List<Category>>(
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
          }),
    );
  }

  Widget _buildAvatar(User user) {
    // print(user.photoUrl);
    // print(user.displayName.split(" ")[0]);
    if (user.photoUrl == null || user.photoUrl == "null") {
      // No photo
      if (user.displayName == null ||
          user.displayName.split(" ")[0] == "null") {
        // No name
        return Container();
      } else {
        // Name exists
        return Container(
          height: 50.0,
          width: 50.0,
          decoration: BoxDecoration(
            color: Colors.indigo[400],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                offset: Offset(0.0, 5.0),
                blurRadius: 5.0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              user.displayName.split(" ")[0].substring(0, 1),
              style: Theme.of(context).textTheme.headline6.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
          ),
        );
      }
    } else {
      // There is a photo url
      return Container(
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
      );
    }
  }

  List<Widget> _buildTimelineDay() {
    List<Widget> dayWidgets = [];
    DateTime currentDate = new DateTime.now().subtract(new Duration(days: 2));

    // Originally only showed 1 week, starting on Sunday
    // int sunday = 7;
    // while (currentDate.weekday != sunday) {
    //   currentDate = currentDate.subtract(new Duration(days: 1));
    // }

    // DateTime end = currentDate.add(Duration(days: 7));

    for (int i = 0; i < 17; i++) {
      dayWidgets.add(
        new TimelineWidget(
          onTap: () {
            _animationController.reset();
            _animationController.forward();
          },
          currentDate: currentDate,
          model: model,
          tasksPerDay: _tasksPerDay,
        ),
      );
      currentDate = currentDate.add(Duration(days: 1));
    }

    // print(_tasksPerDay.toString());

    return dayWidgets;
  }

  Widget _buildTasks(Database database) {
    print("Building and sorting tasks.");
    // Sorting tasks
    widget.tasks.sort(TaskSortMethods.dueDate);

    return FadeTransition(
      opacity: new Tween<double>(begin: 0.25, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeIn)),
      child: ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
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
                        Spacer(),
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
}
