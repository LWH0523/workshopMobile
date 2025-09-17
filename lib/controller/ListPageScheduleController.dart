import 'dart:ui';
import '../database/ListPageScheduleDB.dart';

class ListPageScheduleController {
  final ListPageScheduleService scheduleService;

  ListPageScheduleController(this.scheduleService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails({int? userId}) async {
    return await scheduleService.getTaskDeliverDetails(userId: userId);
  }

  // 獲取今天的訂單
  Future<List<Map<String, dynamic>>?> fetchTodayTaskDeliverDetails({int? userId}) async {
    final todayTasks = await scheduleService.getTodayTaskDeliverDetails(userId: userId);
    if (todayTasks == null) return null;

    // 只返回今天且狀態為pending的任務
    return todayTasks.where((task) {
      final status = task['status'] as String?;
      final displayStatus = getDisplayStatus(status);
      return displayStatus == 'Pending';
    }).toList();
  }

  // 獲取待處理的訂單數量 (根據 getDisplayStatus 判斷)
  Future<int> getPendingDeliveriesCount({int? userId}) async {
    final allTasks = await scheduleService.getTaskDeliverDetails(userId: userId);
    if (allTasks == null) return 0;

    int count = 0;
    for (var task in allTasks) {
      final status = task['status'] as String?;
      final displayStatus = getDisplayStatus(status);
      if (displayStatus == 'Pending') {
        count++;
      }
    }
    return count;
  }

  // 獲取完成的訂單數量 (顯示狀態為 Complete)
  Future<int> getCompleteDeliveriesCount({int? userId}) async {
    final allTasks = await scheduleService.getTaskDeliverDetails(userId: userId);
    if (allTasks == null) return 0;

    int count = 0;
    for (var task in allTasks) {
      final status = task['status'] as String?;
      final displayStatus = getDisplayStatus(status);
      if (displayStatus == 'Complete') {
        count++;
      }
    }
    return count;
  }

  // 獲取今天待處理的訂單數量
  Future<int> getTodayPendingDeliveriesCount({int? userId}) async {
    final todayTasks = await scheduleService.getTodayTaskDeliverDetails(userId: userId);
    if (todayTasks == null) return 0;

    int count = 0;
    for (var task in todayTasks) {
      final status = task['status'] as String?;
      final displayStatus = getDisplayStatus(status);
      if (displayStatus == 'Pending') {
        count++;
      }
    }
    return count;
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