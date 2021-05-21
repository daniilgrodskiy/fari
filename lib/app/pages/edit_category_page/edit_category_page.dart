import 'package:fari/app/custom_widgets/common_widgets/custom_text_field.dart';
import 'package:fari/app/custom_widgets/platform_widgets/platform_alert_dialog.dart';
import 'package:fari/app/custom_widgets/platform_widgets/platform_exception_alert_dialog.dart';
import 'package:fari/app/custom_widgets/top_bar/top_bar.dart';
import 'package:fari/app/hex_color.dart';
import 'package:fari/app/models/category.dart';
import 'package:fari/app/pages/edit_category_page/edit_category_page_model.dart';
import 'package:fari/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class EditCategoryPage extends StatefulWidget {
  final Category category;
  final Database database;
  final EditCategoryPageModel model;

  const EditCategoryPage({
    this.category,
    @required this.database,
    @required this.model,
  });

  static Future<void> show(BuildContext context,
      {Category category, Database database}) async {
    // Returning 'bool' because we want to give feedback to whether or not the category has been deleted (if Navigator ever returns true, then the category has been deleted)
    // IMPORTANT: When navigating from a page that came from the MaterialPage (EditTaskPage -> EditCategoryPage), Database cannot be retrieved via a Provider and MUST be passed in because it no longer exists as an ancestor of the page
    if (database == null) {
      database = Provider.of<Database>(context, listen: false);
    }

    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      fullscreenDialog: true, // slides from the bottom
      builder: (context) => ChangeNotifierProvider<EditCategoryPageModel>(
        create: (context) {
          if (category == null) {
            // New category
            return new EditCategoryPageModel(
              database: database,
            );
          }
          return new EditCategoryPageModel(
              database: database,
              id: category.id,
              name: category.name,
              color: category.color);
        },
        child: Consumer<EditCategoryPageModel>(
          builder: (context, model, _) => EditCategoryPage(
            category: category,
            database: database,
            model: model,
          ),
        ),
      ),
    ));
  }

  @override
  _EditCategoryPageState createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  /// Instance variables

  final _nameController = TextEditingController();
  final _categoryColors = [
    "1abc9c",
    "2ecc71",
    "3498db",
    "9b59b6",
    "34495e",
    "f1c40f",
    "e67e22",
    "e74c3c",
    "95a5a6",
  ];
  ScrollController _listViewScrollController;

  /// Getter methods

  Category get category => widget.category;
  EditCategoryPageModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    _nameController.text = category?.name;

    _listViewScrollController = new ScrollController();
    _listViewScrollController.addListener(() {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _listViewScrollController.dispose();
  }

  //// Service methods

  Future<void> _submit() async {
    // Called when the form is submitted
    try {
      await model.submit();
      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      // Shows the error in a PlatfrormAlertExceptionDialog (which extends PlatformAlertDialog); will be rethrown from the 'submit()' method inside of our bloc

      // IMPORTANT: Don't forget to always change 'isLoading' back to false after throwing an error!
      model.updateWith(isLoading: false);
      PlatformExceptionAlertDialog(
        title: category == null
            ? "Unable to create new category 😞"
            : "Unable to save category 😞",
        exception: e,
      ).show(context);
    }
  }

  Future<void> _delete(Category category) async {
    // Called when user wants to delete a task
    try {
      bool isQuitting = await PlatformAlertDialog(
        title: "Are you sure you want to delete this category?",
        content: "No tasks will be deleted. This action cannot be undone.",
        defaultActionText: "Yes",
        cancelActionText: "No",
      ).show(context);

      if (isQuitting) {
        await model.deleteCategory(category);
        // Pop twice!
        Navigator.of(context)..pop()..pop();
      }
    } on PlatformException catch (e) {
      model.updateWith(isLoading: false);
      PlatformExceptionAlertDialog(
        title: "Unable to delete category 😞",
        exception: e,
      ).show(context);
    }
  }

  /// BUILD METHOD

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          resizeToAvoidBottomInset: false,
          // backgroundColor: Colors.grey[50],
          // backgroundColor: HexColor(model.color).withAlpha(10),
          appBar: TopBar.empty(),
          body: Stack(
            children: <Widget>[
              ListView(
                controller: _listViewScrollController,
                children: <Widget>[
                  SizedBox(
                    height: 30.0,
                  ),
                  _buildHeading(),
                  SizedBox(
                    height: 20.0,
                  ),
                  _buildForm(),
                  if (category != null) _buildDeleteButton(),
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
          // TODO: Uncomment this part and only show dialog if it's a created category that's been altered (we'd check once we put this top bar in a separate class and pass in "model")
          // bool isQuitting =  await PlatformAlertDialog(
          //   title: "Are you want to quit?",
          //   content: "Changes will not be saved.",
          //   defaultActionText: "Yes",
          //   cancelActionText: "No",
          // ).show(context);

          // if (isQuitting)
          Navigator.of(context).pop();
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
        category?.name == null || category?.name == ""
            ? "New category"
            : category.name,
        style: Theme.of(context).textTheme.headline6.copyWith(
              color: Colors.indigo,
              fontWeight: FontWeight.w700,
              fontSize: 25.0,
            ),
      ),
    );
  }

  Widget _buildTextFieldHeading(String title) {
    return Container(
      margin: EdgeInsets.only(left: 20.0, bottom: 15.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline6.copyWith(
              color: Colors.black.withAlpha(200),
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Name
        _buildTextFieldHeading("Name"),
        CustomTextField(
          enabled: model.isLoading == false,
          controller: _nameController,
          hintText: "\"School\"",
          textInputAction: TextInputAction.done,
          maxLength: 40,
          minLines: 1,
          maxLines: 3,
          onChanged: model.updateName,
        ),
        SizedBox(
          height: 40.0,
        ),
        _buildColors(),
      ],
    );
  }

  Widget _buildColors() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTextFieldHeading("Color"),
          // Actual colors
          Container(
            child: GridView.count(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 50.0),
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                crossAxisSpacing: 20,
                mainAxisSpacing: 10,
                crossAxisCount: 5,
                children: List.generate(_categoryColors.length,
                    (index) => _buildColorWidget(index))),
          ),
        ],
      ),
    );
  }

  Widget _buildColorWidget(int index) {
    final isSelected = model.color == _categoryColors[index];

    return GestureDetector(
      onTap: () => model.updateColor(_categoryColors[index]),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: HexColor(_categoryColors[index]),
          boxShadow: [
            BoxShadow(
                color: HexColor(_categoryColors[index]).withAlpha(100),
                offset: Offset(0.0, 10.0),
                spreadRadius: -5.0,
                blurRadius: 5.0),
          ],
          // shape: BoxShape.circle,
        ),
        child: isSelected
            ? Container(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        color: Colors.green[100],
                        // borderRadius: BorderRadius.circular(5.0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green[800].withAlpha(100),
                            offset: Offset(0.0, 6.0),
                            blurRadius: 5.0,
                            spreadRadius: -3.0,
                          ),
                        ]),
                    child: Icon(
                      FontAwesomeIcons.check,
                      color: Colors.green[400],
                      size: 20,
                    ),
                  ),
                ),
              )
            : Container(),
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
                // If the passed in category is null -> we're creating a category
                // If the passed in category exists -> we're editing a category
                category == null ? "Create category" : "Save category",
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

  Widget _buildDeleteButton() {
    return Center(
      child: GestureDetector(
        onTap: () => _delete(category),
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
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Center(
            child: Text(
              "Delete category",
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

  Widget _buildOverlay() {
    return Container(
      color: Colors.blueGrey[50].withAlpha(200),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
