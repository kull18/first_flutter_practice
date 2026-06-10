
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled1/services/SecureData.dart';

class Storagesecure {
  static final String _key = 'secure_data';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveData(SensitiveData secureData) async {
    await _storage.write(key: _key, value: jsonEncode(secureData.toJson()));
  }

  Future<SensitiveData?> getData() async {
    String? value = await _storage.read(key: _key);

    if(value == null) return null;

    return SensitiveData.fromJson(
      jsonDecode(value)
    );
  }

  Future<void> delete() async {
    await _storage.delete(key: _key);
  }
}