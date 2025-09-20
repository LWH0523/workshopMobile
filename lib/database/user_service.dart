// lib/database/user_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    return await supabase
        .from('user')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }


  Future<void> insertUser(int userId, String name) async {
    await supabase.from('user').insert({
      'id': userId,
      'name': name,
    });
  }


  Future<String> uploadUserImage(int userId, File file) async {
    final fileName = 'user_$userId.png';
    await supabase.storage.from('avatars').upload(
      fileName,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    return supabase.storage.from('avatars').getPublicUrl(fileName);
  }


  Future<void> updateUserImage(int userId, String imageUrl) async {
    await supabase
        .from('user')
        .update({'image': imageUrl})
        .eq('id', userId);
  }
}
