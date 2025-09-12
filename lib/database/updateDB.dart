import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getTaskDeliverDetails({String? userId}) async {
    try {
      var query = _client
          .from('taskDeliver')
          .select('id, component_id, user_id, quantity, destination, dueDate, time, status, signature, image, component(name, workshop)');

      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }

      final response = await query;

      final List<Map<String, dynamic>> data = (response as List).map((item) => {
        'id': item['id']?.toString(),
        'component_id': item['component_id']?.toString(),
        'user_id': item['user_id']?.toString(),
        'quantity': item['quantity']?.toString(),
        'destination': item['destination']?.toString(),
        'duedate': item['dueDate']?.toString(),
        'time': item['time']?.toString(),
        'status': item['status']?.toString() ?? 'pending',
        'signature': item['signature']?.toString(),
        'image': item['image']?.toString(),
        'component_name': item['component']?['name']?.toString() ?? '',
        'workshop': item['component']?['workshop']?.toString() ?? '',
      }).toList();

      data.sort((a, b) => int.parse(a['id']!).compareTo(int.parse(b['id']!)));
      return data;
    } catch (e) {
      print('Error fetching taskDeliver details: $e');
      return null;
    }
  }

  /// 更新狀態，如果是 delivered，要檢查 signature 或 image 是否有內容
  Future<bool> updateTaskStatus(String userId, String status) async {
    try {
      final tasks = await getTaskDeliverDetails(userId: userId);
      if (tasks == null || tasks.isEmpty) return false;

      final List<String> idsToUpdate = [];

      for (var task in tasks) {
        if (status == 'delivered') {
          // 只有 signature 或 image 有內容才更新
          if ((task['signature'] != null && task['signature']!.isNotEmpty) ||
              (task['image'] != null && task['image']!.isNotEmpty)) {
            idsToUpdate.add(task['id']!);
          }
        } else {
          // 其他狀態不需要檢查
          idsToUpdate.add(task['id']!);
        }
      }

      if (idsToUpdate.isEmpty) return false; // 沒有符合條件的任務

      await _client
          .from('taskDeliver')
          .update({'status': status})
          .filter('id', 'in', idsToUpdate);

      return true;
    } catch (e) {
      print("Error updating tasks for user: $e");
      return false;
    }
  }
}