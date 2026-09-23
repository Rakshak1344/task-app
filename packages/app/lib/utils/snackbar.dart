import 'package:flutter/material.dart';

extension SnackbarExtensions on BuildContext {
  void showSnackBar(String message) {
    var snackBar = SnackBar(
      content: Text(message),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    );

    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  Widget showLoading() {
    return Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
