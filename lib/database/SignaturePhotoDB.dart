import 'package:supabase_flutter/supabase_flutter.dart';

class SignaturePhotoDB {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getTaskDeliverDetails({
    int? userId,
    int? taskId,
  }) async {
    try {
      var query = _client
          .from('taskDeliver')
          .select(
            'id, component_id, user_id, quantity, destination, dueDate, time, status, signature, image, component(name, workshop)',
          );

      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      if (taskId != null) query = query.eq('id', taskId);

      final response = await query;

      final List<Map<String, dynamic>> data = (response as List)
          .map(
            (item) => {
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
            },
          )
          .toList();

      data.sort((a, b) => a['id'].compareTo(b['id']));
      print('DB fetched data(signaturePhotoDB): $data'); // debug
      return data;
    } catch (e) {
      print('Error fetching taskDeliver details: $e');
      return null;
    }
  }

  Future<bool> updateConfirmationField({
    required int userId,
    required int taskId,
    required String status,
    required Map<String, String> fields,
  }) async {
    try {
      final tasks = await getTaskDeliverDetails(userId: userId, taskId: taskId);
      if (tasks == null || tasks.isEmpty) return false;

      final task = tasks.first;

      final Map<String, dynamic> updateData = {'status': status};

      fields.forEach((key, value) {
        if (key == 'signature' &&
            (task['signature'] == null || task['signature']!.isEmpty)) {
          updateData['signature'] = value;
        } else if (key == 'image' &&
            (task['image'] == null || task['image']!.isEmpty)) {
          updateData['image'] = value;
        } else if (key == 'reasonOfRejected') {
          updateData['reasonOfRejected'] = value;
        }
      });

      if (updateData.length <= 1) return false; // No fields to update

      await _client
          .from('taskDeliver')
          .update(updateData)
          .eq('id', taskId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print("Error updating confirmation field: $e");
      return false;
    }
  }

  Future<bool> clearConfirmationFields({
    required int userId,
    required int taskId,
    bool clearSignature = false,
    bool clearImage = false,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (clearSignature) updateData['signature'] = null;
      if (clearImage) updateData['image'] = null;
      if (updateData.isEmpty) return false;

      await _client
          .from('taskDeliver')
          .update(updateData)
          .eq('id', taskId)
          .eq('user_id', userId);

      final tasks = await getTaskDeliverDetails(userId: userId, taskId: taskId);
      if (tasks != null && tasks.isNotEmpty) {
        final task = tasks.first;
        final sigEmpty =
            task['signature'] == null || task['signature'].toString().isEmpty;
        final imgEmpty =
            task['image'] == null || task['image'].toString().isEmpty;
        if (sigEmpty && imgEmpty) {
          await _client
              .from('taskDeliver')
              .update({'status': 'enroute'})
              .eq('id', taskId)
              .eq('user_id', userId);
          print(
            'Status set to enroute because both signature and image are empty',
          );
        }
      }
      return true;
    } catch (e) {
      print("Error clearing confirmation fields: $e");
      return false;
    }
  }
}
