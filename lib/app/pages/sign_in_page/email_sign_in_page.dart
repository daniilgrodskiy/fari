import 'package:fari/app/pages/sign_in_page/email_sign_in_form.dart';
import 'package:flutter/material.dart';

class EmailSignInPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: EmailSignInForm.create(context)
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],

    );
  }

}