import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controller/historyController.dart';
import '../database/historyDB.dart';
import 'MapLauncherExample.dart';

class HistoryPage extends StatefulWidget {
  final int userId;
  final int taskId;

  const HistoryPage({super.key, required this.userId, required this.taskId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final historyController = HistoryController(HistoryService());
  late Future<List<Map<String, dynamic>>?> _taskFuture;
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  // 展開狀態用 Map 儲存，不然多個卡片會互相干擾
  final Map<int, bool> _expandedMap = {};

  @override
  void initState() {
    super.initState();
    _taskFuture = _loadTasks();
  }

  Future<List<Map<String, dynamic>>?> _loadTasks() async {
    final data = await historyController.fetchTaskDeliverDetails(
      userId: widget.userId,
      taskId: widget.taskId,
    );
    if (mounted) {
      setState(() {
        _tasks = data ?? [];
        _isLoading = false;
      });
    }
    return data;
  }

  String formatDateTime(String? date, String? time) {
    if (date == null || time == null) return '';
    try {
      final DateTime dt = DateTime.parse("$date $time");
      return DateFormat("dd-MM-yyyy h:mm a").format(dt);
    } catch (e) {
      return "$date $time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4CC8),
        elevation: 0,
        title: const Text("History", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? const Center(child: Text('No delivered or rejected tasks.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final status = task['status'] ?? 'pending';
          final formattedDateTime =
          formatDateTime(task['duedate'], task['time']);

          // components list
          final List<String> allNames =
              (task['component_names'] as List?)?.cast<String>() ??
                  (task['component_name'] != null
                      ? [task['component_name'].toString()]
                      : []);

          final bool isExpanded = _expandedMap[index] ?? false;

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(
                vertical: 10, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D4CC8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  child: Row(
                    children: [
                      // 🆔 ID
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "T${task['id']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4CC8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 📦 Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: status == 'delivered'
                              ? Colors.green
                              : status == 'rejected'
                              ? Colors.red
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (status ?? 'pending')
                              .toString()
                              .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase()),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // 🔹 三個點，跳去 MapLauncherExample
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.more_horiz,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapLauncherExample(initialTaskId: widget.userId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 🔹 下半部分 (白色背景, 卡內容)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🏭 Workshop
                      Text(
                        task['workshop'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 📍 Destination
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              task['destination'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 📅 Date & Time
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            formattedDateTime,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 🔧 Components with dropdown
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.build_outlined,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(allNames.isNotEmpty
                                ? allNames.first
                                : ''),
                          ),
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _expandedMap[index] = !isExpanded;
                              });
                            },
                          ),
                        ],
                      ),
                      if (isExpanded && allNames.length > 1) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              for (int i = 1;
                              i < allNames.length;
                              i++)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 2),
                                  child: Text(allNames[i]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
