import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/updateController.dart';
import '../database/updateDB.dart';

class SetRoutePage extends StatefulWidget {
  const SetRoutePage({super.key, required String userId});

  @override
  State<SetRoutePage> createState() => _SetRoutePageState();
}

class _SetRoutePageState extends State<SetRoutePage> {
  final updateController = UpdateController(UpdateService());
  Map<String, dynamic>? selectedTask;

  // 按鈕文字狀態
  String buttonText = "Picked Up";

  // 是否已經被 picked up / enroute / delivered
  String status = "pending"; // possible: pending, picked up, enroute, delivered

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4CC8),
        elevation: 0,
        title: const Text("Set Route"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          // flow
          Container(
            width: double.infinity,
            height: 100,
            color: const Color(0xFF2D4CC8),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      status == "picked up" || status == "enroute" || status == "delivered"
                          ? "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/icon-park--delivery%20(1).png"
                          : "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/icon-park--delivery.png",
                      width: 45,
                      height: 45,
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                    const SizedBox(width: 14),
                    Image.network(
                      status == "enroute" || status == "delivered"
                          ? "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/streamline-cyber-color--pickup-truck.png"
                          : "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/streamline-cyber-color--pickup-truck.png",
                      width: 45,
                      height: 45,
                      color: status == "pending" ? const Color(0xFFA0CFFF) : null,
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                    const SizedBox(width: 14),
                    Image.network(
                      status == "delivered"
                          ? "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/hugeicons--package-delivered.png"
                          : "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/hugeicons--package-delivered.png",
                      width: 45,
                      height: 45,
                      color: status == "pending" || status == "picked up" ? const Color(0xFFA0CFFF) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // card area
          FutureBuilder(
            future: updateController.fetchTaskDeliverDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("No data found")),
                );
              }

              final tasks = snapshot.data!;
              final task = tasks.isNotEmpty ? tasks.first : null;

              if (task == null) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("No task available")),
                );
              }

              final formattedDateTime = formatDateTime(
                task['duedate'] as String?,
                task['time'] as String?,
              );

              selectedTask = task;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D4CC8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task['id'] ?? '',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.more_vert, color: Colors.black54),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          task['workshop'] ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: Colors.black54, size: 18),
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
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.black54, size: 18),
                            const SizedBox(width: 6),
                            Text(formattedDateTime),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.build, color: Colors.black54, size: 18),
                            const SizedBox(width: 6),
                            Text(task['component_name'] ?? ''),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const Spacer(),

          // 按鈕區域
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D4CC8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                if (selectedTask == null) return;

                String nextStatus;
                if (status == "pending") {
                  nextStatus = "picked up";
                } else if (status == "picked up") {
                  nextStatus = "enroute";
                } else if (status == "enroute") {
                  nextStatus = "delivered";
                } else {
                  return; // delivered 已完成
                }

                final success = await updateController.updateStatus(
                  selectedTask!['id'].toString(),
                  nextStatus,
                );

                if (success && mounted) {
                  setState(() {
                    status = nextStatus;
                    if (status == "picked up") {
                      buttonText = "Enroute";
                    } else if (status == "enroute") {
                      buttonText = "Delivered";
                    } else if (status == "delivered") {
                      buttonText = "Delivered"; // 最後狀態
                    }
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Status updated to ${nextStatus.replaceAll('_', ' ').toUpperCase()}")),
                  );
                }
              },
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF2D4CC8),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
        ],
      ),
    );
  }
}
