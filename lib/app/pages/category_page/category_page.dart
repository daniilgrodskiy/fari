import 'package:fari/app/custom_widgets/common_widgets/add_button.dart';
import 'package:fari/app/custom_widgets/common_widgets/task_widget.dart';
import 'package:fari/app/custom_widgets/top_bar/search_bar.dart';
import 'package:fari/app/custom_widgets/top_bar/top_bar.dart';
import 'package:fari/app/models/ad_state.dart';
import 'package:fari/app/models/category.dart';
import 'package:fari/app/models/task.dart';
import 'package:fari/app/pages/category_page/category_page_model.dart';
import 'package:fari/app/pages/edit_category_page/edit_category_page.dart';
import 'package:fari/app/pages/edit_task_page.dart/edit_task_page.dart';
import 'package:fari/services/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({
    @required this.model,
    @required
        this.database, // Only passing database in for EditCategoryPage(...)
    @required this.tasks,
    @required this.category,
  });

  final CategoryPageModel model;
  final Database database;
  final List<Task> tasks;
  final Category category;

  static Future<void> create(BuildContext context,
      {@required Category category}) async {
    final database = Provider.of<Database>(context, listen: false);

    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (context) => StreamBuilder<List<Task>>(
            // FOUND IT! -> 'categoryId: category.id' causes flickering!
            stream: database.tasksStream(categoryId: category.id),
            // stream: database.tasksStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final tasks = snapshot.data;
                // tasks.removeWhere((c) => c.categoryId != category.id);
                return ChangeNotifierProvider<CategoryPageModel>(
                  create: (context) => CategoryPageModel(),
                  child:
                      Consumer<CategoryPageModel>(builder: (context, model, _) {
                    return CategoryPage(
                      database: database,
                      model: model,
                      tasks: tasks,
                      category: new Category(
                          id: "2020-12-31T02:07:36.887095",
                          name: "School",
                          color: "2ecc71"),
                    );
                  }),
                );
              }
              return Container();
            })));

    // Get category
    // await Navigator.of(context, rootNavigator: true).push(
    //   MaterialPageRoute(builder: (context) {
    //     return StreamBuilder<Category>(
    //         stream: database.categoryStream(categoryId: category.id),
    //         builder: (context, categorySnapshot) {
    //           if (categorySnapshot.hasError) {
    //             // Will only show when Category has been deleted
    //             return Scaffold(
    //               appBar: TopBar(
    //                 hasBackButton: true,
    //               ),
    //               body: Center(
    //                 child: Text(
    //                   "Error retrieving category.",
    //                   textAlign: TextAlign.center,
    //                   style: Theme.of(context).textTheme.headline6.copyWith(
    //                         fontWeight: FontWeight.w500,
    //                         color: Colors.black,
    //                         fontSize: 15.0,
    //                       ),
    //                 ),
    //               ),
    //             );
    //           }
    //           if (categorySnapshot.hasData) {
    //             // Get tasks
    //             return StreamBuilder<List<Task>>(
    //                 stream: database.tasksStream(categoryId: category.id),
    //                 builder: (context, tasksSnapshot) {
    //                   if (tasksSnapshot.hasData) {
    //                     return ChangeNotifierProvider<CategoryPageModel>(
    //                       create: (context) => CategoryPageModel(),
    //                       child: Consumer<CategoryPageModel>(
    //                           builder: (context, model, _) {
    //                         // return CategoryPage();
    //                         return CategoryPage(
    //                           database: database,
    //                           model: model,
    //                           tasks: tasksSnapshot.data,
    //                           // category: new Category(
    //                           //     id: "2020-12-31T02:07:36.887095",
    //                           //     name: "School",
    //                           //     color: "2ecc71"),
    //                           category: categorySnapshot.data,
    //                         );
    //                       }),
    //                     );
    //                   }
    //                   return Scaffold(
    //                     resizeToAvoidBottomInset: false,
    //                     extendBodyBehindAppBar: true,
    //                     // appBar: _buildTopBar(context),
    //                     backgroundColor: Colors.grey[50],
    //                   );
    //                 });
    //           }
    //           return Scaffold(
    //             resizeToAvoidBottomInset: false,
    //             extendBodyBehindAppBar: true,
    //             // appBar: _buildTopBar(context),
    //             backgroundColor: Colors.grey[50],
    //           );
    //         });
    //   }),
    // );
  }

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  /// Build method

  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: _buildTopBar(context),
    //   // backgroundColor: Colors.blue,
    //   backgroundColor: Colors.grey[50],
    // );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: _buildTopBar(context),
      body: Stack(
        children: <Widget>[
          _buildContent(context),
          AddButton(
            onTap: () => EditTaskPage.show(context,
                category: widget.category, database: widget.database),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return TopBar.searchBarOnly(
      context,
      SearchBar(
          hintText: "Search tasks in '${widget.category.name}'",
          onChanged: widget.model.updateSearch),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        _buildHeader(context),
        SizedBox(
          height: 20.0,
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
        SizedBox(
          height: 20.0,
        ),
        _buildTasks(),
        SizedBox(
          height: 150.0,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Text(
                      widget.category.name,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black.withAlpha(200),
                            fontWeight: FontWeight.w700,
                            fontSize: 30.0,
                          ),
                    ),
                  ],
                ),
                Text(
                  (widget.tasks.length.toString() ?? "No ") +
                      (widget.tasks.length == 1 ? " task" : " tasks"),
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.black.withAlpha(150),
                        fontWeight: FontWeight.w400,
                        fontSize: 15.0,
                      ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              EditCategoryPage.show(context,
                  category: widget.category, database: widget.database);
            },
            child: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                  color: Colors.indigo[400],
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
                FontAwesomeIcons.pencilAlt,
                color: Colors.white,
                size: 15.0,
              ),
            ),
          ),
        ],
      ),
    );

    // Spacer(),
    // GestureDetector(
    //   onTap: () {
    //     showModalBottomSheet(
    //       context: context,
    //       backgroundColor: Colors.transparent,
    //       useRootNavigator: true,
    //       builder: (context) => SortTasksBottomSheet(
    //         showCategoryOption: false,
    //         currentSortType: model.sortType,
    //         onTap: (newSortType) {
    //           Navigator.pop(context);
    //           model.updateSortType(newSortType);
    //         },
    //       )
    //     );
    //   },
    //   child: Container(
    //     padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    //     decoration: BoxDecoration(
    //       color: Colors.indigo[400],
    //       borderRadius: BorderRadius.circular(5.0),
    //     ),
    //     child: Text(
    //       "Sort",
    //       style: Theme.of(context).textTheme.headline6.copyWith(
    //         color: Colors.white,
    //         fontSize: 15.0
    //       ),
    //     ),
    //   ),
    // ),
    // SizedBox(width: 10.0,),
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
  }

  Widget _buildEditButton(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom,
      right: 80.0,
      child: GestureDetector(
        onTap: () {
          EditCategoryPage.show(context,
              category: widget.category, database: widget.database);
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

  Widget _buildTasks() {
    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) =>
            // I'M SO HAPPY LMAOOO ONLY SHOW TASKS THAT MATCH UP BY NAME BRO I WAS TRYING TO QUERY THE WHOLE DAMN DATABASE OMG THANK GOD I REALIZED THIS WAY WORKS TOO OMG IM SO HAPPY BC I REALIZED THAT BECAUSE WE RESET THE PAGE EACH TIME, THE MODEL AUTOMATICALLY QUERIES EACH TIME WE SEARCH SOMETHING NEW UP (BAD BAD BAD)
            widget.tasks[index].name
                        .toLowerCase()
                        .contains(widget.model.search.toLowerCase()) ||
                    (widget.tasks[index].description != null &&
                        widget.tasks[index].description
                            .toLowerCase()
                            .contains(widget.model.search.toLowerCase()))
                ? TaskWidget(
                    task: widget.tasks[index],
                    database: widget.database,
                    showDate: true,
                  )
                : Container());
  }
}
