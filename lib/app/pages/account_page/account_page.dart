import 'package:fari/app/custom_widgets/top_bar/top_bar.dart';
import 'package:fari/app/custom_widgets/top_bar/top_bar_button.dart';
import 'package:fari/services/auth.dart';
import 'package:fari/services/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final database = Provider.of<Database>(context);
    final user = Provider.of<User>(context);

    return Stack(
      children: <Widget>[
        Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.blueGrey[50],
          appBar: _buildTopBar(),
          body: _buildContent(context),
        ),
      ],
    );
  }

  /// UI methods

 Widget _buildTopBar() {
    return TopBar(
      title: "Account",
      actions: <TopBarButton>[
        TopBarButton(
          text: "Settings", 
          icon: FontAwesomeIcons.cog,
          onTap: () {}
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildNameSection(context),
        SizedBox(height: 150.0,),
      ],
    );
  }

  Widget _buildNameSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(150),
            offset: Offset(0.0, 5.0),
            spreadRadius: -10.0,
            blurRadius: 15.0
          ),
        ]
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(5.0)
              // shape: BoxShape.circle
            ),
            child: Center(
              child: Text(
                "D",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0
                ),
              ),
            ),
          ),
          SizedBox(width: 20.0,),
          Container(
            child: Text(
              "Daniil Grodskiy",
              style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }


}