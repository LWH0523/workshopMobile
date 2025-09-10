import '../database/updateDB.dart';

class UpdateController {
  final UpdateService updateService;

  UpdateController(this.updateService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails() async {
    return await updateService.getTaskDeliverDetails();
  }

  Future<bool> updateStatus(String taskId, String status) async {
    return await updateService.updateTaskStatus(taskId, status);
  }

}
