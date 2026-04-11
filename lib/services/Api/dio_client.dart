import 'package:dio/dio.dart';
import '../../utils/request_interceptor.dart';
import 'api_constants.dart';

class DioClient {
  final Dio dio = Dio();
  final String baseUrl = ApiConstants.baseURL;
  final RequestInterceptor requestInterceptor = RequestInterceptor();

  BaseOptions baseOptions() {
    BaseOptions options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    );
    options.baseUrl = baseUrl;
    return options;
  }

  Dio getDio() {
    dio.options = baseOptions();
    dio.interceptors.add(requestInterceptor);
    return dio;
  }

}
