import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final bool enabled; // model.isLoading == false <--- Should always be this!
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final TextInputAction textInputAction;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final Function(String) onChanged;
  final VoidCallback onEditingComplete;
  final Function(String) validator;

  const CustomTextField({
    @required this.enabled,
    @required this.controller,
    @required this.hintText, 
    @required this.textInputAction, 
    @required this.maxLength,
    @required this.minLines,
    @required this.maxLines,
    @required this.onChanged,
    this.focusNode, 
    this.onEditingComplete,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(75),
                offset: Offset(0.0, 10.0),
                blurRadius: 10.0,
                spreadRadius: -10.0,
              ),
            ]
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
            validator: validator,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            controller: controller,
            focusNode: focusNode,
            // cursorColor: Colors.black,
            style: TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              focusColor: Colors.indigo,
              hintStyle: TextStyle(
                color: Colors.black38,
              ),
              enabledBorder: UnderlineInputBorder(      
                borderSide: BorderSide(color: Colors.transparent),   
              ),  
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),   
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),   
              ),
              // labelText: labelText,
              hintText: hintText,
              enabled: enabled,
            ),
            autocorrect: false,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
          ),
        ),
      ],
    );
  }
} 