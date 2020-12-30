class ToggleModel {
  ToggleModel({
    this.showDescription,
    this.showCategories,
    this.showDay,
    this.showTime,
  });

  bool showDescription;
  bool showCategories;
  bool showDay;
  bool showTime;

  /// Convenient methods

  // Updates the model object
  void update({ToggleModel newToggleModel}) {
    // Either update 'this' object using the properties of 'newToggleModel' or if they're null, use the original properties
    this.showDescription =
        newToggleModel.showDescription ?? this.showDescription;
    this.showCategories = newToggleModel.showCategories ?? this.showCategories;
    this.showDay = newToggleModel.showDay ?? this.showDay;
    this.showTime = newToggleModel.showTime ?? this.showTime;
  }
}
