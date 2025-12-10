import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_model.dart';

class SecureStorageService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const _keyToken = 'token';
  static const _keyUser = 'user';

  // Token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  // Usuario
  static Future<void> saveUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _storage.write(key: _keyUser, value: json);
  }

  static Future<UserModel?> getUser() async {
    final json = await _storage.read(key: _keyUser);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  static Future<void> deleteUser() async {
    await _storage.delete(key: _keyUser);
  }

  // Eliminar todo (para logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  // Obtener DNI del usuario actualmente guardado
  static Future<String?> getDNI() async {
  final user = await getUser(); // ya existe este método
  return user?.identificacion; // devuelve el DNI o null si no hay usuario
  }

}
