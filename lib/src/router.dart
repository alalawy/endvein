import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:endvein/endvein.dart';

typedef RequestHandler = void Function(HttpRequest request);

class Router {
  final _routes = <String, Map<String, dynamic>>{};

  void addRoute(RouteMethod method, String path, dynamic response,
      {bool? needAuth}) {
    // Menyimpan informasi respons dan needAuth dalam sebuah map
    var routeInfo = {
      'response': response,
      'needAuth': needAuth ?? false,
    };

    if (!_routes.containsKey(path)) {
      _routes[path] = {};
    }
    _routes[path]![method.name.toString().toUpperCase()] = routeInfo;
  }

  void handleRequest(HttpRequest request) {
    var routeInfo = _routes[request.uri.path]?[request.method];
    if (routeInfo != null) {
      // Mengecek apakah autentikasi diperlukan untuk rute ini
      if (routeInfo['needAuth']) {
        var authorizationHeader = request.headers.value('Authorization');
        if (authorizationHeader == null ||
            !authorizationHeader.startsWith('Bearer ') ||
            !_validateJwtToken(
                authorizationHeader.substring('Bearer '.length))) {
          _handleAuthenticationRequired(request);
          return;
        }
      }

      // Mengambil respons dari informasi rute
      var response = routeInfo['response'];

      if (request.method == 'GET') {
        _handleGetApi(request, response);
      } else if (request.method == 'POST') {
        _handlePostApi(request, response);
      } else {
        _handleUnsupportedMethod(request);
      }
    } else {
      _handleNotFound(request);
    }
  }

  /// Handle response not found
  void _handleNotFound(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.notFound
      ..write('Not found')
      ..close();
  }

  /// Handle response unsupported method
  void _handleUnsupportedMethod(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.methodNotAllowed
      ..write('Unsupported request: ${request.method}.')
      ..close();
  }

  /// Handle response unsupported method
  void _handleUnauthorized(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.unauthorized
      ..write('Unauthorized!')
      ..close();
  }

  /// Handle response get api
  void _handleGetApi(HttpRequest request, response) {
    // Implementasi logika untuk GET request
    request.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(response))
      ..close();
  }

  /// Handle response post api
  void _handlePostApi(HttpRequest request, response) async {
    // Implementasi logika untuk POST request, misalnya mengambil data dari body
    var content = await utf8.decoder.bind(request).join();
    var data = jsonDecode(content);

    request.response
      ..headers.contentType = ContentType.json
      ..write(response != null
          ? jsonEncode(response)
          : jsonEncode({'receivedData': data}))
      ..close();
  }

  bool _validateJwtToken(String token) {
    // Implementasi validasi token JWT.
    // Validasi bisa termasuk memeriksa signature, iss, exp, dan klaim lain yang relevan.
    // Kembali true jika token valid, false jika tidak valid.
    return true; // Placeholder, ganti dengan logika validasi yang sebenarnya.
  }

  void _handleInvalidToken(HttpRequest request) {
    // Kirim response bahwa token tidak valid
    _handleUnauthorized(request);
  }

  void _handleAuthenticationRequired(HttpRequest request) {
    // Kirim response bahwa autentikasi diperlukan
    _handleUnauthorized(request);
  }
}
