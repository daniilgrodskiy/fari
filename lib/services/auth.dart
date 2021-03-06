import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:fari/services/apple_sign_in_available.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  User(
      {@required this.uid,
      @required this.photoUrl,
      @required this.displayName});

  final String uid;
  final String photoUrl;
  final String displayName;
}

// PROVIDER USED BY CERTAIN WIDGETS IN THE APP
abstract class AuthBase {
  Stream<User> get onAuthStateChanged;
  Future<User> currentUser();
  // Future<User> signInWithEmailAndPassword(String email, String password);
  // Future<User> createUserWithEmailAndPassword(String email, String password);
  // Future<User> signInAnonymously();
  Future<User> signInWithGoogle();
  Future<User> signInWithApple({List<Scope> scopes});
  Future<void> signOut();
}

class Auth implements AuthBase {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  User _userFromFirebase(auth.User user) {
    // Converts a auth.auth.User type into a User type
    if (user == null) {
      return null;
    }

    return User(
        uid: user.uid, displayName: user.displayName, photoUrl: user.photoURL);
  }

  @override
  Stream<User> get onAuthStateChanged {
    // Creates a stream from the original stream that would update whenever the state of our authentication changes
    // '.map' changes each element from auth.auth.User to User
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<User> currentUser() async {
    // Creates a new User from auth.auth.User
    final auth.User user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  // @override
  // Future<User> signInAnonymously() async {
  //   // Signs in and returns a User from auth.auth.User
  //   final auth.UserCredential authResult =
  //       await _firebaseAuth.signInAnonymously();
  //   return _userFromFirebase(authResult.user);
  // }

  // @override
  // Future<User> signInWithEmailAndPassword(String email, String password) async {
  //   // Signs in through a standard email and a password
  //   final auth.UserCredential authResult = await _firebaseAuth
  //       .signInWithEmailAndPassword(email: email, password: password);
  //   return _userFromFirebase(authResult.user);
  // }

  // @override
  // Future<User> createUserWithEmailAndPassword(
  //     String email, String password) async {
  //   // Creates a new user from an email and a password
  //   final auth.UserCredential authResult = await _firebaseAuth
  //       .createUserWithEmailAndPassword(email: email, password: password);
  //   return _userFromFirebase(authResult.user);
  // }

  @override
  Future<User> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleAccount;
    try {
      googleAccount = await googleSignIn.signIn();
    } catch (e) {
      throw PlatformException(
          code: 'ERROR LOGGING IN', message: 'There was an error logging in!');
    }
    if (googleAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        // Checks to see if our accessToken and idToken exists
        final auth.UserCredential authResult =
            await _firebaseAuth.signInWithCredential(
                // We want to sign in through Firebase, so we're going to pass our credentials through Firebase
                auth.GoogleAuthProvider.credential(
                    idToken: googleAuth.idToken,
                    accessToken: googleAuth.accessToken));
        // Returning a User from our auth.auth.User
        return _userFromFirebase(authResult.user);
      } else {
        throw PlatformException(
            code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
            message: 'Missing Google Auth Token');
      }
    } else {
      throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
    }
  }

  @override
  Future<User> signInWithApple({List<Scope> scopes = const []}) async {
    // 1. perform the sign-in request
    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = authResult.user;
        if (scopes.contains(Scope.fullName)) {
          final displayName =
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          print("Display name: " + displayName);
          await firebaseUser.updateProfile(displayName: displayName);
        }
        return _userFromFirebase(firebaseUser);
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      // case AuthorizationStatus.cancelled:
      //   throw PlatformException(
      //     code: 'ERROR_ABORTED_BY_USER',
      //     message: 'Sign in aborted by user',
      //   );
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut() async {
    // Signs out through Google if needed (I think _firebaseAuth.signOut() takes care of it now though?)
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    await googleSignIn.signOut();
    // Signs out the current Firebase user
    await _firebaseAuth.signOut();
  }
}
