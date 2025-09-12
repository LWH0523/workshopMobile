import '../database/updateDB.dart';

class UpdateController {
  final UpdateService updateService;

  UpdateController(this.updateService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails({required String userId}) async {
    return await updateService.getTaskDeliverDetails(userId: userId); // ✅ 傳 userId
  }

  Future<bool> updateStatus(String userId, String status) async {
    return await updateService.updateTaskStatus(userId, status); // ✅ 傳 userId
  }

  Future<bool> checkSignatureOrImage(String userId) async {
    final tasks = await fetchTaskDeliverDetails(userId: userId);
    if (tasks == null || tasks.isEmpty) return false;

    for (var task in tasks) {
      if ((task['signature'] != null && task['signature']!.isNotEmpty) ||
          (task['image'] != null && task['image']!.isNotEmpty)) {
        return true; // 只要有一筆有就回 true
      }
    }
    return false;
  }

}
