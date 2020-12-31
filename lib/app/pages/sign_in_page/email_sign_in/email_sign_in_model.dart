import 'package:fari/app/pages/sign_in_page/email_sign_in/validators.dart';

enum EmailSignInFormType{
  signIn,
  register
}

class EmailSignInModel with EmailAndPasswordValidators {
  EmailSignInModel({
    this.email = '', 
    this.password = '', 
    this.formType = EmailSignInFormType.signIn, 
    this.isLoading = false, 
    this.submitted = false
  });

  final String email;
  final String password;
  final EmailSignInFormType formType;
  final bool isLoading;
  final bool submitted;

  // UI Helper Methods
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

  // Makes a copy of the model object; used to update stream based on ONLY the values that were specified (which will only be the values changed), otherwise the null coalescing operating defaults to the previous value
  // Have to use this method that'll return an entirely new EmailSignInModel object because the values are final in this class, so there can't be some 'updateWith(...)' method that'll do that work for us
  EmailSignInModel copyWith({
    String email,
    String password,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    return new EmailSignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
      formType: formType ?? this.formType,
      isLoading: isLoading ?? this.isLoading,
      submitted: submitted ?? this.submitted
    );
  }

}