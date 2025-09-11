import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controller/ListPageScheduleController.dart';
import '../database/ListPageScheduleDB.dart';
import 'update.dart';

class ListPageSchedule extends StatefulWidget {
  const ListPageSchedule({super.key});

  @override
  State<ListPageSchedule> createState() => _ListPageScheduleState();
}

class _ListPageScheduleState extends State<ListPageSchedule> {
  final ListPageScheduleController _controller = ListPageScheduleController(ListPageScheduleService());

  String _formatDateTime(String? date, String? time) {
    if (date == null || time == null) return '';
    try {
      final DateTime dt = DateTime.parse("$date $time");
      return DateFormat("dd-MM-yyyy h:mm a").format(dt);
    } catch (_) {
      return "$date $time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text('Kitty', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person_outline),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top toggle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D4CC8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: const Text('Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EFFD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: const Text('Today', style: TextStyle(color: Color(0xFF2D4CC8), fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Summary pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FutureBuilder<List<Map<String, dynamic>>?>(
              future: _controller.fetchTaskDeliverDetails(),
              builder: (context, snapshot) {
                final int count = (snapshot.data?.length ?? 0);
                return Container(
                  width: double.infinity,
                  height: 44,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EFFD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF2A2E3B)),
                      children: [
                        const TextSpan(text: 'You have '),
                        TextSpan(text: '$count deliveries '),
                        const TextSpan(text: 'Future', style: TextStyle(color: Color(0xFF2D4CC8), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // List of cards
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>?>(
              future: _controller.fetchTaskDeliverDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return const Center(child: Text('No deliveries'));
                }

                final List<Map<String, dynamic>> tasks = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final deliveryStatus = task['status'] as String?;
                    final displayStatus = _controller.getDisplayStatus(deliveryStatus);
                    final statusColor = _controller.getStatusColor(displayStatus);
                    
                    return _ScheduleCard(
                      id: task['id'] ?? '',
                      workshop: task['workshop'] ?? '',
                      destination: task['destination'] ?? '',
                      dateTime: _formatDateTime(task['duedate'] as String?, task['time'] as String?),
                      component: task['component_name'] ?? '',
                      status: displayStatus,
                      statusColor: statusColor,
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemCount: tasks.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String id;
  final String workshop;
  final String destination;
  final String dateTime;
  final String component;
  final String status;
  final Color statusColor;

  const _ScheduleCard({
    required this.id,
    required this.workshop,
    required this.destination,
    required this.dateTime,
    required this.component,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 根据不同的条件导航到不同页面
        _navigateToPage(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8EF)),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar with id and menu
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2D4CC8),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(id, style: const TextStyle(color: Color(0xFF2D4CC8), fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status, 
                    style: TextStyle(
                      color: statusColor == const Color(0xFF4CAF50) ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workshop, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(child: Text(destination)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(dateTime),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.build_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(component),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      ),
    );
  }

  void _navigateToPage(BuildContext context) {
    // 根据不同的条件导航到不同页面
    // 这里可以根据 id、status 或其他条件来决定导航到哪个页面
    
    if (status.toLowerCase() == 'pending') {
      // 如果状态是 Pending，导航到 update 页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetRoutePage(),
        ),
      );
    } else if (status.toLowerCase() == 'complete') {
      // 如果状态是 Complete，可以导航到详情页面或其他页面
      // 这里先导航到 update 页面，您可以根据需要修改
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetRoutePage(),
        ),
      );
    } else {
      // 默认导航到 update 页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetRoutePage(),
        ),
      );
    }
  }
}


