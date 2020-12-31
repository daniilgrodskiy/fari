// File will contain general validators for froms

abstract class StringValidator {
  // Abstract class that will contain various methods for string validation
  bool isValid(String value);
}

class NonEmptyStringValidator implements StringValidator {
  // An example of one specific validator that will deal with making sure strings are not empty

  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class EmailAndPasswordValidators {
  // General validators for an email and password form
  final StringValidator emailValidator = new NonEmptyStringValidator();
  final StringValidator passwordValidator = new NonEmptyStringValidator();

  // Error text
  final String invalidEmailErrorText = 'Email can\'t be empty';
  final String invalidPasswordErrorText = 'Password can\'t be empty';

}