import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'package:pointycastle/random/fortuna_random.dart';

AsymmetricKeyPair<PublicKey, PrivateKey> generateRSAKeyPair(
    {int bitLength = 2048}) {
  // Create an RSA key generator and initialize it
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        secureRandomString()));

  // Use the generator to generate a key pair
  final pair = keyGen.generateKeyPair();
  return pair;
}

SecureRandom secureRandomString() {
  final secureRandom = FortunaRandom();

  var random = Random.secure();
  List<int> seeds = List<int>.generate(32, (_) => random.nextInt(256));
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  return secureRandom;
}

String createRandomKeyBase64(int length) {
  final rnd = SecureRandom("Fortuna")
    ..seed(KeyParameter(Uint8List.fromList(List.generate(32, (n) => n))));
  final key = Uint8List(length);
  for (int i = 0; i < length; i++) {
    key[i] = rnd.nextUint8();
  }

  return base64Encode(key);
}
