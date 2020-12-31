import 'package:apple_sign_in/apple_sign_in.dart' as appleSignIn;
import 'package:apple_sign_in/scope.dart';
import 'package:fari/app/custom_widgets/platform_widgets/platform_exception_alert_dialog.dart';
import 'package:fari/services/apple_sign_in_available.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fari/app/pages/sign_in_page/sign_in_manager.dart';
import 'package:fari/services/auth.dart';
import 'package:flutter/services.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({
    Key key,
    @required this.manager,
    @required this.isLoading,
  }) : super(key: key);

  final SignInManager manager;
  // We can directly get the value of isLoading based on the way we set up ChangeNotifier<ValueNotifier<bool>> and its children
  final bool isLoading;

  static Widget create(BuildContext context) {
    // ***
    // VERY IMPORTANT :) OKAY, so you can either include these 'Provider' classes INSIDE a static '.create()' method existing inside the stateful widget that'll use that respective manager/bloc (that's what we're doing here) OR you can just wrap wherever the widget is being called with a 'Provider' class (in this case it'd be inside of LandingPage())
    // If you use the static '.create()' method it honestly looks cleaner and you'll be able to separate the code better!
    // ***

    final auth = Provider.of<AuthBase>(context, listen: false);

    // The 'builder' method inside of a Consumer(...) gets rebuilt each time ValueNotifier.value changes; very similar to StreamBuilder

    // TODO: UNDERSTAND THIS _isLoading BUSINESS!
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      // Lets you create a ValueNotifier<bool> and lets you listen to it
      create: (context) => ValueNotifier<bool>(
          false), // Create the boolean ValueNotifier with a default value
      child: Consumer<ValueNotifier<bool>>(
        // Wrap the Provider in a Consumer (Consumer CONSUMES the boolean ValueNotifier)
        builder: (context, isLoading, __) => Provider<SignInManager>(
          // Return the Provider
          create: (context) => SignInManager(
              auth: auth, isLoading: isLoading), // Create the SignInManager
          child: Consumer<SignInManager>(
              // Wrap the page in a Consumer (Consumer CONSUMES the SignInManager)
              builder: (context, manager, _) =>
                  SignInPage(manager: manager, isLoading: isLoading.value)),
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(
      title: 'Sign in failed 😢',
      exception: exception,
    ).show(context);
  }

  // // SIGN IN METHODS
  // Future<void> _signInAnonymously(BuildContext context) async {
  //   try {
  //     await manager.signInAnonymously();
  //   } on PlatformException catch (e) {
  //     _showSignInError(context, e);
  //   }
  // }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await manager.signInWithGoogle();
    } on PlatformException catch (e) {
      // if (e.code != 'ERROR_ABORTED_BY_USER') {
      //   // If the user only exited out of the Google sign in prompt, we do NOT want to show an error
      //   _showSignInError(context, e);
      // }
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<AuthBase>(context, listen: false);

      final List<Scope> scopes = [
        appleSignIn.Scope.email,
        appleSignIn.Scope.fullName
      ];

      final user = await authService.signInWithApple(scopes: scopes);
      print('uid: ${user.uid}');
    } catch (e) {
      print(e);
    }
  }

  // void _signInWithEmail(BuildContext context) {
  //   Navigator.of(context).push(MaterialPageRoute<void>(
  //       fullscreenDialog: true,
  //       builder: (BuildContext context) => EmailSignInPage()));
  // }

  @override
  Widget build(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _buildContent(context, appleSignInAvailable),
    );
  }

  Widget _buildContent(
      BuildContext context, AppleSignInAvailable appleSignInAvailable) {
    return Padding(
      // color: Colors.yellow,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 175.0,
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "./assets/launch_screen.png",
                ),
              ),
            ),
            height: 100.0,
            width: 250.0,
          ),
          Text(
            "The simple task app for all your needs!",
            style: Theme.of(context).textTheme.headline6.copyWith(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w200,
                ),
          ),
          SizedBox(
            height: 250.0,
          ),
          GestureDetector(
            onTap: () => _signInWithGoogle(context),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          "./assets/google_logo.png",
                        ),
                      ),
                    ),
                    height: 25.0,
                    width: 25.0,
                  ),
                  SizedBox(
                    width: 18.0,
                  ),
                  Text("Sign in with Google")
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0),
          GestureDetector(
            onTap: () => _signInWithApple(context),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.0)),
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          "./assets/apple_logo.png",
                        ),
                      ),
                    ),
                    height: 25.0,
                    width: 25.0,
                  ),
                  SizedBox(
                    width: 18.0,
                  ),
                  Text(
                    "Sign in with Apple",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),

          Spacer(),
          // SizedBox(height: 50.0, child: _builderHeader(context)),
          // Google sign in
          // GestureDetector(
          //     onTap: isLoading ? null : () => _signInWithGoogle(context),
          //     child: Container(
          //         width: 20.0,
          //         child: Row(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Image.asset(
          //               "./assets/google_logo.png",
          //               scale: 0.1,
          //             ),
          //             Text("Sign in with Google")
          //           ],
          //         ))),
          // Apple sign in
          // if (appleSignInAvailable.isAvailable)
          //   appleSignIn.AppleSignInButton(
          //     style: appleSignIn.ButtonStyle.black,
          //     type: appleSignIn.ButtonType.signIn,
          //     onPressed: () => _signInWithApple(context),
          //   ),
          // Email sign in
          // FlatButton(
          //   onPressed: isLoading ? null : () => _signInWithEmail(context),
          //   child: Text('Sign in with email'),
          // ),
          // SizedBox(height: 8.0),
          // Text(
          //   "or",
          //   style: TextStyle(fontSize: 14.0, color: Colors.black87),
          //   textAlign: TextAlign.center,
          // ),
          // SizedBox(height: 8.0),
          // // Anyonymous sign in
          // FlatButton(
          //   onPressed: isLoading ? null : () => _signInAnonymously(context),
          //   child: Text('Go anonymous'),
          // ),
          Text(
            "\u00a9 Daniil Grodskiy",
            style: Theme.of(context).textTheme.headline6.copyWith(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                ),
          ),
          SizedBox(height: 15.0),
        ],
      ),
    );
  }

  Widget _buildButton() {}

  Widget _builderHeader(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      'Sign In',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline6.copyWith(
            color: Colors.black,
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
