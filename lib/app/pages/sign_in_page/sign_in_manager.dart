import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fari/services/auth.dart';

class SignInManager {
  SignInManager({
    @required this.auth, 
    @required this.isLoading
  });
  
  final AuthBase auth;
  final ValueNotifier<bool> isLoading;

  Future<User> _signIn(Future<User> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
      // We only need to set the _isLoading to false when the loading FAILS! If it succeeds the whole state gets reset anyways and we navigate into a new screen; no need to change the stream AND there's also a bug with trying to change the state after the stream gets disposed (it gets closed because our state gets reset)
    } catch(e) {
      isLoading.value = false;
      rethrow;
      // Bubbles up the throw and causes a PlatformException error to be accounted for via the signIn() method existing inside of 'SignInPage()'
    }
  }

  Future<User> signInAnonymously() async => await _signIn(auth.signInAnonymously);

  Future<User> signInWithGoogle() async => await _signIn(auth.signInWithGoogle);
}
