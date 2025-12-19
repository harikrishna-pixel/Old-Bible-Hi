import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'package:biblebookapp/view/constants/constant.dart';
import 'package:biblebookapp/view/screens/dashboard/constants.dart';

import '../../../Model/auth/temp_token_model.dart';
import '../../../constant/app_api_constant.dart';
import '../../../utils/custom_http.dart';
import 'temp_token.api.dart';

class RegisterApi {
  Temptokenapi temptokenapi = Temptokenapi();

  Future register(
      {required name,
      required email,
      required password,
      required passwordconfirmation,
      appversion,
      deviceversion,
      devicemodel,
      devicelocale,
      devicetimezone}) async {
    final Uri uri =
        Uri.parse(AppApiConstant.baseurl + AppApiConstant.registerapi);

    // PhoneInfo phoneInfos = await Phoneinformations.getPhoneInformation();
    try {
      var tokendata = await temptokenapi.gettokenaccess();
      final data = Temptoken.fromJson(jsonDecode(tokendata));
      if (data.statusCode == 200) {
        if (data.data!.tempAccessToken != null) {
          // devtools.log("access token is ${data.data!.tempAccessToken}");
          var response = await CustomHttp().postwithtoken(
            path: uri,
            token: data.data!.tempAccessToken.toString(),
            data: {
              "name": name,
              "email": email,
              "password": password,
              "password_confirmation": passwordconfirmation,
              "app_version": appversion ?? "1.0.0",
              "email_verify": BibleInfo.emailVerify,
              "device_type": "Android",
              //"device_type": Platform.isAndroid ? "Android" : "ios",
              "device_version": deviceversion ?? "15.2",
              "device_model": devicemodel ?? "iPhone 16",
              "device_locale": devicelocale ?? "en-US",
              "device_timezone": devicetimezone ?? "America/New_York",
              // "app_id": AppApiConstant.appid
              "app_id": BibleInfo.appID
            },
          );

          final statuscode = response!.statusCode;
          final body = response.body;

          devtools.log("register msg is ${response.statusCode} - ");

          if (statuscode == 200) {
            return body;
          } else {
            devtools.log("register is failed");
            return body;
          }
        } else {
          devtools.log("access token is null");
          return null;
        }
      } else {
        devtools.log("access token is not found");
        return null;
      }
    } catch (e) {
      devtools.log("register error is $e");
      return null;
    }
  }

  Future login(
      {required email,
      required password,
      appversion,
      deviceversion,
      devicemodel,
      devicelocale,
      devicetimezone}) async {
    final Uri uri = Uri.parse(AppApiConstant.baseurl + AppApiConstant.loginapi);

    // PhoneInfo phoneInfos = await Phoneinformations.getPhoneInformation();
    try {
      var tokendata = await temptokenapi.gettokenaccess();
      final data = Temptoken.fromJson(jsonDecode(tokendata));
      if (data.statusCode == 200) {
        if (data.data!.tempAccessToken != null) {
          // devtools.log("access token is ${data.data!.tempAccessToken}");
          var response = await CustomHttp().postwithtoken(
            path: uri,
            token: data.data!.tempAccessToken.toString(),
            data: {
              "email": email,
              "password": password,
              "app_version": appversion ?? "1.0.0",
              "device_type": "Android",
              //"device_type": Platform.isAndroid ? "Android" : "ios",
              "device_version": deviceversion ?? "15.2",
              "device_model": devicemodel ?? "iPhone 16",
              "device_locale": devicelocale ?? "en-US",
              "device_timezone": devicetimezone ?? "America/New_York",
              // "app_id": AppApiConstant.appid
              "app_id": BibleInfo.appID
            },
          );

          final statuscode = response!.statusCode;
          final body = response.body;

          devtools.log("login msg is $statuscode - $body");

          if (body.isNotEmpty) {
            return body;
          } else {
            devtools.log("login api  is not found");
            return null;
          }
        } else {
          devtools.log("access token is null");
          return null;
        }
      } else {
        devtools.log("access token is not found");
        return null;
      }
    } catch (e) {
      devtools.log("login api error is $e");
      return null;
    }
  }

  Future deleteyouraccount(context, email, token) async {
    final Uri uri = Uri.parse(AppApiConstant.deleteacctapi);

    // PhoneInfo phoneInfos = await Phoneinformations.getPhoneInformation();
    try {
      // var tokendata = await temptokenapi.gettokenaccess();
      // final data = Temptoken.fromJson(jsonDecode(tokendata));
      // if (data.statusCode == 200) {
      //   if (data.data!.tempAccessToken != null) {
      // devtools.log("access token is ${data.data!.tempAccessToken}");
      var response = await CustomHttp().postwithtoken(
        path: uri,
        token: token,
        data: {
          "user_id": email,
          // "app_id": AppApiConstant.appid
          "app_id": BibleInfo.appID
        },
      );

      final statuscode = response!.statusCode;
      final body = response.body;

      devtools.log("deleteyouraccount api msg is $statuscode - $body");

      if (body.isNotEmpty) {
        return body;
      } else {
        devtools.log("deleteyouraccount api  is not found");
        return null;
      }
      //   } else {
      //     devtools.log("access token is null");
      //     return null;
      //   }
      // } else {
      //   devtools.log("access token is not found");
      //   return null;
      // }
    } catch (e) {
      Constants.showToast('Check your Internet connection');
      devtools.log("deleteyouraccount api error is $e");
      return null;
    }
  }

  Future forgotsendotp({
    required email,
  }) async {
    final Uri uri =
        Uri.parse(AppApiConstant.baseurl + AppApiConstant.forgotsendotp);

    // PhoneInfo phoneInfos = await Phoneinformations.getPhoneInformation();
    try {
      // devtools.log("access token is ${data.data!.tempAccessToken}");
      final response = await CustomHttp().postwithout(
        uri,
        data: {
          "email": email,
          "app_id": BibleInfo.appID
          //"app_id": AppApiConstant.appid,
        },
      );

      final statuscode = response.statusCode;
      final body = response.body;

      devtools.log("forgotsendotp msg is $statuscode - $body ");

      return body;
    } catch (e) {
      devtools.log("forgotsendotp api error is $e");
      return null;
    }
  }

  Future forgotverifyotp({
    required email,
    required otp,
  }) async {
    final Uri uri =
        Uri.parse(AppApiConstant.baseurl + AppApiConstant.forgotverifyotp);

    // PhoneInfo phoneInfos = await Phoneinformations.getPhoneInformation();
    try {
      // devtools.log("access token is ${data.data!.tempAccessToken}");
      var response = await CustomHttp().postwithout(
        uri,
        data: {
          "email": email,
          // "app_id": AppApiConstant.appid,
          "app_id": BibleInfo.appID,
          "otp": otp,
        },
      );

      final statuscode = response.statusCode;
      final body = response.body;

      devtools.log("forgotverifyotp msg is $statuscode - ");

      return body;
    } catch (e) {
      devtools.log("forgotverifyotp api error is $e");
      return null;
    }
  }

  Future forgotrestpwd(
      {required email,
      required otp,
      required passwordconfirmation,
      required token,
      required password}) async {
    final Uri uri =
        Uri.parse(AppApiConstant.baseurl + AppApiConstant.forgotrestpwd);

    // PhoneInfo phoneInfos = await Phoneinformations.getPhoneInformation();
    try {
      var tokendata = await temptokenapi.gettokenaccess();
      final data = Temptoken.fromJson(jsonDecode(tokendata));
      if (data.statusCode == 200) {
        if (data.data!.tempAccessToken != null) {
          // devtools.log("access token is ${data.data!.tempAccessToken}");
          var response = await CustomHttp().postwithout(
            uri,
            data: {
              "email": email,
              "app_id": BibleInfo.appID,
              //"app_id": AppApiConstant.appid,
              "token": token,
              "password": password,
              "password_confirmation": passwordconfirmation
            },
          );

          final statuscode = response.statusCode;
          final body = response.body;

          devtools.log("forgotrestpwd msg is $statuscode - ");

          return body;
        } else {
          devtools.log("access token is null");
          return null;
        }
      } else {
        devtools.log("access token is not found");
        return null;
      }
    } catch (e) {
      devtools.log("forgotrestpwd api error is $e");
      return null;
    }
  }
}
