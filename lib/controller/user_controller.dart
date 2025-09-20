// lib/controller/user_controller.dart
import 'dart:io';
import '../database/user_service.dart';

class UserController {
  static final UserController _instance = UserController._internal();

  factory UserController() => _instance;

  UserController._internal();

  final UserService _userService = UserService();

  Future<void> saveAUserData(int userId) async {
    try {
      final existing = await _userService.getUserById(userId);

      if (existing != null) {
        print('User $userId already exists, skipping insert');
        return;
      }

      await _userService.insertUser(userId, 'DeliveryPerson_$userId');
      print('User $userId has been successfully inserted into Supabase');
    } catch (e) {
      print('Failed to save user data: $e');
      rethrow;
    }
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    return await _userService.getUserById(userId);
  }

  /// Update profile picture
  Future<String> updateProfilePicture(int userId, File imageFile) async {
    try {
      // 1Upload image
      final imageUrl = await _userService.uploadUserImage(userId, imageFile);

      // Update user.image field in database
      await _userService.updateUserImage(userId, imageUrl);

      print('User $userId profile picture updated: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Failed to update profile picture: $e');
      rethrow;
    }
  }
}
