import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getTaskDeliverDetails({int? userId, int? taskId}) async {
    try {
      var query = _client
          .from('taskDeliver')
          .select('id, component_id, user_id, quantity, destination, dueDate, time, status, signature, image, component(name, workshop)');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      if (taskId != null) query = query.eq('id', taskId);

      final response = await query;

      final List<Map<String, dynamic>> data = (response as List).map((item) => {
        'id': (item['id'] as num?)?.toInt() ?? 0,
        'component_id': item['component_id']?.toString(),
        'user_id': (item['user_id'] as num?)?.toInt() ?? 0,
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

      data.sort((a, b) => a['id'].compareTo(b['id']));
      print('DB fetched data: $data'); // debug
      return data;
    } catch (e) {
      print('Error fetching taskDeliver details: $e');
      return null;
    }
  }

  Future<bool> updateTaskStatus(int userId, int taskId, String status) async {
    try {
      final tasks = await getTaskDeliverDetails(userId: userId);
      if (tasks == null || tasks.isEmpty) return false;

      final List<String> idsToUpdate = [];

      for (var task in tasks) {
        if (status == 'delivered') {
          // only have signature/image then only update
          if ((task['signature'] != null && task['signature']!.isNotEmpty) ||
              (task['image'] != null && task['image']!.isNotEmpty)) {
            idsToUpdate.add(task['id'].toString());
          }
        } else {
          idsToUpdate.add(task['id'].toString());
        }
      }

      if (idsToUpdate.isEmpty) return false; // not have fulfill condition task

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