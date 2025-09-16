import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getTask(
      {int? userId, int? taskId}) async {
    try {
      var query = _client
          .from('taskDeliver')
          .select('id, component_id, user_id, quantity, destination, dueDate, time, status, signature, image, task_deliver_component(component(name, workshop)), component(name, workshop)');

      if (userId != null) {
        query = query.eq('user_id', userId);

      }

      // 只有當 taskId 非空且不為 0 時才篩選
      if (taskId != null && taskId != 0) {
        query = query.eq('id', taskId);
      }

      final response = await query;

      final List<Map<String, dynamic>> data =
      (response as List).map((item) {
        final List components = (item['task_deliver_component'] as List?) ?? [];
        final List<String> componentNames = components
            .map((c) => c['component']?['name']?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .cast<String>()
            .toList();
        final String workshop = components.isNotEmpty
            ? (components.first['component']?['workshop']?.toString() ?? '')
            : (item['component']?['workshop']?.toString() ?? '');
        if (componentNames.isEmpty && item['component'] != null) {
          final fallbackName = item['component']?['name']?.toString();
          if (fallbackName != null && fallbackName.isNotEmpty) {
            componentNames.add(fallbackName);
          }
        }

        return {
          'id': (item['id'] as num?)?.toInt() ?? 0,
          'component_id': (item['component_id'] as num?)?.toInt() ?? 0,
          'user_id': (item['user_id'] as num?)?.toInt() ?? 0,
          'quantity': (item['quantity'] as num?)?.toInt() ?? 0,
          'destination': item['destination']?.toString() ?? '',
          'duedate': item['dueDate']?.toString() ?? '',
          'time': item['time']?.toString() ?? '',
          'status': item['status']?.toString() ?? '',
          'component_name': componentNames.isNotEmpty ? componentNames.first : '',
          'component_names': componentNames,
          'workshop': workshop,
        };
      }).toList();

      data.sort((a, b) => a['id'].compareTo(b['id']));
      print('DB fetched data: $data'); // debug
      return data;
    } catch (e) {
      print('Error fetching taskDeliver details: $e');
      return null;
    }
  }
}