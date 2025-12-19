import 'package:biblebookapp/controller/api_service.dart';
import 'package:biblebookapp/core/notifiers/auth/auth.notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final loginBloc = ChangeNotifierProvider((ref) => LoginBloc(ref: ref));

class LoginBloc extends ChangeNotifier {
  final Ref ref;
  LoginBloc({required this.ref});

  TextEditingController emailCon = TextEditingController();
  TextEditingController passCon = TextEditingController();

  bool isLoading = false;

  AuthNotifier authNotifier = AuthNotifier();

  Future login(context) async {
    isLoading = true;
    notifyListeners();
    try {
      isLoading = false;
      // return await authNotifier.login(
      //     email: emailCon.text, password: passCon.text, context: context);
      return await loginUser(email: emailCon.text, password: passCon.text);
    } catch (_) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
