import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    try {
      // intenta inicializar Firebase solo si no está inicializado
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (_) {
      // ignore errors aquí; la app seguirá mostrando el splash
    }

    // espera mínimo para que el usuario vea la imagen (ajusta duración si quieres)
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    // check permissions and show dialog once if needed, then navigate
    await _checkPermissionsAndNavigate();
  }

  Future<void> _checkPermissionsAndNavigate() async {
    SharedPreferences? prefs;
    var asked = false;

    try {
      prefs = await SharedPreferences.getInstance();
      asked = prefs.getBool('asked_exact_alarm') ?? false;
    } catch (e) {
      // Could not access SharedPreferences; log but continue — we will still prompt
      debugPrint('SharedPreferences.getInstance() failed: $e');
      prefs = null;
      asked = false; // treat as not asked so we prompt
    }

    // Check notification and exact alarm permissions. If status check fails,
    // assume permissions are not granted so we can prompt the user.
    var needsNotif = true;
    var needsExact = true;
    try {
      final notifStatus = await Permission.notification.status;
      final exactStatus = await Permission.scheduleExactAlarm.status;
      needsNotif = !notifStatus.isGranted;
      needsExact = !exactStatus.isGranted;
    } catch (e) {
      debugPrint('Permission.status failed: $e');
      // keep defaults (true) so dialog will be shown
    }

    // If we already asked before, just continue without prompting
    if (!asked && (needsNotif || needsExact)) {
      final allow = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: const Text('Permisos de notificaciones'),
          content: const Text(
              'Para que los recordatorios funcionen correctamente, la aplicación necesita permiso para mostrar notificaciones y, opcionalmente, programar alarmas exactas.\n\nPuedes permitirlos en la siguiente pantalla o continuar sin ellos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Continuar sin permisos'),
            ),
            TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Permitir'),
            ),
          ],
        ),
      );

      if (prefs != null) {
        try {
          await prefs.setBool('asked_exact_alarm', true);
        } catch (e) {
          debugPrint('Failed to write asked_exact_alarm: $e');
        }
      }

      if (allow == true) {
        // Request notification permission (will show prompt on Android 13+)
        try {
          await Permission.notification.request();
        } catch (e) {
          debugPrint('Permission.request() failed: $e');
        }

        // For exact alarms there is no standard runtime prompt; open system screen
        // only if the user explicitly accepted. This avoids opening settings automatically.
        try {
          final intent = AndroidIntent(action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM');
          await intent.launch();
        } catch (_) {
          // ignore if intent fails
        }
      }
    }

    // proceed to AuthScreen to check if user is already logged in; maintains session
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    // degradado entre lilas suaves y verde-agua claro
    const bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFD1C4E9), // lilac claro
        Color(0xFFB2EBF2), // verde-agua claro
      ],
    );

    // colores auxiliares para detalles
    const accentLilac = Color(0xFF8E7CC3);
    const accentAqua = Color(0xFF3FBFB0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // imagen de splash (usa el asset existente)
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Image.asset(
                    'assets/carga1.gif',
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, st) => const Icon(
                      Icons.local_hospital_rounded,
                      size: 120,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Pills O'Clock",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // barra de progreso con acento que combina lilac/agua
                SizedBox(
                  height: 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 140,
                        child: LinearProgressIndicator(
                          backgroundColor: Color(0x44FFFFFF),
                          valueColor: AlwaysStoppedAnimation<Color>(accentAqua),
                        ),
                      ),
                      SizedBox(width: 12),
                      CircularProgressIndicator(strokeWidth: 2, color: accentLilac),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
