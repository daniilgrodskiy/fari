import 'package:fari/app/custom_widgets/platform_widgets/platform_exception_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fari/app/pages/sign_in_page/email_sign_in_page.dart';
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

  // SIGN IN METHODS
  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await manager.signInAnonymously();
    } on PlatformException catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await manager.signInWithGoogle();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        // If the user only exited out of the Google sign in prompt, we do NOT want to show an error
        _showSignInError(context, e);
      }
    }
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext context) => EmailSignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      // color: Colors.yellow,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 50.0, child: _builderHeader(context)),
          SizedBox(height: 48.0),
          // Google sign in
          FlatButton(
            onPressed: isLoading ? null : () => _signInWithGoogle(context),
            child: Text('Sign in with Google'),
          ),
          SizedBox(height: 8.0),
          // Email sign in
          FlatButton(
            onPressed: isLoading ? null : () => _signInWithEmail(context),
            child: Text('Sign in with email'),
          ),
          SizedBox(height: 8.0),
          Text(
            "or",
            style: TextStyle(fontSize: 14.0, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          // Anyonymous sign in
          FlatButton(
            onPressed: isLoading ? null : () => _signInAnonymously(context),
            child: Text('Go anonymous'),
          ),
        ],
      ),
    );
  }

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
