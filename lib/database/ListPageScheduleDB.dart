import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class ListPageScheduleService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getTaskDeliverDetails() async {
    try {
      final response = await _client
          .from('taskDeliver')
          .select('id, component_id, user_id, quantity, destination, dueDate, time, status, component(name, workshop)');

      // change List<Map>
      final List<Map<String, dynamic>> data =
      (response as List).map((item) => {
        'id': item['id']?.toString(),   // 轉字串
        'component_id': item['component_id']?.toString(),
        'user_id': item['user_id']?.toString(),
        'quantity': item['quantity']?.toString(),
        'destination': item['destination']?.toString(),
        'duedate': item['dueDate']?.toString(),
        'time': item['time']?.toString(),
        'status': item['status']?.toString(),
        'component_name': item['component']?['name']?.toString() ?? '',
        'workshop': item['component']?['workshop']?.toString() ?? '',
      }).toList();

      return data;

    } catch (e) {
      print('Error fetching taskDeliver details: $e');
      return null;
    }
  }
}
