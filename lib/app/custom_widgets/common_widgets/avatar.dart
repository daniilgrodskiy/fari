import 'package:fari/services/auth.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {

  Avatar({
    this.user,
    @required this.radius
  });
  
  final User user;
  final double radius;
  

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.indigo[700],
      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl) : null, // Will only have a backgroundImage if we have a photoUrl
      child: user.photoUrl == null 
        ? Text(
          user.displayName?.substring(0, 1) ?? "D",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ) 
        : null, // No photoUrl => Show a camera icon!
    );
  }
}