import '../database/updateDB.dart';

class UpdateController {
  final UpdateService updateService;

  UpdateController(this.updateService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails({required int userId, required int taskId}) async {
    return await updateService.getTaskDeliverDetails(userId: userId, taskId: taskId);
  }

  Future<bool> updateStatus(int userId, int taskId, String status) async {
    return await updateService.updateTaskStatus(userId, taskId, status);
  }

  Future<bool> checkSignatureOrImage(int userId, int taskId) async {
    final tasks = await fetchTaskDeliverDetails(userId: userId, taskId: taskId);
    if (tasks == null || tasks.isEmpty) return false;

    for (var task in tasks) {
      if ((task['signature'] != null && task['signature']!.isNotEmpty) ||
          (task['image'] != null && task['image']!.isNotEmpty)) {
        return true;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>?> fetchTaskById({required int userId, required int taskId}) async {
    final tasks = await fetchTaskDeliverDetails(userId: userId, taskId: taskId);
    if (tasks == null || tasks.isEmpty) return null;
    return tasks.first;
  }
}
