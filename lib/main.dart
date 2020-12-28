import 'package:fari/app/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:fari/services/auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black, // '.white' : white status bar for Android
      statusBarBrightness: Brightness.light // '.dark' : white status bar for IOS.
    )
  );

  runApp(MyApp());
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
                fontWeight: FontWeight.w600
              ),
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