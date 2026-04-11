import 'dart:async';
import 'dart:developer' as Logger;
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';

import '../../errors/exceptions.dart';
import 'base_api_services.dart';

class NetworkApiServices extends BaseApiServices {

  @override
  Future<dynamic> getApi(String url, {Object? data}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        final dio = Dio();
        debugPrint(
            "kkkkkkk ****GET URL$url : $data");
        try {
          final response =
              await dio.get(url, data: data).timeout(const Duration(seconds: 250));
          return returnResponse(response);
        } on SocketException {
          throw InternetException();
        } on TimeoutException {
          throw RequestTimeOut();
        } on Exception catch (e) {
          throw Exception(e);
        }
      } catch (error, stackTrace) {
        Logger.log(error.toString(), stackTrace: stackTrace);
        rethrow;
      }
    } else {
      // Message_Utils.displayToast(
      //   "No Internet Connection",
      // );
    }
  }

  @override
  Future<dynamic> postApi(data, String url) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        final dio = Dio();
        debugPrint(
            "kkkkkkk ****URL$url : $data");
        (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
            (HttpClient dioClient) {
          dioClient.badCertificateCallback =
              ((X509Certificate cert, String host, int port) => true);
          return dioClient;
        };
        try {
          final response =
              await dio.post(url, data: data).timeout(Duration(seconds: 250));

          debugPrint("kkkkkkk ****RESPONSE${response.data}");

          return returnResponse(response);
        } on SocketException {
          throw InternetException();
        } on TimeoutException {
          throw RequestTimeOut();
        } on Exception {
          throw Exception();
        }
      } catch (error, stackTrace) {
        Logger.log(error.toString(), stackTrace: stackTrace);
        rethrow;
      }
    } else {
      // Message_Utils.displayToast(
      //   "No Internet Connection",
      // );
    }
  }
}

dynamic returnResponse(dio.Response response) {
  switch (response.statusCode) {
    case 200:
      return response.data ?? 'Something Went Wrong!';
    case 400:
      throw BadRequest();
    case 401:
      throw Unauthorized();
    case 403:
      throw Forbidden();
    case 404:
      throw NotFound();
    case 408:
      throw RequestTimeOut();
    case 500:
      throw InternalServerError();
    case 502:
      throw BadGateway();
    default:
      throw FetchDataException(
          "Something Went Wrong ${response.statusCode}");
  }
}
