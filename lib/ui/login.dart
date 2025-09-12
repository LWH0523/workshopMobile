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
    debugPrint('🔐 開始指紋驗證流程...');
    try {
      final bool isSupported = await localAuth.isDeviceSupported();
      final bool canCheck = await localAuth.canCheckBiometrics;
      debugPrint('設備支援: $isSupported, 可檢查生物辨識: $canCheck');

      bool didAuthenticate = false;
      if (isSupported && canCheck) {
        didAuthenticate = await localAuth.authenticate(
          localizedReason: '請掃描指紋以繼續',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        debugPrint('指紋驗證結果: $didAuthenticate');
      }

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();

        // 🔹 生成新的或取得已存在 userId
        int? userId = prefs.getInt('user_id');
        if (userId == null) {
          userId = 100000 + Random().nextInt(900000);
          await prefs.setInt('user_id', userId);
          debugPrint('🔧 產生並儲存新的 user_id: $userId');
        } else {
          debugPrint('✅ 已存在 userId: $userId');
        }

        // 🔹 儲存到資料庫，如果已存在就跳過
        try {
          await UserController().saveAUserData(userId);
          debugPrint('✅ UserController 已確認 userId $userId 在資料庫中');
        } catch (e) {
          debugPrint('❌ UserController saveAUserData 失敗: $e');
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ListPageSchedule(userId: userId)),
        );
      } else {
        debugPrint('⚠️ 驗證失敗或被取消');
        if (mounted) {
          setState(() {
            _authInProgress = false;
            _errorMessage = '驗證失敗或已取消';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ 驗證錯誤: $e');
      if (mounted) {
        setState(() {
          _authInProgress = false;
          _errorMessage = '驗證錯誤: $e';
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
              child: const Text('重新嘗試指紋驗證'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ListPageSchedule(userId: null)),
                );
              },
              child: const Text('跳過驗證'),
            ),
          ],
        ),
      ),
    );
  }
}
