import 'package:supabase_flutter/supabase_flutter.dart';

  class ListPageScheduleService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getTaskDeliverDetails({int? userId}) async {
    try {
      final query = _client
          .from('taskDeliver')
          .select('id, component_id, user_id, quantity, destination, dueDate, time, status, component(name, workshop)');

      final response = userId != null ? await query.eq('user_id', userId) : await query;

      final List<Map<String, dynamic>> data =
      (response as List).map((item) => {
        'id': (item['id'] as num?)?.toInt() ?? 0,
        'component_id': (item['component_id'] as num?)?.toInt() ?? 0,
        'user_id': (item['user_id'] as num?)?.toInt() ?? 0,
        'quantity': (item['quantity'] as num?)?.toInt() ?? 0,
        'destination': item['destination']?.toString() ?? '',
        'duedate': item['dueDate']?.toString() ?? '',
        'time': item['time']?.toString() ?? '',
        'status': item['status']?.toString() ?? '',
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
