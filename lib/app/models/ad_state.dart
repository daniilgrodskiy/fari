import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initalization;

  AdState(this.initalization);

  // Test banner ad unit id: ca-app-pub-3940256099942544/2934735716
  String get bannerAdUnitId => "ca-app-pub-3446106133887966/6536853537";
  String get nativeUnitId => "ca-app-pub-3940256099942544/3986624511";

  BannerAdListener get adListener => BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an ad is in the process of leaving the application.
        // onApplicationExit: (Ad ad) => print('Left application.'),
      );
}
