import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final supabase = Supabase.instance.client;

  /// 檢查 user 是否存在
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    return await supabase
        .from('user')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  /// 插入新 user
  Future<void> insertUser(int userId, String name) async {
    await supabase.from('user').insert({
      'id': userId,
      'name': name,
    });
  }
}
