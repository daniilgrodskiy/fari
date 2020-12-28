import 'package:flutter/material.dart';

class TopBarButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  TopBarButton({
    @required this.text,
    @required this.icon, 
    @required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              offset: Offset(0.0, 2.0),
              blurRadius: 15.0,
            ),
          ]
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0,),
        margin: EdgeInsets.only(left: 10.0), // For spacing between buttons
        child: Row(
          children: <Widget>[
            // Text
            Text(
              text,
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(width: 8.0,),
            // Icon
            Container(
              width: 25.0,
              height: 25.0,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Icon(icon, color: Colors.black, size: 12.0,)
            ),
          ],
        ),
      ),
    );
  }
}