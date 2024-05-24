import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:endvein/endvein.dart';
import 'package:endvein/src/decryptor.dart';
import 'package:endvein/src/encryptor.dart';
import 'package:endvein/src/keypair.dart';
import 'package:endvein/src/router.dart';
import 'package:pointycastle/pointycastle.dart';

typedef RequestCallback = void Function(HttpRequest request);

class WebServer {
  int _port = 8080;
  var _router = Router();

  void setPort(int? port) {
    _port = port ?? 8080;
  }

  final _requestController = StreamController<HttpRequest>.broadcast();

  Stream<HttpRequest> get onRequest => _requestController.stream;

  void get(String path, dynamic response, {bool? needAuth}) {
    _router.addRoute(RouteMethod.get, path, response, needAuth: needAuth);
  }

  void post(String path, dynamic response, {bool? needAuth}) {
    _router.addRoute(RouteMethod.post, path, response, needAuth: needAuth);
  }

  void put(String path, dynamic response, {bool? needAuth}) {
    _router.addRoute(RouteMethod.put, path, response, needAuth: needAuth);
  }

  void delete(String path, dynamic response, {bool? needAuth}) {
    _router.addRoute(RouteMethod.delete, path, response, needAuth: needAuth);
  }

  void base(String path, dynamic response,
      {bool? needAuth, bool encrypt = false}) {
    if (encrypt) {
      final keyPair = generateRSAKeyPair();
      final _publicKey = keyPair.publicKey as RSAPublicKey;
      final _privateKey = keyPair.privateKey as RSAPrivateKey;
      final _pass = createRandomKeyBase64(16);
      var encrypted = Encryptor().doubleEncrypt(response.toString(), _pass,
          privateKey: _privateKey, publicKey: _publicKey);
      // var decrypted = Decryptor().doubleDecrypt(encrypted, _pass, _privateKey);
      print(encrypted);
      _router.addRoute(RouteMethod.post, path, {"data": encrypted.toString()},
          needAuth: needAuth);
      // print(
      //     'decrypt : ${Decryptor().doubleDecrypt(Encryptor().doubleEncrypt(jsonEncode(response), '1234567890987654', privateKey: _privateKey, publicKey: _publicKey), '1234567890987654', _privateKey)}');
    } else {
      _router.addRoute(RouteMethod.post, path, response, needAuth: needAuth);
    }
  }

  Future<void> startServer() async {
    // instantiate a reloader that by monitors the project's source code folders for changes

    // ... your other code

    // cleanup
    var server = await HttpServer.bind(InternetAddress.anyIPv4, _port);

    stdout.writeln(
        'Server running on http://${server.address.host}:${server.port}');

    await for (HttpRequest request in server) {
      _requestController.add(request);
      _router.handleRequest(request);
    }
  }

  void dispose() {
    _requestController
        .close(); // Jangan lupa untuk menutup controller ketika tidak dibutuhkan lagi
  }
}
