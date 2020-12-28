import 'package:fari/app/pages/sign_in_page/email_sign_in_model.dart';
import 'package:flutter/foundation.dart';
import 'package:fari/app/pages/sign_in_page/validators.dart';
import 'package:fari/services/auth.dart';


class EmailSignInFormModel with EmailAndPasswordValidators, ChangeNotifier {
  // NOTE THAT THIS CLASS USES ChangeNotifier AS A MIXIN!
  // In this case of state management, there are not streams! Using the Provider pattern with ChangeNotifierProvider and feeding in consumers into it is simpler than using the BLoC pattern. For one, there is only one model class in the Provider pattern, and each model class exists as only one instance of an object in which you change the properties of.
  // For the BLoC pattern, there is a constant stream of a model class via a StreamController, meaning that you need to separate the model class from the bloc class.
  EmailSignInFormModel({
    @required this.auth,
    this.email = '', 
    this.password = '', 
    this.formType = EmailSignInFormType.signIn, 
    this.isLoading = false, 
    this.submitted = false
  });

  final AuthBase auth;
  String email;
  String password;
  EmailSignInFormType formType;
  bool isLoading;
  bool submitted;

  Future<void> submit() async {
    // Called when form is submitted

    // Update the _model to change its state; the form is now submitted and loading
    updateWith(submitted: true, isLoading: true);

    try {
      if (this.formType == EmailSignInFormType.signIn) {
        // Signing in
        await auth.signInWithEmailAndPassword(this.email, this.password);
      } else {
        // Registering
        await auth.createUserWithEmailAndPassword(this.email, this.password);
      }
    } catch(e) {
      updateWith(isLoading: false);
      // By RETHROWING the error, we show the error in a PlatfrormAlertExceptionDialog (which extends PlatformAlertDialog) 
      rethrow;
    }
  }

  String get primaryButtonText {
    return formType == EmailSignInFormType.signIn ? "Sign in" : "Create an account";
  }

  String get secondaryText {
    return formType == EmailSignInFormType.signIn ? "Need an account? Register" : "Have an account? Sign in";
  }

  bool get canSubmit {
      return emailValidator.isValid(email) && emailValidator.isValid(password) && !isLoading;
  }

  String get emailErrorText {
    bool showErrorText = submitted && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : null;
  }

  String get passwordErrorText {
    bool showErrorText = submitted && !passwordValidator.isValid(email);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  void toggleFormType() {
    // Updates the model stream by resetting everything

    // Just makes it a bit easier to read if we extract formType
    final formType = this.formType == EmailSignInFormType.signIn ? EmailSignInFormType.register : EmailSignInFormType.signIn;

    updateWith(
      email: '',
      password: '',
      submitted: false,
      isLoading: false,
      formType: formType,
    );
  }

  // Some convenient methods to make things easier and the code look cleaner inside of 'email_sign_in_form_bloc.dart'
  void updateEmail(String email) => updateWith(email:  email);
  void updatePassword(String password) => updateWith(password: password);

  // Updates the model object
  void updateWith({
    String email,
    String password,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
      this.email = email ?? this.email;
      this.password = password ?? this.password;
      this.formType = formType ?? this.formType;
      this.isLoading = isLoading ?? this.isLoading;
      this.submitted = submitted ?? this.submitted;

      // VERY IMPORTANT! This is what tells the ChangeNotifierProvider(...) to actually rebuild the widget tree!
      notifyListeners();
  }

}