import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;


import '../constants/app_constants.dart' show AppConstants;

class ResponseAPI {
  int code;
  String response;
  bool? isError;
  dynamic isCacheError;
  Error? error;

  ResponseAPI(
    this.code,
    this.response, {
    this.isError,
    this.isCacheError,
    this.error,
  });
}

Map<String, String> getHeaders() {
  Map<String, String> header = {};
  header['Content-Type'] = "application/json";
  header["authorization"] = "Bearer ${AppConstants.authToken}";
  // Utils.logger.e(header);
  return header;
}

Future<bool> isInternetAvailable() async {
  try {
    final result = await http.get(Uri.parse('https://www.yahoo.com'));
    log("==result== $result");
    return result.statusCode == 200;
  } catch (_) {
    return false;
  }
}

Future multiPostAPINew({
  required String methodName,
  required Map<String, dynamic> param,
  required Function(ResponseAPI) callback,
}) async {
  if (await isInternetAvailable()) {
    String url = AppConstants.baseUrl + methodName;

    Uri uri = Uri.parse(url);
    // Utils.logger.e(uri);
    log("==request== $uri");
    log("==full URL== $url");
    log("==methodName== $methodName");
    log("==params== $param");

    Map<String, String>? headers = getHeaders();

    // Utils.logger.f(jsonEncode(param));

    await http
        .post(uri, headers: headers, body: jsonEncode(param))
        .then((value) {
          // Utils.logger.e(value);

          _handleResponse(value, callback);
        })
        .onError((error, stackTrace) {
          log("onError== $error");
          log("stackTrace== $stackTrace");
          _handleError(error, callback);
        })
        .catchError((error) {
          log("catchError== $error");
          _handleError(error, callback);
        });
  } else {
    // Utils.logger.e('No Internet');
    callback.call(ResponseAPI(0, 'No Internet', isError: true));
  }
}

Future putAPI({
  required String methodName,
  required Map<String, dynamic> param,
  required Function(ResponseAPI) callback,
}) async {
  if (await isInternetAvailable()) {
    String url = AppConstants.baseUrl + methodName;

    Uri uri = Uri.parse(url);
    // Utils.logger.e(uri);
    log("==request== $uri");
    log("==params== $param");

    Map<String, String>? headers = getHeaders();

    // Utils.logger.f(jsonEncode(param));

    await http
        .put(uri, headers: headers, body: jsonEncode(param))
        .then((value) {
          // Utils.logger.e(value);

          _handleResponse(value, callback);
        })
        .onError((error, stackTrace) {
          log("onError== $error");
          log("stackTrace== $stackTrace");
          _handleError(error, callback);
        })
        .catchError((error) {
          log("catchError== $error");
          _handleError(error, callback);
        });
  } else {
    // Utils.logger.e('No Internet');
    callback.call(ResponseAPI(0, 'No Internet', isError: true));
  }
}

Future deleteAPI({
  required String methodName,
  required Map<String, dynamic> param,
  required Function(ResponseAPI) callback,
}) async {
  if (await isInternetAvailable()) {
    String url = AppConstants.baseUrl + methodName;

    Uri uri = Uri.parse(url);
    // Utils.logger.e(uri);
    log("==request== $uri");
    log("==params== $param");
    log("==token== ${AppConstants.authToken}");

    Map<String, String>? headers = getHeaders();

    // Utils.logger.f(jsonEncode(param));

    await http
        .delete(uri, headers: headers, body: jsonEncode(param))
        .then((value) {
          _handleResponse(value, callback);
        })
        .onError((error, stackTrace) {
          log("onError== $error");
          log("stackTrace== $stackTrace");
          _handleError(error, callback);
        })
        .catchError((error) {
          log("catchError== $error");
          _handleError(error, callback);
        });
  } else {
    // Utils.logger.e('No Internet');
    callback.call(ResponseAPI(0, 'No Internet', isError: true));
  }
}

Future patchAPI({
  required String methodName,
  required Map<String, dynamic> param,
  required Function(ResponseAPI) callback,
}) async {
  if (await isInternetAvailable()) {
    String url = AppConstants.baseUrl + methodName;

    Uri uri = Uri.parse(url);
    // Utils.logger.i(uri);
    log("==request== $uri");
    log("==params== $param");
    log("==token== ${AppConstants.authToken}");

    Map<String, String>? headers =
        AppConstants.authToken.isEmpty ? {} : getHeaders();
    //  Map<String, String>? headers =  getHeaders();

    await http
        .patch(uri, headers: headers, body: jsonEncode(param))
        .then((value) {
          // Utils.logger.i(value);

          _handleResponse(value, callback);
        })
        .onError((error, stackTrace) {
          log("onError== $error");
          log("stackTrace== $stackTrace");
          _handleError(error, callback);
        })
        .catchError((error) {
          log("catchError== $error");
          _handleError(error, callback);
        });
  } else {
    // Utils.logger.e('No Internet');
    callback.call(ResponseAPI(0, 'No Internet', isError: true));
  }
}

_handleResponse(http.Response value, Function(ResponseAPI) callback) {
  // Utils.logger.i("==response== ${value.body}");
  callback.call(ResponseAPI(value.statusCode, value.body));
}

_handleError(value, Function(ResponseAPI) callback) {
  print("❌ Network Error: ${value.body}");
  callback.call(
    ResponseAPI(0, "Something went wrong", isError: true, error: value),
  );
}

getAPI({
  required String methodName,
  required Function(ResponseAPI) callback,
}) async {
  if (await isInternetAvailable()) {
    // Utils.logger.f("Auth token ${AppConstants.authToken}");
    String url = AppConstants.baseUrl + methodName;
    Uri uri = Uri.parse(url);
    // Utils.logger.f(uri);
    log("==request== $uri");
    log("==token== ${AppConstants.authToken}");
    await http
        .get(uri, headers: getHeaders())
        .then((value) {
          _handleResponse(value, callback);
        })
        .onError((error, stackTrace) {
          log("onError== $error");
          _handleError(error, callback);
        })
        .catchError((error) {
          log("catchError== $error");
          _handleError(error, callback);
        });
  } else {
    // toast('No Internet');
    callback.call(ResponseAPI(0, 'No Internet', isError: true));
  }
}
