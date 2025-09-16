import '../database/historyDB.dart';

class HistoryController {
  final HistoryService historyService;

  HistoryController(this.historyService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails({required int userId, required int taskId}) async {
    return await historyService.getTask(userId: userId, taskId: taskId);
  }
}