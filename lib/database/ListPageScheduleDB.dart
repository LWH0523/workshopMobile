import 'package:supabase_flutter/supabase_flutter.dart';

  class ListPageScheduleService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getTaskDeliverDetails({int? userId}) async {
    try {
      final query = _client
          .from('taskDeliver')
          .select('id, component_id, user_id, quantity, destination, dueDate, time, status, task_deliver_component(component(name, workshop)), component(name, workshop)');

      final response = userId != null ? await query.eq('user_id', userId) : await query;

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

      return data;
    } catch (e) {
      print('Error fetching taskDeliver details: $e');
      return null;
    }
  }

  // 獲取今天的訂單
  Future<List<Map<String, dynamic>>?> getTodayTaskDeliverDetails({int? userId}) async {
    try {
      // 獲取今天的日期 (YYYY-MM-DD 格式)
      final DateTime now = DateTime.now();
      final String today = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final query = _client
          .from('taskDeliver')
          .select('id, component_id, user_id, quantity, destination, dueDate, time, status, task_deliver_component(component(name, workshop)), component(name, workshop)')
          .eq('dueDate', today);

      final response = userId != null ? await query.eq('user_id', userId) : await query;

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

      return data;
    } catch (e) {
      print('Error fetching today taskDeliver details: $e');
      return null;
    }
  }
}
