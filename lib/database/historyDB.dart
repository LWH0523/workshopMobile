import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getTask(
      {int? userId, int? taskId}) async {
    try {
      var query = _client.from('taskDeliver').select(
          'id, component_id, user_id, quantity, destination, dueDate, time, status, signature, image, task_deliver_component(component(name, workshop)), component(name, workshop)');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (taskId != null && taskId != 0) {
        query = query.eq('id', taskId);
      }

      final response = await query;
      final now = DateTime.now();

      final filtered = <Map<String, dynamic>>[];

      for (var item in (response as List)) {
        final status = item['status']?.toString() ?? '';
        final dueDateStr = item['dueDate']?.toString();
        DateTime? dueDate;

        if (dueDateStr != null && dueDateStr.isNotEmpty) {
          try {
            dueDate = DateTime.parse(dueDateStr);
          } catch (_) {}
        }

        // condition 1: already delivered/rejected
        if (status == 'delivered' || status == 'rejected') {
          filtered.add(item);
        } else if (dueDate != null) {
          final today = DateTime(now.year, now.month, now.day);
          final dueOnlyDate =
          DateTime(dueDate.year, dueDate.month, dueDate.day);

          if (dueOnlyDate.isBefore(today)) {
            // time out update database
            await _client
                .from('taskDeliver')
                .update({'status': 'time out'})
                .eq('id', item['id']);

            item['status'] = 'time out';
            filtered.add(item);
          }
        }
      }

      final List<Map<String, dynamic>> data = filtered.map((item) {
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
          'signature': item['signature']?.toString() ?? '',
          'image': item['image']?.toString() ?? '',
          'component_name':
          componentNames.isNotEmpty ? componentNames.first : '',
          'component_names': componentNames,
          'workshop': workshop,
        };
      }).toList();

      data.sort((a, b) => a['id'].compareTo(b['id']));
      print('DB fetched history data: $data'); // debug
      return data;
    } catch (e) {
      print('Error fetching taskDeliver details: $e');
      return null;
    }
  }
}