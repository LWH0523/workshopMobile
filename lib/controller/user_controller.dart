import '../database/user_service.dart';

class UserController {
  static final UserController _instance = UserController._internal();

  factory UserController() => _instance;

  UserController._internal();

  final UserService _userService = UserService();

  /// 儲存新使用者（如果不存在就新增）
  Future<void> saveAUserData(int userId) async {
    try {
      final existing = await _userService.getUserById(userId);

      if (existing != null) {
        print('⚠️ 使用者 $userId 已存在，不重複插入');
        return;
      }

      await _userService.insertUser(userId, 'User_$userId');
      print('✅ 使用者 $userId 已成功插入到 Supabase');
    } catch (e) {
      print('❌ 儲存使用者資料失敗: $e');
      rethrow;
    }
  }

  /// 獲取用戶資料
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    return await _userService.getUserById(userId);
  }
}
