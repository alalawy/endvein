import 'dart:io';

import 'package:endvein/src/webserver.dart';

class Endvein extends WebServer {}

/// Defines HTTP call methods for routes.
enum RouteMethod {
  /// HTTP get.
  get,

  /// HTTP post.
  post,

  /// HTTP put.
  put,

  /// HTTP delete.
  delete
}
