
import '../services/auth_service.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../core/utils/result.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<Result<LoginResponse>> login(String identificacion, String password) async {
    try {
      final loginData = await _authService.login(identificacion, password);
      if (loginData != null) {
        final user = loginData['perfil'].toEntity();
        final token = loginData['token'];
        
        return Result.success(LoginResponse(
          token: token,
          user: user,
        ));
      } else {
        return Result.error('Credenciales inválidas');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  Future<Result<bool>> validarConductor(String identificacion, String numeroLicencia) async {
    try {
      final result = await _authService.validarConductor(identificacion, numeroLicencia);
      final isValid = result['valido'] == true;
      return Result.success(isValid);
    } catch (e) {
      return Result.error('Error al validar identidad: ${e.toString()}');
    }
  }

  Future<Result<String>> actualizarPassword(String identificacion, String nuevaPassword) async {
    try {
      final mensaje = await _authService.actualizarPassword(identificacion, nuevaPassword);
      return Result.success(mensaje);
    } catch (e) {
      return Result.error('Error al actualizar la contraseña: ${e.toString()}');
    }
  }
}
