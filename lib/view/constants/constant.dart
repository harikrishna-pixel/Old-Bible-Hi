import 'package:biblebookapp/view/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      color: CommanColor.whiteBlack(context),
      animating: true,
      radius: 15,
    );
  }
}

class Constants {
  //show toast
  static showToast(String message, [sec = 1000]) {
    EasyLoading.showToast(message,
        toastPosition: EasyLoadingToastPosition.top,
        duration: Duration(milliseconds: sec));
  }
}
