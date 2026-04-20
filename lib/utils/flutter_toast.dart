
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'color_constants.dart';

mixin Message_Utils {
  static displayToast(String message, {msg}) async {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: ColorConstants.textOne,
        textColor: Colors.white,
        fontSize: 14);
  }
}
