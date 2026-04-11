

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/constants.dart';
import '../services/Api/api_constants.dart';
import 'flutter_toast.dart';
                              
class RequestInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final storage = GetStorage();
  final Dio _dio = Dio();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    String? token = await secureStorage.read(key: Constants.accessToken);
    options.headers["Authorization"] = 'Bearer $token';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.type == DioExceptionType.connectionError) {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        Message_Utils.displayToast("No internet connection. Please check your connection.");
      } else {
        Message_Utils.displayToast("No internet connection. Please check your connection.");
      }
      return handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: "No internet connection. Please check your connection.",
        type: DioExceptionType.connectionError,
      ));
    }

    if (err.response?.statusCode == 401) {
      final newAccessToken = await _refreshToken();
      if (newAccessToken != null) {
        _dio.options.headers['Authorization'] = 'Bearer $newAccessToken';
        return handler.resolve(await _dio.fetch(err.requestOptions));
      }
    }
    return handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await secureStorage.read(key: Constants.refreshToken);

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await _dio.post(
       ApiConstants.accessTokenNew,
        data: {Constants.refreshToken: refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        /// Store the new tokens
        await secureStorage.write(key: Constants.accessToken, value: newAccessToken);
        await secureStorage.write(key: Constants.refreshToken, value: newRefreshToken);

        return newAccessToken;
      } else {
        throw Exception(response.statusCode.toString());
      }
    } catch (e) {
      Message_Utils.displayToast(e.toString());
      return null;
    }
  }
}


