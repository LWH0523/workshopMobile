import 'package:supabase_flutter/supabase_flutter.dart';

class ListPageScheduleService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getTaskDeliverDetails({int? userId}) async {
    try {
      final query = _client
          .from('taskDeliver')
          .select('id, component_id, user_id, quantity, destination, dueDate, time, status, contact_number, task_deliver_component(component(name, workshop)), component(name, workshop)');

      final response = userId != null ? await query.eq('user_id', userId) : await query;

      print(' All dates in DB:');
      for (var item in response) {
        print('  - ID: ${item['id']}, dueDate: ${item['dueDate']}, user_id: ${item['user_id']}');
      }

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
          'contact_number': item['contact_number'],
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

  // Get today's tasks
  Future<List<Map<String, dynamic>>?> getTodayTaskDeliverDetails({int? userId}) async {
    try {
      // Get today's date (YYYY-MM-DD format)
      final DateTime now = DateTime.now();
      final String today = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      print('Current date: ${now.year}-${now.month}-${now.day}');
      print('Today filter: $today, userId: $userId');

      // First query all records to check what exists in the database
      final allQuery = _client
          .from('taskDeliver')
          .select('id, dueDate, user_id, status');
      final allResponse = userId != null ? await allQuery.eq('user_id', userId) : await allQuery;
      print('All records in DB:');
      for (var item in allResponse) {
        print('  - ID: ${item['id']}, dueDate: ${item['dueDate']}, userId: ${item['user_id']}, status: ${item['status']}');
      }

      final query = _client
          .from('taskDeliver')
          .select('id, component_id, user_id, quantity, destination, dueDate, time, status, contact_number, task_deliver_component(component(name, workshop)), component(name, workshop)')
          .eq('dueDate', today);

      final response = userId != null ? await query.eq('user_id', userId) : await query;

      print('Today query result count: ${(response as List).length}');
      print('Today query SQL: SELECT * FROM taskDeliver WHERE dueDate = $today${userId != null ? ' AND user_id = $userId' : ''}');

      // Print detailed information of query result
      for (var item in response) {
        print('Found today task: ID=${item['id']}, dueDate=${item['dueDate']}, userId=${item['user_id']}, status=${item['status']}');
      }

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
          'contact_number': item['contact_number'],
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
