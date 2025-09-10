import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/updateDB.dart';

class SetRoutePage extends StatefulWidget {
  const SetRoutePage({super.key});

  @override
  State<SetRoutePage> createState() => _SetRoutePageState();
}

class _SetRoutePageState extends State<SetRoutePage> {
  final updateService = UpdateService();

  String formatDateTime(String? date, String? time) {
    if (date == null || time == null) return '';
    try {
      // 把 "2025-09-09" + "14:00:00" 合起來
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
                  "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/icon-park--delivery.png",
                  width: 45,
                  height: 45,
                  color: Color(0xFFA0CFFF),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                const SizedBox(width: 14),
                Image.network(
                  "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/streamline-cyber-color--pickup-truck.png",
                  width: 45,
                  height: 45,
                  color: Color(0xFFA0CFFF),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                const SizedBox(width: 14),
                Image.network(
                  "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/hugeicons--package-delivered.png",
                  width: 45,
                  height: 45,
                  color: Color(0xFFA0CFFF),
                ),
              ],
            ),
          ),
          ),
          ),

          // card area
          FutureBuilder(
            future: updateService.getTaskDeliverDetails(),
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
                        // Header Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D4CC8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task['id'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.more_vert, color: Colors.black54),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Text(
                          task['workshop'] ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.black54, size: 18),
                            const SizedBox(width: 6),
                            Text(task['destination'] ?? ''),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.black54, size: 18),
                            const SizedBox(width: 6),
                            Text(formattedDateTime),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.build,
                                color: Colors.black54, size: 18),
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
          // 🔹 Picked Up button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D4CC8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Picked Up",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),

      // NavigationBar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF2D4CC8),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
        ],
      ),
    );
  }
}
