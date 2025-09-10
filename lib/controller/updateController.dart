import '../database/updateDB.dart';

class UpdateController {
  final UpdateService updateService;

  UpdateController(this.updateService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails() async {
    return await updateService.getTaskDeliverDetails();
  }
}
