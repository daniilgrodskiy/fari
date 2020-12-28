import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchBar extends StatefulWidget {
  final Function(String) onChanged;
  final String hintText;

  const SearchBar({
    @required this.onChanged, // Should always be 'model.updateSearch'
    @required this.hintText
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _searchController = new TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildSearchBar();
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        // color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0,),
      // margin: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: <Widget>[
          Icon(FontAwesomeIcons.search, color: Colors.grey, size: 18.0,),
          SizedBox(width: 10.0,),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(        
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: Colors.transparent)
                ),  
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                hintText: widget.hintText
              ),
              style: TextStyle(
                color: Colors.black,
              ),
              onChanged: widget.onChanged,
            )
          ),
        ],
      ),
    );
  }
}