// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

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
  final header = <String, String>{};
  header['Content-Type'] = 'application/json';
  print('==authToken== ${AppConstants.authToken}');
  if (AppConstants.authToken.isNotEmpty) {
    print('==authToken== ${AppConstants.authToken}');
    header['authorization'] = 'Bearer ${AppConstants.authToken}';
  }
  return header;
}

Future<bool> isInternetAvailable() async {
  try {
    final result = await http.get(Uri.parse('https://www.google.com'));
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
    final url = AppConstants.baseUrl + methodName;
    final uri = Uri.parse(url);
    log('==request== $uri');
    log('==params== $param');
    final headers = getHeaders();
    final response = await http
        .post(uri, headers: headers, body: jsonEncode(param))
        .timeout(const Duration(seconds: 20))
        .onError((error, stackTrace) {
          log('onError== $error');
          log('stackTrace== $stackTrace');
          _handleError(error, callback);
          return Future.value(ResponseAPI(0, 'Something went wrong', isError: true) as FutureOr<http.Response>?);
        })
        .catchError((error) => _handleError(error, callback));
    _handleResponse(response, callback);
    } else {
    callback.call(ResponseAPI(0, 'No Internet', isError: true));
  }
}

Future multiGetAPINew({
  required String methodName,
  Map<String, String>? query,
  required Function(ResponseAPI) callback,
}) async {
  if (await isInternetAvailable()) {
    final base = AppConstants.baseUrl + methodName;
    final uri = Uri.parse(base).replace(queryParameters: query);
    log('==GET request== $uri');
    final headers = getHeaders();
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20))
        .onError((error, stackTrace) {
          log('onError== $error');
          log('stackTrace== $stackTrace');
          _handleError(error, callback);
          return Future.value(ResponseAPI(0, 'Something went wrong', isError: true) as FutureOr<http.Response>?);
        })
        .catchError((error) => _handleError(error, callback));
    _handleResponse(response, callback);
  } else {
    callback.call(ResponseAPI(0, 'No Internet', isError: true));
  }
}

Future multiPutAPINew({
  required String methodName,
  required Map<String, dynamic> param,
  required Function(ResponseAPI) callback,
}) async {
  if (await isInternetAvailable()) {
    final url = AppConstants.baseUrl + methodName;
    final uri = Uri.parse(url);
    log('==PUT request== $uri');
    log('==params== $param');
    final headers = getHeaders();
    final response = await http
        .put(uri, headers: headers, body: jsonEncode(param))
        .timeout(const Duration(seconds: 20))
        .onError((error, stackTrace) {
          log('onError== $error');
          log('stackTrace== $stackTrace');
          _handleError(error, callback);
          return Future.value(ResponseAPI(0, 'Something went wrong', isError: true) as FutureOr<http.Response>?);
        })
        .catchError((error) => _handleError(error, callback));
    _handleResponse(response, callback);
  } else {
    callback.call(ResponseAPI(0, 'No Internet', isError: true));
  }
}

void _handleResponse(http.Response value, Function(ResponseAPI) callback) {
  callback.call(ResponseAPI(value.statusCode, value.body));
}

void _handleError(value, Function(ResponseAPI) callback) {
  callback.call(
    ResponseAPI(0, 'Something went wrong', isError: true),
  );
}


