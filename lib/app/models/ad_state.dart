import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initalization;

  AdState(this.initalization);

  String get bannerAdUnitId => "ca-app-pub-3940256099942544/2934735716";
  String get nativeUnitId => "ca-app-pub-3940256099942544/3986624511";
}
