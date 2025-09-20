// lib/database/user_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final supabase = Supabase.instance.client;

  /// Get user data
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    return await supabase
        .from('user')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  /// Insert a new user
  Future<void> insertUser(int userId, String name) async {
    await supabase.from('user').insert({
      'id': userId,
      'name': name,
    });
  }

  /// Upload image to Storage only
  Future<String> uploadUserImage(int userId, File file) async {
    // Store in bucket: avatars under path, e.g. user_1/1695123456.jpg
    final fileName = 'user_$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage.from('avatars').upload(
      fileName,
      file,
      fileOptions: const FileOptions(upsert: true), // overwrite if exists
    );

    // Return public URL
    return supabase.storage.from('avatars').getPublicUrl(fileName);
  }

  /// Update only the image field in DB
  Future<void> updateUserImage(int userId, String imageUrl) async {
    await supabase
        .from('user')
        .update({'image': imageUrl})
        .eq('id', userId);
  }

  ///  Combined method: upload image + update in DB
  Future<String> uploadAndSaveUserImage(int userId, File file) async {
    try {
      final imageUrl = await uploadUserImage(userId, file);
      await updateUserImage(userId, imageUrl);
      return imageUrl;
    } catch (e) {
      throw Exception(' Upload or update failed: $e');
    }
  }

  /// Get user avatar URL
  Future<String?> getUserAvatar(int userId) async {
    final response = await supabase
        .from('user')
        .select('image')
        .eq('id', userId)
        .maybeSingle();

    return response?['image'] as String?;
  }
}
