import 'package:fari/app/custom_widgets/useful_time_methods.dart';
import 'package:fari/app/models/category.dart';
import 'package:fari/app/models/task.dart';
import 'package:fari/app/pages/edit_task_page.dart/edit_task_page.dart';
import 'package:fari/services/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../hex_color.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskWidget extends StatefulWidget {
  TaskWidget({
    @required this.task,
    @required this.database,
    this.showDate,
  });

  final Task task;
  final Database database;
  final bool showDate;

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _scaleAnimationController;
  Animation<double> _animation;

  Task get task => widget.task;

  @override
  void initState() {
    _scaleAnimationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 100));
    _animation = CurvedAnimation(
        curve: Curves.easeOut,
        parent: Tween<double>(begin: 1.0, end: 0.80)
            .animate(_scaleAnimationController));
    super.initState();
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionExtentRatio: 0.0,
      // direction: DismissDirection.endToStart,
      key: Key(task.id),
      actionPane: SlidableScrollActionPane(),
      closeOnScroll: false,
      secondaryActions: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          padding: EdgeInsets.only(left: 20.0),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0))),
          child: Icon(
            FontAwesomeIcons.trashAlt,
            color: Colors.white,
          ),
        ),
      ],
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onDismissed: (actionType) {
          final database = Provider.of<Database>(context, listen: false);
          try {
            database.deleteTask(task);
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                elevation: 1.0,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                duration: Duration(seconds: 100),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red[400],
                content: Text("\"${task.name}\" has been deleted"),
                margin: EdgeInsets.all(10.0),
              ));
          } catch (e) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                duration: Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red[400],
                content: Text("Error: \"${task.name}\" was not deleted."),
                margin: EdgeInsets.all(10.0),
              ));
          }
        },
      ),
      child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: GestureDetector(
                  onTapDown: (tap) {
                    // print("x: ${tap.globalPosition.dx}, y: ${tap.globalPosition.dy}");
                    _scaleAnimationController.forward();
                  },
                  onTapUp: (up) {
                    _scaleAnimationController.reverse();
                    EditTaskPage.show(context, task: task);
                  },
                  onTapCancel: () {
                    _scaleAnimationController.reverse();
                  },
                  child: task.categoryId != null && task.categoryId != ""
                      ? StreamBuilder<Category>(
                          stream: widget.database
                              .categoryStream(categoryId: task.categoryId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Category category = snapshot.data;
                              return _buildTaskWidgetContent(context,
                                  hasCategory: true,
                                  category: category,
                                  database: widget.database);
                            }
                            return Container();
                          })
                      : _buildTaskWidgetContent(context,
                          hasCategory: false, database: widget.database)),
            );
          }),
    );
  }

  Widget _buildTaskWidgetContent(
    BuildContext context, {
    @required bool hasCategory,
    Category category,
    Database database,
  }) {
    return GestureDetector(
      onTap: () {
        EditTaskPage.show(context, task: task, database: database);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? Colors.green[100]
              : (task.day != null)
                  ? isMissed(task.day, task.time)
                      ? Colors.red[100]
                      : Colors.white
                  : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: task.isCompleted
                    ? Colors.green.withAlpha(30)
                    : (task.day != null)
                        ? isMissed(task.day, task.time)
                            ? Colors.red.withAlpha(30)
                            : Colors.black.withAlpha(30)
                        : Colors.black.withAlpha(30),
                offset: Offset(0.0, 10.0),
                blurRadius: 10.0,
                spreadRadius: -5.0),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: <Widget>[
            _buildCheckBoxSection(),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    children: <Widget>[
                      // Date
                      if ((task.time != null) ||
                          (task.day != null &&
                              widget.showDate != null &&
                              widget.showDate))
                        // If there's a task.time => always show it
                        // If there's no task.time => only show the date if there's a day AND showDate is true
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 3.0),
                          margin: EdgeInsets.only(bottom: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.indigo[200],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Icon(FontAwesomeIcons.calendarAlt, color: Colors.black54, size: 14.0,),
                              Icon(
                                FontAwesomeIcons.calendarAlt,
                                color: Colors.white54,
                                size: 14.0,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              ..._buildDateSection(context),
                            ],
                          ),
                        ),
                      // Category
                      if ((task.time != null) ||
                          (task.day != null &&
                              widget.showDate != null &&
                              widget.showDate))
                        SizedBox(
                          width: 10.0,
                        ),
                      if (hasCategory)
                        // Using a stack here so that the category background doesn't blend weirdly with the background of completed and missed tasks (the red/green does not mix well with the transparency)
                        _buildCategory(category),
                    ],
                  ),
                  // Name
                  Text(task.name,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  // Description
                  task.description != null && task.description != ""
                      ? Container(
                          margin: EdgeInsets.only(top: 3.0),
                          child: Text(task.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black.withAlpha(150))),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckBoxSection() {
    return GestureDetector(
      onTap: () async {
        try {
          Task savedTask = new Task(
              id: task.id,
              name: task.name,
              description: task.description,
              categoryId: task.categoryId,
              // Doing this just in case we type something and delete it after; we don't want to save an an empty ("") categoryId or description into the database
              day: task.day,
              time: task.time,
              isCompleted: !task.isCompleted,
              hasReminder: task.hasReminder);

          await widget.database.setTask(savedTask);
        } catch (e) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              duration: Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red[400],
              content: Text("Error: \"${task.name}\" was not changed."),
              margin: EdgeInsets.all(10.0),
            ));
          print(e);
        }
      },
      child: Container(
        child: Stack(
          children: <Widget>[
            AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: 35.0,
              height: 35.0,
              decoration: BoxDecoration(
                border: Border.all(
                    color: task.isCompleted
                        ? Colors.green[100]
                        : (task.day != null)
                            ? isMissed(task.day, task.time)
                                ? Colors.red[100]
                                : Colors.grey[300]
                            : Colors.grey[300],
                    width: 1.0),
                color: task.isCompleted
                    ? Colors.green[200].withAlpha(150)
                    : Colors.white,
                shape: BoxShape.circle,
                // borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            if (task.isCompleted)
              Container(
                width: 35.0,
                height: 35.0,
                child: Icon(
                  FontAwesomeIcons.check,
                  color: Colors.green[300],
                  size: 17,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDateSection(BuildContext context) {
    List<Widget> children = [];
    if (widget.showDate != null && widget.showDate) {
      // Show the date
      children.add(Text(
        DateFormat("MM/dd/y").format(task.day),
        style: Theme.of(context).textTheme.headline6.copyWith(
            fontSize: 14.0,
            // color: Colors.black54
            color: Colors.white),
      ));

      if (task.time != null) {
        // Show the " @ " if we want to show the date AND time
        children.add(Text(
          " @ ",
          style: Theme.of(context).textTheme.headline6.copyWith(
              fontSize: 16.0,
              // color: Colors.black54
              color: Colors.yellow[600]),
        ));
      }
    }
    if (task.time != null) {
      // Show the time
      children.add(Text(
        DateFormat.jm().format(task.time),
        style: TextStyle(
            fontSize: 14.0,
            // color: Colors.black54
            color: Colors.white),
      ));
    }
    return children;
  }

  Widget _buildCategory(Category category) {
    return Stack(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 5.0),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              border: Border.all(
                  color: HexColor(category.color).withAlpha(100), width: 1.0),
              borderRadius: BorderRadius.circular(5.0),
              // color: HexColor(category.color).withAlpha(50),
              color: Colors.white,
            ),
            child: Text(
              category.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.transparent,
              ),
            )),
        Container(
            margin: EdgeInsets.only(bottom: 5.0),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              border: Border.all(
                  color: HexColor(category.color).withAlpha(100), width: 1.0),
              borderRadius: BorderRadius.circular(5.0),
              color: HexColor(category.color).withAlpha(50),
            ),
            child: Text(
              category.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: HexColor(category.color)
                  // color: Colors.white,
                  ),
            )),
      ],
    );
  }
}
