import 'package:fari/app/custom_widgets/platform_widgets/platform_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  // Class used ot show a dialog ONLY for PlatformException instances
  // Child of PlatformAlertDialog

  PlatformExceptionAlertDialog({
    @required String title,
    @required PlatformException exception,
  }) : super(
    // Calling the super class here
    title: title,
    content: _message(exception),
    defaultActionText: 'OK',
  );

  static String _message(PlatformException exception) {
    print(exception);

    if (exception.message == 'FIRFirestoreErrorDomain') {
      if (exception.code == 'Error 7') {
        return 'Missing or insufficient permissions';
      }
    }

    // Either return the value from _errors based on the 'exception.code' key or just return the default message Firebase gives you 'exception.code'
    return _errors[exception.code] ?? exception.message;
  }

  static Map<String, String> _errors = {
    // Customizes user error message based on the Firebase PlatformException errors
    ///  * `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
    ///  * `ERROR_INVALID_EMAIL` - If the email address is malformed.
    ///  * `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
    ///  * `ERROR_INVALID_EMAIL` - If the [email] address is malformed.
    'ERROR_WRONG_PASSWORD' : 'The password is invalid',
    ///  * `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address, or if the user has been deleted.
    ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
    ///  * `ERROR_TOO_MANY_REQUESTS` - If there was too many attempts to sign in as this user.
    ///  * `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  };
  
}