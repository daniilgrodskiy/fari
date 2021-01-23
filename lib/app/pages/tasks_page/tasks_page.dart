import 'package:fari/app/custom_widgets/common_widgets/add_button.dart';
import 'package:fari/app/custom_widgets/common_widgets/sort_tasks_bottom_sheet.dart';
import 'package:fari/app/custom_widgets/common_widgets/task_widget.dart';
import 'package:fari/app/custom_widgets/top_bar/search_bar.dart';
import 'package:fari/app/custom_widgets/top_bar/top_bar.dart';
import 'package:fari/app/models/task.dart';
import 'package:fari/app/pages/edit_task_page.dart/edit_task_page.dart';
import 'package:fari/app/pages/tasks_page/tasks_page_model.dart';
import 'package:fari/app/task_sort_methods.dart';
import 'package:fari/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TasksPage extends StatelessWidget {
  TasksPage({
    @required this.model,
    @required this.database,
    @required this.tasks,
  });

  final TasksPageModel model;
  final Database database;
  final List<Task> tasks;

  // 'create' instead of 'show' purely because we aren't ever NAVIGATING to this page; only can reach it from the bottom tab bar so it'd never be a 'show' through a navigator <--- Not true anymore, but for reference I'll keep it! :)
  static Widget show(BuildContext context, Database database) {
    // final database = Provider.of<Database>(context, listen: false);

    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        // fullscreenDialog: true,
        builder: (context) => StreamBuilder<List<Task>>(
            // IMPORTANT: Wrapping the page in this StreamBuilder so that the stream to get all the tasks doesn't get called EVERY time we type something into the search query.
            // TODO: However, I don't know if Firestore accounts for this^ and thus, lowers the number of queries. This is worth a look to make sure that the above statement is true. If it's not, then I DON'T need to keep wrapping some of these classes with a StreamBuilder.
            stream: database.tasksStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final tasks = snapshot.data;

                return ChangeNotifierProvider<TasksPageModel>(
                  create: (context) => TasksPageModel(),
                  child: Consumer<TasksPageModel>(builder: (context, model, _) {
                    return TasksPage(
                      database: database,
                      model: model,
                      tasks: tasks,
                    );
                  }),
                );
              }
              return Container();
            })));

    return StreamBuilder<List<Task>>(
        // IMPORTANT: Wrapping the page in this StreamBuilder so that the stream to get all the tasks doesn't get called EVERY time we type something into the search query.
        // TODO: However, I don't know if Firestore accounts for this^ and thus, lowers the number of queries. This is worth a look to make sure that the above statement is true. If it's not, then I DON'T need to keep wrapping some of these classes with a StreamBuilder.
        stream: database.tasksStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final tasks = snapshot.data;

            return ChangeNotifierProvider<TasksPageModel>(
              create: (context) => TasksPageModel(),
              child: Consumer<TasksPageModel>(builder: (context, model, _) {
                return TasksPage(
                  database: database,
                  model: model,
                  tasks: tasks,
                );
              }),
            );
          }
          return Container();
        });
  }

  /// Build methood

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: TopBar.searchBarOnly(
        context,
        SearchBar(
          hintText: "Search all tasks",
          onChanged: model.updateSearch,
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: <Widget>[
          _buildContent(context),
          AddButton(
            onTap: () => EditTaskPage.show(context, database: database),
          )
        ],
      ),
    );
  }

  /// UI methods

  Widget _buildButton(BuildContext context, VoidCallback onTap, String text) {
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.indigo[400],
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.white, fontSize: 10.0),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Tasks",
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          color: Colors.black.withAlpha(200),
                          fontWeight: FontWeight.w700,
                          fontSize: 30.0,
                        ),
                  ),
                ),
                Text(
                  (tasks.length.toString() ?? "No ") + " tasks",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.black.withAlpha(150),
                        fontWeight: FontWeight.w400,
                        fontSize: 15.0,
                      ),
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    useRootNavigator: true,
                    builder: (context) => SortTasksBottomSheet(
                          showCategoryOption: false,
                          currentSortType: model.sortType,
                          onTap: (newSortType) {
                            Navigator.pop(context);
                            model.updateSortType(newSortType);
                          },
                        ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.indigo[400],
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  "Sort",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.white, fontSize: 15.0),
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
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
            //       "Filter",
            //       style: Theme.of(context).textTheme.headline6.copyWith(
            //         color: Colors.white,
            //         fontSize: 15.0
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              width: 20.0,
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        _buildTasks(context),
        SizedBox(
          height: 200.0,
        ),
      ],
    );
  }

  Widget _buildTasks(BuildContext context) {
    if (tasks.isEmpty) {
      return _buildNoTasksContainer(context);
    }

    // Filter task
    switch (model.sortType) {
      case SortType.DueDate:
        tasks.sort(TaskSortMethods.dueDate);
        break;
      case SortType.DateCreation:
        tasks.sort(TaskSortMethods.dateCreation);
        break;
      case SortType.Alphabetically:
        tasks.sort(TaskSortMethods.alphabetically);
        break;
      case SortType.Category:
        tasks.sort(TaskSortMethods.category);
        break;
    }

    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) =>
            // I'M SO HAPPY LMAOOO ONLY SHOW TASKS THAT MATCH UP BY NAME BRO I WAS TRYING TO QUERY THE WHOLE DAMN DATABASE OMG THANK GOD I REALIZED THIS WAY WORKS TOO OMG IM SO HAPPY BC I REALIZED THAT BECAUSE WE RESET THE PAGE EACH TIME, THE MODEL AUTOMATICALLY QUERIES EACH TIME WE SEARCH SOMETHING NEW UP (BAD BAD BAD)
            tasks[index]
                        .name
                        .toLowerCase()
                        .contains(model.search.toLowerCase()) ||
                    (tasks[index].description != null &&
                        tasks[index]
                            .description
                            .toLowerCase()
                            .contains(model.search.toLowerCase()))
                ? TaskWidget(
                    task: tasks[index],
                    database: database,
                    showDate: true,
                  )
                : Container());
  }

  Widget _buildNoTasksContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo[900],
        boxShadow: [
          BoxShadow(
              color: Colors.indigo[900].withAlpha(150),
              offset: Offset(0.0, 15.0),
              blurRadius: 10.0,
              spreadRadius: -10.0),
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      margin: EdgeInsets.all(20.0),
      child: Center(
          child: Text(
        model.search != null
            ? "No tasks found"
            : "Click the plus button below to create your first task!",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline6.copyWith(
            fontSize: 20.0, fontWeight: FontWeight.w200, color: Colors.white),
      )),
    );
  }
}
