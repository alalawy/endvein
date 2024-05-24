import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';

class Decryptor {
  String rsaDecrypt(RSAPrivateKey privateKey, String base64CipherText) {
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(false,
          PrivateKeyParameter<RSAPrivateKey>(privateKey)); // false=decrypt
    final cipherText = base64Decode(base64CipherText);
    final decryptedBytes = decryptor.process(cipherText);
    return String.fromCharCodes(decryptedBytes);
  }

  String aesDecrypt(String base64CipherText, String base64Key) {
    final key = base64Decode(base64Key);
    final iv =
        Uint8List(16); // Inisialisasi IV dengan nilai yang sama saat enkripsi
    final params = PaddedBlockCipherParameters(
        ParametersWithIV<KeyParameter>(KeyParameter(key), iv), null);
    final cipher =
        PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()))
          ..init(false, params); // false = decrypt
    final cipherText = base64Decode(base64CipherText);
    final plainText = cipher.process(cipherText);
    return utf8.decode(plainText);
  }

  String doubleDecrypt(String doubleEncryptedText, String aesPassword,
      RSAPrivateKey privateKey) {
    // First, decrypt with RSA using the private key
    String rsaDecrypted = rsaDecrypt(privateKey, doubleEncryptedText);

    // Then, decrypt the result with AES
    String aesDecrypted = aesDecrypt(rsaDecrypted, aesPassword);

    return aesDecrypted;
  }
}
