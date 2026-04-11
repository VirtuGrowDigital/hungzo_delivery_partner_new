
import '../utils/snack_bar.dart';

class ServerException implements Exception {

  late String _message;

  ServerException([String message = 'Internal Server Error']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

class CacheException implements Exception {
  late String _message;

  CacheException([String message = 'Cache Error']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

class NetworkException implements Exception {
  late String _message;

  NetworkException([String message = 'Network error']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

class NoInternetException implements Exception {
  late String _message;

  NoInternetException([String message = 'No Internet Exception Occurred']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

class InternetException implements Exception {
  late String _message;

  InternetException([String message = 'No Internet Exception Occurred']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

class InvalidUrlException implements Exception{
  late String _message;

  InvalidUrlException([String message = 'Request time out Occurred']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

class FetchDataException implements Exception{
  late String _message;

  FetchDataException([String message = 'Fetch data error Occurred']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

/// ********

///400
class BadRequest implements Exception{
  late String _message;

  BadRequest([String message = 'Bad Request']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

///401
class Unauthorized implements Exception{
  late String _message;

  Unauthorized([String message = 'UnAuthorized']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

///403
class Forbidden implements Exception{
  late String _message;

  Forbidden([String message = 'Forbidden']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

///404
class NotFound implements Exception{
  late String _message;

  NotFound([String message = 'Not Found']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

///408
class RequestTimeOut implements Exception {
  late String _message;

  RequestTimeOut([String message = 'Request time out Occurred']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

///500
class InternalServerError implements Exception{
  late String _message;

  InternalServerError([String message = 'Internal Server Error']) {
    _message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}

///502
class BadGateway implements Exception{
  late String _message;

  BadGateway([String message = 'Bad Gateway']) {
    this._message = message;
    CustomSnackBar(_message, "E") ;
  }

  @override
  String toString() {
    return _message;
  }
}