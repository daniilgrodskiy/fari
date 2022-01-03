import 'dart:math';
import 'package:fari/app/custom_widgets/common_widgets/custom_text_field.dart';
import 'package:fari/app/custom_widgets/platform_widgets/platform_alert_dialog.dart';
import 'package:fari/app/custom_widgets/platform_widgets/platform_exception_alert_dialog.dart';
import 'package:fari/app/custom_widgets/top_bar/top_bar.dart';
import 'package:fari/utils/hex_color.dart';
import 'package:fari/app/models/category.dart';
import 'package:fari/app/models/task.dart';
import 'package:fari/app/pages/edit_category_page/edit_category_page.dart';
import 'package:fari/app/pages/edit_task_page.dart/date_section.dart';
import 'package:fari/app/pages/edit_task_page.dart/time_section.dart';
import 'package:fari/app/pages/edit_task_page.dart/edit_task_page_model.dart';
import 'package:fari/app/pages/edit_task_page.dart/toggle_field_button.dart';
import 'package:fari/app/pages/edit_task_page.dart/toggle_model.dart';
import 'package:fari/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  final Database database;
  final EditTaskPageModel model;
  final Category category;

  EditTaskPage({
    this.task,
    // IMPORTANT: 'task' will be null when we want to create a new task!
    // If the passed in task is null -> we're creating a new task
    // If the passed in task exists -> we're editing a task
    this.category, // Only using this to give an initial value for the model (this would happen if we're adding a new task inside of CategoryPage())
    @required this.database,
    @required this.model,
  });

  static Future<void> show(BuildContext context,
      {Task task, Category category, Database database}) async {
    if (database == null) {
      database = Provider.of<Database>(context, listen: false);
    }

    // IMPORTANT: 'rootNavigator' prevents the bottom navigation bar from obstructing the new screen,
    // You have to have "Database" passed in because we are navigating from MaterialApp(...) [via MaterialPageRoute] and the database provider only  exists as a CHILD of MaterialApp, so using Povider.of<Database>(context) does NOT get it. You HAVE to pass it into this class by making sure you get Database via the context of the class you're in BEFORE.
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      fullscreenDialog: true, // slides from the bottom
      builder: (context) => ChangeNotifierProvider<EditTaskPageModel>(
        create: (context) {
          if (task == null) {
            // New task
            return new EditTaskPageModel(
                database: database,
                categoryId: category?.id ??
                    "", // Only wouldn't be null if we're making a new task from CategoryPage() and want to give the model a default value
                day: DateTime.now(),
                time: DateTime.now(),
                toggleModel: new ToggleModel(
                  showDescription: false,
                  showCategories: false,
                  showDay: false,
                  showTime: false,
                ),
                hasReminder: false);
          }
          return new EditTaskPageModel(
            database: database,
            id: task.id,
            name: task.name,
            description: task.description,
            categoryId: task.categoryId,
            day: task.day ?? DateTime.now(),
            time: task.time ?? DateTime.now(),
            toggleModel: new ToggleModel(
              showDescription: task.description != null ? true : false,
              showCategories: task.categoryId != null ? true : false,
              showDay: task.day != null ? true : false,
              showTime: task.time != null ? true : false,
            ),
            isCompleted: task.isCompleted,
            hasReminder: task.hasReminder,
          );
        },
        child: Consumer<EditTaskPageModel>(
          builder: (context, model, _) =>
              // Actual task page
              EditTaskPage(
            task: task,
            database: database,
            model: model,
          ),
        ),
      ),
    ));
  }

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage>
    with SingleTickerProviderStateMixin {
  //// Stateful instance variables

  final _nameController = new TextEditingController();
  final _descriptionController = new TextEditingController();

  final _nameFocusNode = new FocusNode();
  final _descriptionFocusNode = new FocusNode();
  final _formKey = new GlobalKey<FormState>();

  ScrollController _listViewScrollController;

  //// Getters

  Task get task => widget.task;
  Database get database => widget.database;
  EditTaskPageModel get model => widget.model;
  ToggleModel get toggleModel => widget.model.toggleModel;

  @override
  void initState() {
    super.initState();
    _nameController.text = task?.name;
    _descriptionController.text = task?.description;

    _listViewScrollController = new ScrollController();
    _listViewScrollController.addListener(() {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _listViewScrollController.dispose();
  }

  //// Service methods

  Future<void> _submit() async {
    // Called when the form is submitted
    if (_formKey.currentState.validate()) {
      try {
        await model.submit(task);
        Navigator.of(context).pop(true);
      } on PlatformException catch (e) {
        // Shows the error in a PlatfrormAlertExceptionDialog (which extends PlatformAlertDialog); will be rethrown from the 'submit()' method inside of our bloc

        // IMPORTANT: Don't forget to always change 'isLoading' back to false after throwing an error!
        model.updateWith(isLoading: false);
        PlatformExceptionAlertDialog(
          title: task == null
              ? "Unable to create new task 😞"
              : "Unable to save task 😞",
          exception: e,
        ).show(context);
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _delete(Task task) async {
    // Called when user wants to delete a task
    try {
      bool isQuitting = await PlatformAlertDialog(
        title: "Are you sure you want to delete this task?",
        content: "This action cannot be undone.",
        defaultActionText: "Yes",
        cancelActionText: "No",
      ).show(context);

      if (isQuitting) {
        await model.deleteTask(task);
        Navigator.of(context).pop();
      }
    } on PlatformException catch (e) {
      model.updateWith(isLoading: false);
      PlatformExceptionAlertDialog(
        title: "Unable to delete task 😞",
        exception: e,
      ).show(context);
    }
  }

  //// 'build' method

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.grey[100],
          // backgroundColor: Colors.grey[100],
          // appBar: TopBar.edit(context, _submit, task),
          appBar: TopBar.empty(),
          body: Stack(
            children: <Widget>[
              ListView(
                controller: _listViewScrollController,
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  if (task != null) _buildDeleteButton(),
                  SizedBox(
                    height: 20.0,
                  ),
                  _buildHeading(),
                  SizedBox(
                    height: 20.0,
                  ),
                  _buildForm(),
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    height: 400.0,
                  ),
                ],
              ),
              _buildSubmitButton(),
              _buildExitButton(),
            ],
          ),
        ),
        model.isLoading ? _buildOverlay() : Container(),
      ],
    );
  }

  //// UI methods

  Widget _buildExitButton() {
    return Positioned(
      right: 20.0,
      top: 20.0,
      child: GestureDetector(
        onTap: () async {
          // TODO: Uncomment this part and only show dialog if it's a created task that's been altered (we'd check once we put this top bar in a separate class and pass in "model")
          // bool isQuitting =  await PlatformAlertDialog(
          //   title: "Are you want to quit?",
          //   content: "Changes will not be saved.",
          //   defaultActionText: "Yes",
          //   cancelActionText: "No",
          // ).show(context);

          // if (isQuitting)
          Navigator.pop(context);
        },
        child: Container(
          height: 50.0,
          width: 50.0,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(150),
            shape: BoxShape.circle,
          ),
          child: Icon(
            FontAwesomeIcons.times,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeading() {
    return Container(
      margin: EdgeInsets.only(left: 20.0),
      child: Text(
        task?.name == null || task?.name == "" ? "New task" : task.name,
        style: Theme.of(context).textTheme.headline6.copyWith(
              color: Colors.indigo,
              fontWeight: FontWeight.w700,
              fontSize: 25.0,
            ),
      ),
    );
  }

  Widget _buildTextFieldHeading(String title,
      {bool isEnabled,
      VoidCallback onTap,
      String enabledText,
      String disabledText}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20.0, right: 10.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline6.copyWith(
                    color: Colors.black.withAlpha(200),
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (isEnabled != null) ToggleFieldButton(isEnabled, onTap)
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Name
          _buildTextFieldHeading("Name"),
          CustomTextField(
            enabled: model.isLoading == false,
            controller: _nameController,
            focusNode: _nameFocusNode,
            hintText: "\"Exercise for 20 minutes\"",
            textInputAction: TextInputAction.next,
            maxLength: 140,
            minLines: 1,
            maxLines: 3,
            onChanged: model.updateName,
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_descriptionFocusNode),
            validator: (text) {
              if (text == "" || text == null) {
                return "Your task must have a name";
              }
              return null;
            },
          ),
          SizedBox(height: 40.0),
          // Description
          _buildTextFieldHeading("Description",
              isEnabled: toggleModel.showDescription,
              onTap: model.toggleShowDescription),
          if (toggleModel.showDescription)
            CustomTextField(
              enabled: model.isLoading == false,
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              hintText: "\"3 sets of crunches, 5 sets of pushups\"",
              maxLength: 240,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              onChanged: model.updateDescription,
            ),
          SizedBox(
            height: 40.0,
          ),
          // Categories
          _buildTextFieldHeading("Categories",
              isEnabled: toggleModel.showCategories,
              onTap: model.toggleShowCategories),
          if (toggleModel.showCategories) _buildCategories(database),
          SizedBox(
            height: 40.0,
          ),
          // Deadline
          _buildTextFieldHeading("Deadline",
              isEnabled: toggleModel.showDay, onTap: model.toggleShowDay),
          SizedBox(
            height: 10.0,
          ),
          if (toggleModel.showDay) _buildDateTimeSection(),
          SizedBox(
            height: 20.0,
          ),
          if (toggleModel.showDay) _buildDateSection(),
          SizedBox(
            height: 40.0,
          ),
          if (toggleModel.showDay)
            _buildTextFieldHeading("Time",
                isEnabled: toggleModel.showTime, onTap: model.toggleShowTime),
          if (toggleModel.showDay && toggleModel.showTime) _buildTimeSection(),
          SizedBox(
            height: 40.0,
          ),
          if (toggleModel.showDay) _buildReminderSection()
        ],
      ),
    );
  }

  Widget _buildCategories(Database database) {
    return StreamBuilder<List<Category>>(
        stream: database.categoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final categories = snapshot.data;
            // No tasks added yet
            if (categories.isEmpty) {
              return GestureDetector(
                onTap: () {
                  EditCategoryPage.show(context, database: database);
                },
                child: Center(
                    child: Container(
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  margin: EdgeInsets.all(20.0),
                  child: Center(
                      child: Text(
                    "Click here to create your first category!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w200,
                        ),
                  )),
                )),
              );
            }
            // Data loaded and exists
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap(
                children: _buildLoadedCategories(categories, context),
              ),
            );
          }
          // Loading state
          return Center(child: CircularProgressIndicator());
        });
  }

  List<Widget> _buildLoadedCategories(
      List<Category> categories, BuildContext context) {
    List<Widget> widgets = categories.map((category) {
      // Builds every individual category widget
      return GestureDetector(
          onTap: () {
            model.categoryId != category.id
                ? model.updateCategoryId(category.id)
                : model.updateCategoryId("");
          },
          child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: model.categoryId == category.id
                        ? HexColor(category.color).withAlpha(150)
                        : Colors.transparent,
                    width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
                color: HexColor(category.color).withAlpha(30),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  color: HexColor(category.color),
                  fontSize: 15.0,
                ),
              )));
    }).toList();

    widgets.add(_buildAddCategoryButton(context));

    return widgets;
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () => EditCategoryPage.show(context, database: database),
      child: Container(
        // margin: EdgeInsets.only(top: 5.0),
        height: 32.0,
        width: 32.0,
        decoration: BoxDecoration(
          color: Colors.indigo[300],
          borderRadius: BorderRadius.circular(8.0),
          // boxShadow: [
          //   BoxShadow(
          //     color:Colors.black.withAlpha(150),
          //     offset: Offset(0.0, 1.0),
          //     blurRadius: 5.0,
          //     spreadRadius: -1.0,
          //   ),
          // ]
        ),
        child: Icon(
          FontAwesomeIcons.plus,
          color: Colors.white,
          size: 13.0,
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Center(
      child: GestureDetector(
        onTap: () => _delete(task),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.red[300],
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.red[300].withAlpha(200),
                    offset: Offset(0.0, 5.0),
                    blurRadius: 15.0,
                    spreadRadius: -5.0),
              ]),
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          margin: EdgeInsets.fromLTRB(20.0, 10.0, 80.0, 20.0),
          child: Center(
            child: Text(
              "Delete task",
              style: Theme.of(context).textTheme.headline6.copyWith(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      bottom: 20.0,
      left: 20.0,
      right: 20.0,
      child: Center(
        child: GestureDetector(
          onTap: _submit,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.indigo[400],
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.indigo[400].withAlpha(200),
                      offset: Offset(0.0, 5.0),
                      blurRadius: 15.0,
                      spreadRadius: -5.0),
                ]),
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Center(
              child: Text(
                // If the passed in task is null -> we're creating a task
                // If the passed in task exists -> we're editing a task
                task == null ? "Create task" : "Save task",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
            // child: Icon(FontAwesomeIcons.check, color: Colors.white,),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() => DateSection(
        model: model,
      );

  Widget _buildTimeSection() => TimeSection(
        model: model,
      );

  Widget _buildDateTimeSection() {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(50),
                    offset: Offset(0.0, 5.0),
                    spreadRadius: -3.0,
                    blurRadius: 5.0),
              ]),
          margin: EdgeInsets.only(left: 20.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 5.0),
                child: Icon(FontAwesomeIcons.calendarAlt,
                    size: 15.0, color: Colors.black.withAlpha(150)),
              ),
              Text(
                DateFormat.yMMMd().format(model.day) ?? "",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              if (toggleModel.showTime)
                Row(
                  children: <Widget>[
                    Text(
                      " @ ",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.indigo[400]),
                    ),
                    Text(
                      DateFormat.jm().format(model.time) ?? "",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withAlpha(150)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return Column(
      children: [
        _buildTextFieldHeading("Send Reminder",
            isEnabled: model.hasReminder,
            onTap: () => model.updateHasReminder(!model.hasReminder),
            enabledText: "Disable",
            disabledText: "Enable"),
        // Center(
        //     child: Container(
        //   margin: EdgeInsets.all(20.0),
        //   child: Column(
        //     children: [
        //       Text(
        //         "A notification will be sent on",
        //         style: Theme.of(context).textTheme.headline6.copyWith(
        //               color: Colors.black,
        //               fontSize: 15.0,
        //               fontWeight: FontWeight.w200,
        //             ),
        //       ),
        //       Text(
        //         "${DateFormat.yMMMd().format(model.day)} @ ${DateFormat.jm().format(model.time)}",
        //         style: Theme.of(context).textTheme.headline6.copyWith(
        //               color: Colors.black,
        //               fontSize: 20.0,
        //               fontWeight: FontWeight.w200,
        //             ),
        //       ),
        //     ],
        //   ),
        // ))
      ],
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.blueGrey[50].withAlpha(200),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
