import 'package:flutter/material.dart';

enum SortType {
  Alphabetically,
  DueDate,
  DateCreation,
  Category
}

class SortTasksBottomSheet extends StatefulWidget {
  SortTasksBottomSheet({
    @required this.onTap,
    @required this.currentSortType,
    @required this.showCategoryOption
  });

  final Function(SortType sortType) onTap;
  final SortType currentSortType;
  final bool showCategoryOption;
  
  @override
  _SortTasksBottomSheetState createState() => _SortTasksBottomSheetState();
}

class _SortTasksBottomSheetState extends State<SortTasksBottomSheet> {
  // TODO: Convert into a StatelessWidget (I only have it as Stateful so that it updates automatically when I change something)

  /// Getter methods
  
  Function(SortType sortType) get onTap => widget.onTap;
  SortType get currentSortType => widget.currentSortType;

  /// Builder method
  
  @override
  Widget build(BuildContext context) => _buildContents();

  Widget _buildContents() {
    return Container(
      padding: EdgeInsets.all(20.0),
      height: 450.0,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          SizedBox(height: 10.0,),
          _buildFilterByButton(title: "By due date", sortType: SortType.DueDate),
          _buildFilterByButton(title: "By date created", sortType: SortType.DateCreation),
          _buildFilterByButton(title: "Alphabetically", sortType: SortType.Alphabetically),
          widget.showCategoryOption ? _buildFilterByButton(title: "By category", sortType: SortType.Category) : Container(),
        ],
      ),
    );
  }

  /// UI methods

  Widget _buildHeader() {
    return Text(
      "Sort",
      style: Theme.of(context).textTheme.headline2
    );
  }

  Widget _buildFilterByButton({
    @required title,
    @required SortType sortType,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () => onTap(sortType), 
            // Will always be  Navigator.pop(context); and model.updateSortType(newSortType); in the main class calling this sheet
            // IMPORTANT: OKAY a little confusing possibly! So we're actually going to call the 'onTap' method that we pass into this class and pass in the parameter that's in this button (basically we're passing in the button type to the model in TasksPage whenever we click on a button)
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                border: sortType == currentSortType 
                  ? Border.all(
                      color: Colors.indigo[400],
                      width: 3.0 ,
                    )
                  : Border.all( 
                    // Adding an actual border instead of just 'null' to this ternary because then there won't be a slight resizing of the boxes themselves when we tap on a new option
                      color: Colors.transparent,
                      width: 3.0 ,
                    ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    offset: Offset(0.0, 10.0),
                    blurRadius: 5.0,
                    spreadRadius: -5.0
                  )
                ]
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16.0)
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}