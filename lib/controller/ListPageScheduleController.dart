import 'dart:ui';
import '../database/ListPageScheduleDB.dart';

class ListPageScheduleController {
  final ListPageScheduleService scheduleService;

  ListPageScheduleController(this.scheduleService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails({int? userId}) async {
    return await scheduleService.getTaskDeliverDetails(userId: userId);
  }

  // 根据 delivery status 确定显示状态
  String getDisplayStatus(String? deliveryStatus) {
    if (deliveryStatus == null) return 'Pending';

    switch (deliveryStatus.toLowerCase()) {
      case 'picked up':
      case 'en route':
        return 'Pending';
      case 'delivered':
        return 'Complete';
      default:
        return 'Pending';
    }
  }

  // 根据状态获取状态颜色
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFE0B3); // 米黃色
      case 'complete':
        return const Color(0xFF4CAF50); // 綠色
      default:
        return const Color(0xFFFFA500); // 橙色
    }
  }
}
