import 'dart:ui';
import '../database/ListPageScheduleDB.dart';

class ListPageScheduleController {
  final ListPageScheduleService scheduleService;

  ListPageScheduleController(this.scheduleService);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails({int? userId}) async {
    final allTasks = await scheduleService.getTaskDeliverDetails(userId: userId);
    if (allTasks == null) return null;

    final DateTime now = DateTime.now();
    final DateTime nowDate = DateTime(now.year, now.month, now.day);
    final DateTime dayAfterTomorrow = now.add(const Duration(days: 2));
    final DateTime threeDaysLater = now.add(const Duration(days: 3));

    print('Schedule filter: Today=${nowDate.day}/${nowDate.month}, Showing tasks from ${nowDate.add(const Duration(days: 1)).day}/${nowDate.add(const Duration(days: 1)).month} to ${dayAfterTomorrow.day}/${dayAfterTomorrow.month}');

    final futureTasks = allTasks.where((task) {
      final taskDate = task['duedate'] as String?;
      if (taskDate == null) return false;

      try {
        final DateTime taskDateTime = DateTime.parse(taskDate);
        final DateTime taskDateOnly = DateTime(taskDateTime.year, taskDateTime.month, taskDateTime.day);

        final bool isInRange = taskDateOnly.isAfter(nowDate) && taskDateOnly.isBefore(threeDaysLater);
        print('Task ${task['id']}: taskDate=$taskDate, nowDate=${nowDate.year}-${nowDate.month}-${nowDate.day}, isInRange=$isInRange');

        return isInRange;
      } catch (e) {
        print('Date parse error for task ${task['id']}: $e, date: $taskDate');
        return false;
      }
    }).toList();

    print('Schedule: Found ${allTasks.length} total tasks, filtered to ${futureTasks.length} tasks for next 2 days');
    return futureTasks;
  }

  Future<List<Map<String, dynamic>>?> fetchTodayTaskDeliverDetails({int? userId}) async {
    final todayTasks = await scheduleService.getTodayTaskDeliverDetails(userId: userId);
    if (todayTasks == null) {
      print('fetchTodayTaskDeliverDetails: todayTasks is null');
      return null;
    }

    print('fetchTodayTaskDeliverDetails: Found ${todayTasks.length} tasks for today');

    for (var task in todayTasks) {
      final status = task['status'] as String?;
      final displayStatus = getDisplayStatus(status);
      print('Task ${task['id']}: status=$status, displayStatus=$displayStatus');
    }

    return todayTasks;
  }

  Future<int> getPendingDeliveriesCount({int? userId}) async {
    final allTasks = await scheduleService.getTaskDeliverDetails(userId: userId);
    if (allTasks == null) return 0;

    final DateTime now = DateTime.now();
    final DateTime nowDate = DateTime(now.year, now.month, now.day);
    final DateTime threeDaysLater = now.add(const Duration(days: 3));

    print('Future count filter: Today=${nowDate.day}/${nowDate.month}, Counting tasks from ${nowDate.add(const Duration(days: 1)).day}/${nowDate.add(const Duration(days: 1)).month} to ${nowDate.add(const Duration(days: 2)).day}/${nowDate.add(const Duration(days: 2)).month}');

    int count = 0;
    for (var task in allTasks) {
      final taskDate = task['duedate'] as String?;
      if (taskDate == null) continue;

      try {
        final DateTime taskDateTime = DateTime.parse(taskDate);
        final DateTime taskDateOnly = DateTime(taskDateTime.year, taskDateTime.month, taskDateTime.day);

        final bool isInRange = taskDateOnly.isAfter(nowDate) && taskDateOnly.isBefore(threeDaysLater);

        if (isInRange) {
          final status = task['status'] as String?;
          final displayStatus = getDisplayStatus(status);
          if (displayStatus == 'Pending') {
            count++;
            print('Future count: Task ${task['id']} (${taskDate}) is pending and in range, count=$count');
          } else if (displayStatus == 'Rejected') {
            print('Future count: Task ${task['id']} (${taskDate}) is rejected, not counting');
          }
        }
      } catch (e) {
        print('Future count: Date parse error for task ${task['id']}: $e, date: $taskDate');
      }
    }

    print('Future count: Found $count pending tasks in next 2 days');
    return count;
  }

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

  Future<int> getTodayPendingDeliveriesCount({int? userId}) async {
    final todayTasks = await scheduleService.getTodayTaskDeliverDetails(userId: userId);
    if (todayTasks == null) return 0;

    int count = 0;
    for (var task in todayTasks) {
      final status = task['status'] as String?;
      final displayStatus = getDisplayStatus(status);
      if (displayStatus == 'Pending') {
        count++;
        print('Today count: Task ${task['id']} is pending, count=$count');
      } else if (displayStatus == 'Rejected') {
        print('Today count: Task ${task['id']} is rejected, not counting');
      }
    }
    return count;
  }

  String getDisplayStatus(String? deliveryStatus) {
    if (deliveryStatus == null) return 'Pending';

    switch (deliveryStatus.toLowerCase()) {
      case 'picked up':
      case 'en route':
        return 'Pending';
      case 'delivered':
      case 'completed':
      case 'complement':
        return 'Complete';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFE0B3);
      case 'complete':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFFFFA500);
    }
  }
}
