import 'package:flutter/material.dart';

class WidgetUtils {
  //staticの後はWidgetの種類
  static AppBar createAppBar(String title) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Text(title, style: TextStyle(color: Colors.black)),
      centerTitle: true,
    );
  }
}
