import 'package:fari/app/pages/calendar/calendar_page.dart';
import 'package:fari/app/pages/home_page/daily/home_page.dart';
import 'package:fari/app/pages/home_page/home_page.dart';
import 'package:fari/app/pages/sign_in_page/sign_in_page.dart';
import 'package:fari/services/auth.dart';
import 'package:fari/services/database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  
  
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    // TODO: Add a MediaQuery and textScaleFactor thing here (keep in mind this messed up all of the TextFields in the app!)
    return StreamBuilder<User>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User user = snapshot.data;
        
          if (user == null) {
            return SignInPage.create(context);
          }
          
          // VERY VERY IMPORTANT: GOD BLESS THE PROVIDER PACKAGE LOL! Just pass the user down the tree and get it from Provider.of<User>(context)! Use the '.value' method here because it's a simple value! It's going to change (and if it does, we'll know because the whole app will reset because of this StreamBuilder up here^ ;) )
          return Provider<User>.value(
            value: user,
            child: Provider<Database>(
              // IMPORTANT: Database provider created here! Database can be used anywhere in the widget tree from this point down!
              create: (_) => FirestoreDatabase(uid: user.uid),
              // child: Navigation()
              builder: (context, _) {
                return MaterialApp(
                  // TODO: Decide if this is a good idea! I'm wrapping this entire part of the app with another 'MaterialApp' because I don't want to end up passing Database to every ancestor after doing some navigation.
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
                  ),
                  home: HomePage.create(context)
                );
              },
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
    
  }
}