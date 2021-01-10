import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as FT;

dynamic AlertCTX;

///弱提示
class Toast {
  static show(String tipText) {
    FT.Fluttertoast.showToast(
        msg: tipText,
        toastLength: FT.Toast.LENGTH_SHORT,
        gravity: FT.ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: Color(0xFF9E9E9E),
        textColor: Color(0xFFFFFFFF),
        fontSize: 15.0);
  }
}

///强提示
class Alert {
  static show(String tipText) {
    showDialog(
      context: AlertCTX,
      barrierDismissible: false,
      builder: (BuildContext content) {
        return AlertDialog(
          title: Text(tipText),
          actions: <Widget>[
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(content).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //不能消失
  static showWithoutDismiss(String tipText) {
    showDialog(
      context: AlertCTX,
      barrierDismissible: false,
      builder: (BuildContext content) {
        return AlertDialog(
          title: Text(tipText),
          actions: <Widget>[],
        );
      },
    );
  }

  //自定义弹窗
  static showCustom(String tipText, String leftButton, String rightButton, Function leftAction, Function rightAction) {
    showDialog(
      context: AlertCTX,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text(tipText),
          actions: <Widget>[
            FlatButton(
              child: Text(leftButton),
              onPressed: (){
                Navigator.of(AlertCTX).pop();
                leftAction();
              },
            ),
            FlatButton(
              child: Text(rightButton),
              onPressed: (){
                Navigator.of(AlertCTX).pop();
                rightAction();
              },
            )
          ],
        );
      },
    );
  }
}
