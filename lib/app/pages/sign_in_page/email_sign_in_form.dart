import 'package:fari/app/custom_widgets/platform_widgets/platform_exception_alert_dialog.dart';
import 'package:fari/app/pages/sign_in_page/email_sign_in_form_model..dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fari/services/auth.dart';
import 'package:flutter/services.dart';


class EmailSignInForm extends StatefulWidget {

  EmailSignInForm({@required this.model});
  final EmailSignInFormModel model;

  static Widget create(BuildContext context) {
    // Method that we'll call when we want to return this EmailSignInForm! Makes us not worry aboout passing any blocs into the class because all the blocs and the things that the blocs need can be done here!

    // IMPORTANT: Use a ValueNotifier for more 'simpler' models like just a boolean, but for complex models like we have here, ChangeNotifier would work better! ValueNotifier is an implementation of ChangeNotifier that automatically rebuilds the state for you. If you want to be able to notify listeners, then ChangeNotifier is what you should use instead! Also, ChangeNotifier allows you to use ChangeNotifierProvider more efficiently?

    // Allows the model to use the 'auth' service
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);

    return ChangeNotifierProvider<EmailSignInFormModel>(
      create: (context) => EmailSignInFormModel(auth: auth), // Creating the model
      child: Consumer<EmailSignInFormModel>(
        // Who's gonna consume our new model? Why EmailSignInForm(...), of course!
        builder: (context, model, _) => EmailSignInForm(model: model,)
      ),
    );
  }


  @override
  _EmailSignInFormChangeNotifierState createState() => _EmailSignInFormChangeNotifierState();
}

class _EmailSignInFormChangeNotifierState extends State<EmailSignInForm> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  // Declare focus for each TextField; allows to change focus node from email to password when clicking 'Next'
  final FocusNode _emailFocusNode = new FocusNode();
  final FocusNode _passwordFocusNode = new FocusNode();

  // Makes us not need to use 'widget.model' each time!
  EmailSignInFormModel get model => widget.model;

  @override
  void dispose() {
    // Called when this widget gets removed from the widget tree
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Called when the form is submitted
    try {
      await model.submit();
      Navigator.of(context).pop();
    } on PlatformException catch(e) {
      // Shows the error in a PlatfrormAlertExceptionDialog (which extends PlatformAlertDialog); will be rethrown from the 'submit()' method inside of our bloc
      PlatformExceptionAlertDialog(
        title: 'Sign in failed 😢',
        exception: e,
      ).show(context);
    }
  }

  void _emailEditingComplete() {
    // We're only able to move forward and hit 'next' if the 'email' field is valid! Otherwise, we stay on the email field.
    final newFocus = model.emailValidator.isValid(model.email) ? _passwordFocusNode : _emailFocusNode;
    // Changes focus from email to password field once editing is finished on the email TextField
    // Triggers once a user hits 'Next'
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _toggleFormType() {
    // Will toggle form type between 'signIn' and 'register'; resets the submitted form (prevents our validators like 'Email can't be empty' from still showing)
    model.toggleFormType();
    
    // IMPORTANT: If you're using a text editing controller for something, you MUST make sure it's in sync with some variables that we might have in a bloc; in this case, we want the variables to return to their default values of '' and for the controllers to reset (by using '.clear()')
    _emailController.clear();
    _passwordController.clear();
    
  }

  List<Widget> _buildChildren() {
    return [
      // Email field
      _buildEmailTextField(),
      SizedBox(height: 8.0,),
      // Password field
      _buildPasswordTextField(),
      SizedBox(height: 8.0,),
      // Sign in button      
      FlatButton(
        child: Text(model.primaryButtonText),
        onPressed: model.canSubmit ? _submit : null,
      ),
      SizedBox(height: 8.0,),
      FlatButton(
        child: Text(model.secondaryText),
        // Button will become disabled if we are loading (we're waiting for a call back from the server already)
        onPressed: !model.isLoading ? _toggleFormType : null,
      )
    ];
  }

  TextField _buildEmailTextField() {
    // Showing error text only if the form has been submitted AND our validator(s) return false

    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "test@test.com",
        errorText: model.emailErrorText,
        enabled: model.isLoading == false,
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: model.updateEmail,
      onEditingComplete: () => _emailEditingComplete(),
    );
  }

  TextField _buildPasswordTextField() {
    // Showing error text only if the form has been submitted AND our validator(s) return false
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        labelText: "Password",
        errorText: model.passwordErrorText,
        enabled: model.isLoading == false,
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: model.updatePassword,
      onEditingComplete: _submit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }
  
  
}