import 'package:http/http.dart' as http;
import 'dart:developer' as devtools show log;

class CustomHttp {
  static final CustomHttp _instance = CustomHttp._internal();
  factory CustomHttp() {
    return _instance;
  }
  late http.Client client;

  final headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    "Acess-Control-Allow-Origin": "*",
  };

  //  final headers2 = {
  //   'Authorization': 'Bearer $token',
  //   "Acess-Control-Allow-Origin": "*",
  // };

  CustomHttp._internal() {
    client = http.Client();
  }

//! Post
  Future<http.Response> post(path, {data}) async {
    var response = await client.post(path, body: data, headers: {
      'Content-type': 'application/x-www-form-urlencoded',
      "Acess-Control-Allow-Origin": "*",
    });
    return response;
  }

  Future<http.Response> postwithout(path, {data}) async {
    devtools.log("req post body  - $data");
    var response = await client.post(path, body: data, headers: {
      'Content-type': 'application/x-www-form-urlencoded',
      "Acess-Control-Allow-Origin": "*",
    });
    return response;
  }

  Future<http.Response?> postwithtokenwitht(path, {data, token}) async {
    devtools.log("req post body  - $data");
    try {
      var response = await client.post(path, body: data, headers: {
        'Authorization': 'Bearer $token',
      });

      return response;
    } catch (e) {
      devtools.log("post resp $e");
      return null;
    }
  }

  //! Post with headers beartoken
  Future<http.Response?> postwithtoken({path, token, data}) async {
    devtools.log("req post body  - $data");
    try {
      var response = await client.post(path, body: data, headers: {
        'Authorization': 'Bearer $token',
      });

      return response;
    } catch (e) {
      devtools.log("post resp $e");
      return null;
    }
  }

//! Update
  Future update(path, {data}) async {
    var response = await client.put(path, body: data, headers: headers);
    return response;
  }

  //! Get
  Future get(path, {data}) async {
    var response = await client.get(path, headers: headers);
    return response;
  }

  //! Delete
  Future delete(path, {data}) async {
    var response = await client.delete(path, body: data, headers: headers);
    return response;
  }
}
