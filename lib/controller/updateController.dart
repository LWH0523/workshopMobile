import '../database/updateDB.dart';

class UpdateController {
  final UpdateService updateService;

  UpdateController(this.updateService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails({required int userId}) async {
    return await updateService.getTaskDeliverDetails(userId: userId);
  }

  Future<bool> updateStatus(int userId, String status) async {
    return await updateService.updateTaskStatus(userId, status);
  }

  Future<bool> checkSignatureOrImage(int userId) async {
    final tasks = await fetchTaskDeliverDetails(userId: userId);
    if (tasks == null || tasks.isEmpty) return false;

    for (var task in tasks) {
      if ((task['signature'] != null && task['signature']!.isNotEmpty) ||
          (task['image'] != null && task['image']!.isNotEmpty)) {
        return true;
      }
    }
    return false;
  }
}
