import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class Encryptor {
// Fungsi untuk mengenkripsi teks menggunakan AES
  String aesEncrypt(String plainText, String base64Key) {
    final key = base64Decode(base64Key);
    final iv = Uint8List(16); // Inisialisasi IV dengan nilai acak atau tetap
    final params = PaddedBlockCipherParameters(
        ParametersWithIV<KeyParameter>(KeyParameter(key), iv), null);
    final cipher =
        PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()))
          ..init(true, params); // true = encrypt
    final plainTextBytes = utf8.encode(plainText);
    final cipherText = cipher.process(Uint8List.fromList(plainTextBytes));
    return base64Encode(cipherText);
  }

  String rsaEncrypt(RSAPublicKey publicKey, String dataToEncrypt) {
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey)); // true=encrypt
    final encryptedBytes =
        encryptor.process(Uint8List.fromList(dataToEncrypt.codeUnits));
    return base64Encode(encryptedBytes);
  }

  String doubleEncrypt(String plaintext, String aesPassword,
      {RSAPrivateKey? privateKey, RSAPublicKey? publicKey}) {
    // First, encrypt with AES
    String aesEncrypted = aesEncrypt(plaintext, aesPassword);

    // Then, encrypt the AES encrypted data with RSA
    String rsaEncrypted = rsaEncrypt(publicKey!, aesEncrypted);

    return rsaEncrypted;
  }
}
