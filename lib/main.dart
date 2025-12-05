import 'package:flutter/material.dart';
import 'core/utils/app_navigator.dart';
import 'core/utils/secure_storage_service.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Verifica si el usuario tiene un token
  Future<String> _getInitialRoute() async {
    final token = await SecureStorageService.getToken();
    return token != null && token.isNotEmpty ? AppRoutes.home : AppRoutes.login;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
            debugShowCheckedModeBanner: false,
          );
        }

        return MaterialApp(
          title: 'Sistema de Monitoreo de Buses',
          navigatorKey: AppNavigator.navigatorKey,
          initialRoute: snapshot.data,
          onGenerateRoute: AppRoutes.generateRoute,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.red,
            fontFamily: 'Roboto',
          ),
        );
      },
    );
  }
}