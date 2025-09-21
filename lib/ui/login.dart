import 'dart:math';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/user_controller.dart';
import 'ListPageSchedule.dart';

class FingerprintLoginScreen extends StatefulWidget {
  const FingerprintLoginScreen({super.key});

  @override
  State<FingerprintLoginScreen> createState() => _FingerprintLoginScreenState();
}

class _FingerprintLoginScreenState extends State<FingerprintLoginScreen> {
  final LocalAuthentication localAuth = LocalAuthentication();
  bool _authInProgress = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    debugPrint('Start fingerprint authentication...');
    try {
      final bool isSupported = await localAuth.isDeviceSupported();
      final bool canCheck = await localAuth.canCheckBiometrics;
      debugPrint('Device supported: $isSupported, Can check biometrics: $canCheck');

      bool didAuthenticate = false;
      if (isSupported && canCheck) {
        didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Please scan your fingerprint to continue',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        debugPrint('Authentication result: $didAuthenticate');
      }

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();

        int? userId = prefs.getInt('user_id');
        if (userId == null) {
          userId = 100000 + Random().nextInt(900000);
          await prefs.setInt('user_id', userId);
          debugPrint('Generated and saved new user_id: $userId');
        } else {
          debugPrint('Existing user_id found: $userId');
        }

        try {
          await UserController().saveAUserData(userId);
          debugPrint('UserController confirmed userId $userId in database');
        } catch (e) {
          debugPrint('UserController saveAUserData failed: $e');
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ListPageSchedule(userId: userId)),
        );
      } else {
        debugPrint('Authentication failed or canceled');
        if (mounted) {
          setState(() {
            _authInProgress = false;
            _errorMessage = 'Authentication failed or canceled';
          });
        }
      }
    } catch (e) {
      debugPrint('Authentication error: $e');
      if (mounted) {
        setState(() {
          _authInProgress = false;
          _errorMessage = 'Authentication error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authInProgress) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBF7EF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7EF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _authInProgress = true;
                  _errorMessage = null;
                });
                _authenticate();
              },
              child: const Text('Retry Fingerprint Authentication'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ListPageSchedule(userId: null)),
                );
              },
              child: const Text('Skip Authentication'),
            ),
          ],
        ),
      ),
    );
  }
}
