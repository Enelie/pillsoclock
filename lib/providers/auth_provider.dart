// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';

class AuthProviderLocal extends ChangeNotifier {
  final AuthService _service = AuthService();
  User? user;
  String? role;
  bool loading = true;

  AuthProviderLocal() {
    _init();
  }

  void _init() {
    // listen auth changes
    _service.authChanges.listen((u) async {
      user = u;
      if (user == null) {
        role = null;
        loading = false;
        notifyListeners();
        return;
      }

      try {
        final r = await _service.getRoleForUid(user!.uid);
        role = r;
      } catch (e) {
        role = null;
      }

      loading = false;
      notifyListeners();
    });

    // fallback: don't stay loading forever
    Future.delayed(const Duration(seconds: 5), () {
      if (loading) {
        loading = false;
        notifyListeners();
      }
    });
  }

  Future<String?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _service.register(email: email, password: password, name: name);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _service.login(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      // Map common Firebase auth error codes to friendly Spanish messages
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return 'Correo o contraseña incorrectos. Verifica tus credenciales e intenta de nuevo.';
      }
      if (e.code == 'invalid-email') {
        return 'El correo proporcionado no es válido.';
      }
      if (e.code == 'user-disabled') {
        return 'Esta cuenta ha sido deshabilitada. Contacta al soporte.';
      }
      if (e.code == 'too-many-requests') {
        return 'Se han realizado demasiados intentos. Intenta nuevamente más tarde.';
      }
      if (e.code == 'invalid-credential') {
      return 'Correo o contraseña incorrectos. Verifica tus credenciales.';
    }
      return e.message ?? 'Error de autenticación. Intenta nuevamente.';
    } catch (e) {
        return e.toString();
    }
  }

  Future<void> logout() async {
    await _service.logout();
  }
}