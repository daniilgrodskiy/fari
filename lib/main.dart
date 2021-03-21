import 'package:fari/app/landing_page.dart';
import 'package:fari/app/models/ad_state.dart';
import 'package:fari/services/apple_sign_in_available.dart';
// import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fari/services/auth.dart';
// import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black, // '.white' : white status bar for Android
      statusBarBrightness:
          Brightness.light // '.dark' : white status bar for IOS.
      ));

  await Firebase.initializeApp();
  // await FirebaseAdMob.instance
  //     .initialize(appId: "ca-app-pub-3446106133887966~5236144498");

  // await MobileAds.initialize(
  //   useHybridComposition: true,
  //   nativeAdUnitId: "ca-app-pub-3446106133887966/3808965450",
  // );

  // await MobileAds.requestTrackingAuthorization();

  final appleSignInAvailable = await AppleSignInAvailable.check();

  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);

  runApp(Provider<AppleSignInAvailable>.value(
    value: appleSignInAvailable,
    child: Provider<AdState>.value(
        value: adState, builder: (context, child) => MyApp()),
  ));
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Provider<AuthBase>(
        create: (context) => new Auth(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fari',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            textTheme: TextTheme(
              bodyText1: GoogleFonts.inter(),
              bodyText2: GoogleFonts.inter(),
              headline1: GoogleFonts.inter(
                color: Colors.black.withAlpha(200),
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
              headline2: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.w700,
              ),
              headline3: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
              headline4: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600),
              // DON'T CHANGE 'headline6:'
            ),
            // fontFamily: "helvetica",
          ),
          home: LandingPage(),
        ),
      ),
    );
  }
}
