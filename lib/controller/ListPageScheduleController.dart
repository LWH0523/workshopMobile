import 'dart:ui';
import '../database/ListPageScheduleDB.dart';

class ListPageScheduleController {
  final ListPageScheduleService scheduleService;

  ListPageScheduleController(this.scheduleService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails({int? userId}) async {
    final allTasks = await scheduleService.getTaskDeliverDetails(userId: userId);
    if (allTasks == null) return null;

    // 計算未來兩天的日期範圍（不包括今天）
    final DateTime now = DateTime.now();
    final DateTime nowDate = DateTime(now.year, now.month, now.day);
    final DateTime dayAfterTomorrow = now.add(const Duration(days: 2));
    final DateTime threeDaysLater = now.add(const Duration(days: 3));

    print('🔍 Schedule filter: Today=${nowDate.day}/${nowDate.month}, Showing tasks from ${nowDate.add(const Duration(days: 1)).day}/${nowDate.add(const Duration(days: 1)).month} to ${dayAfterTomorrow.day}/${dayAfterTomorrow.month}');

    final futureTasks = allTasks.where((task) {
      final taskDate = task['duedate'] as String?;
      if (taskDate == null) return false;
      
      try {
        final DateTime taskDateTime = DateTime.parse(taskDate);
        final DateTime taskDateOnly = DateTime(taskDateTime.year, taskDateTime.month, taskDateTime.day);
        
        // 只顯示明天和後天的任務（不包括今天，不包括3天後）
        final bool isInRange = taskDateOnly.isAfter(nowDate) && taskDateOnly.isBefore(threeDaysLater);
        print('🔍 Task ${task['id']}: taskDate=$taskDate, nowDate=${nowDate.year}-${nowDate.month}-${nowDate.day}, isInRange=$isInRange');
        
        return isInRange;
      } catch (e) {
        print('🔍 Date parse error for task ${task['id']}: $e, date: $taskDate');
        return false;
      }
    }).toList();

    print('🔍 Schedule: Found ${allTasks.length} total tasks, filtered to ${futureTasks.length} tasks for next 2 days');
    return futureTasks;
  }

  // 獲取今天的訂單
  Future<List<Map<String, dynamic>>?> fetchTodayTaskDeliverDetails({int? userId}) async {
    final todayTasks = await scheduleService.getTodayTaskDeliverDetails(userId: userId);
    if (todayTasks == null) {
      print('🔍 fetchTodayTaskDeliverDetails: todayTasks is null');
      return null;
    }

    print('🔍 fetchTodayTaskDeliverDetails: Found ${todayTasks.length} tasks for today');
    
    // 打印所有任務的狀態
    for (var task in todayTasks) {
      final status = task['status'] as String?;
      final displayStatus = getDisplayStatus(status);
      print('🔍 Task ${task['id']}: status=$status, displayStatus=$displayStatus');
    }

    // 返回今天的所有任務（不管是Pending還是Complete）
    return todayTasks;
  }

  // 獲取待處理的訂單數量 (根據 getDisplayStatus 判斷) - 只計算未來2天
  Future<int> getPendingDeliveriesCount({int? userId}) async {
    final allTasks = await scheduleService.getTaskDeliverDetails(userId: userId);
    if (allTasks == null) return 0;

    // 計算未來兩天的日期範圍（不包括今天）
    final DateTime now = DateTime.now();
    final DateTime nowDate = DateTime(now.year, now.month, now.day);
    final DateTime threeDaysLater = now.add(const Duration(days: 3));

    print('🔍 Future count filter: Today=${nowDate.day}/${nowDate.month}, Counting tasks from ${nowDate.add(const Duration(days: 1)).day}/${nowDate.add(const Duration(days: 1)).month} to ${nowDate.add(const Duration(days: 2)).day}/${nowDate.add(const Duration(days: 2)).month}');

    int count = 0;
    for (var task in allTasks) {
      final taskDate = task['duedate'] as String?;
      if (taskDate == null) continue;
      
      try {
        final DateTime taskDateTime = DateTime.parse(taskDate);
        final DateTime taskDateOnly = DateTime(taskDateTime.year, taskDateTime.month, taskDateTime.day);
        
        // 只計算明天和後天的任務（不包括今天，不包括3天後）
        final bool isInRange = taskDateOnly.isAfter(nowDate) && taskDateOnly.isBefore(threeDaysLater);
        
        if (isInRange) {
          final status = task['status'] as String?;
          final displayStatus = getDisplayStatus(status);
          if (displayStatus == 'Pending') {
            count++;
            print('🔍 Future count: Task ${task['id']} (${taskDate}) is pending and in range, count=$count');
          }
        }
      } catch (e) {
        print('🔍 Future count: Date parse error for task ${task['id']}: $e, date: $taskDate');
      }
    }
    
    print('🔍 Future count: Found $count pending tasks in next 2 days');
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