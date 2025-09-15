import '../database/database_test.dart';

class detailController {
  // Fetch Task Deliver data
  Future<List<Map<String, dynamic>>> fetchTaskDeliverDetails() async {
    return await DatabaseTest.getTaskDeliverDetails();

  }
  Future<List<Map<String, dynamic>>> fetchComponentDetails() async {
    return await DatabaseTest.getComponentDetails();

  }

  Future<List<Map<String, dynamic>>> fetchComponentsByTaskId(dynamic taskId) async {
    return await DatabaseTest.getComponentsByTaskId(taskId);

  }

  Future<List<Map<String, dynamic>>> fetchComponentsByWorkshop(String workshop) async {
    return await DatabaseTest.getComponentsByWorkshop(workshop);

  }

  Future<Map<String, dynamic>?> fetchTaskWithComponents(int taskId) async {
    return await DatabaseTest.getTaskWithComponents(taskId);
  }

  // Run database connection test
  Future<Map<String, dynamic>> testConnection() async {
    return await DatabaseTest.testDatabaseConnection();

  }

  // Test the new task_delivery_component relationship
  Future<Map<String, dynamic>> testTaskDeliveryComponentRelationship() async {
    return await DatabaseTest.testTaskDeliveryComponentRelationship();
  }
}
