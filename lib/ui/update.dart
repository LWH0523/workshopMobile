import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/updateController.dart';
import '../database/updateDB.dart';
import 'ListPageSchedule.dart';
import 'Profile.dart';
import 'confirmation.dart';

class SetRoutePage extends StatefulWidget {
  final int? userId;
  final int? taskId;
  const SetRoutePage({super.key, this.userId, this.taskId});

  @override
  State<SetRoutePage> createState() => _SetRoutePageState();
}

class _SetRoutePageState extends State<SetRoutePage> {
  final updateController = UpdateController(UpdateService());
  List<Map<String, dynamic>> tasks = [];
  int _bottomIndex = 0;

  String status = "pending";
  String buttonText = "Picked Up";

  String formatDateTime(String? date, String? time) {
    if (date == null || time == null) return '';
    try {
      final DateTime dt = DateTime.parse("$date $time");
      return DateFormat("dd-MM-yyyy h:mm a").format(dt);
    } catch (e) {
      return "$date $time";
    }
  }

  void updateButtonText(String newStatus) {
    if (newStatus == "pending") {
      buttonText = "Picked Up";
    } else if (newStatus == "picked up") {
      buttonText = "Enroute";
    } else if (newStatus == "enroute") {
      buttonText = "Enroute";
    }
  }

  @override
  void initState() {
    super.initState();
    print("SetRoutePage initState called with userId=${widget.userId}, taskId=${widget.taskId}");
    fetchTasks();
  }


  Future<void> fetchTasks() async {
    if (widget.userId == null || widget.taskId == null) return;

    print("fetchTasks called with userId=${widget.userId}, taskId=${widget.taskId}");

    final data = await updateController.fetchTaskDeliverDetails(
      userId: widget.userId!,
      taskId: widget.taskId!, // 傳入選定的 taskId
    );

    if (data != null && data.isNotEmpty) {
      setState(() {
        tasks = data; // data 應該只包含選定 task
        print("fetched task for taskId=${widget.taskId}: $tasks");

        status = tasks.first['status'] ?? "pending";
        updateButtonText(status);
      });
    } else {
      print("No data found for userId=${widget.userId} and taskId=${widget.taskId}");
    }
  }

  String getNextStatus(String currentStatus) {
    if (currentStatus == "pending") return "picked up";
    if (currentStatus == "picked up") return "enroute";
    return currentStatus;
  }

  void showStatusDialog(BuildContext context, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  isSuccess
                      ? 'https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/qlementine-icons--success-12.png'
                      : 'https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/lets-icons--sad.png',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4CC8),
        elevation: 0,
        title: const Text("Set Route", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
                      status == "picked up" || status == "enroute" || status == "delivered" || status == "rejected"
                          ? "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/icon-park--delivery%20(1).png"
                          : "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/icon-park--delivery.png",
                      width: 45,
                      height: 45,
                      color: (status == "pending" && status != "rejected") ? const Color(0xFFA0CFFF) : Colors.white,
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                    const SizedBox(width: 14),
                    Image.network(
                      status == "enroute" || status == "delivered" || status == "rejected"
                          ? "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/streamline-cyber-color--pickup-truck%20(1).png"
                          : "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/streamline-cyber-color--pickup-truck.png",
                      width: 45,
                      height: 45,
                      color: (status == "pending" || status == "picked up") && status != "rejected"
                          ? const Color(0xFFA0CFFF)
                          : Colors.white,
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                    const SizedBox(width: 14),
                    Image.network(
                      status == "delivered"
                          ? "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/hugeicons--package-delivered%20(1).png"
                          : status == "rejected"
                          ? "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/openmoji--cross-mark.png"
                          : "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/hugeicons--package-delivered.png",
                      width: 45,
                      height: 45,
                      color: status == "pending" || status == "picked up"
                          ? const Color(0xFFA0CFFF)
                          : (status == "rejected" ? null : Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // card area
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final formattedDateTime = formatDateTime(task['duedate'], task['time']);

                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      task['component_name'] ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(task['workshop'] ?? ''),
                        const SizedBox(height: 6),
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 按鈕區域
          if (status != "delivered" && status != "rejected")
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
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
                  onPressed: () async {
                    if (tasks.isEmpty) return;

                    final nextStatus = getNextStatus(status);

                    if (nextStatus == "enroute") {
                      setState(() {
                        status = nextStatus;
                        updateButtonText(status);
                        for (var task in tasks) {
                          task['status'] = nextStatus;
                        }
                      });

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConfirmationPage(),
                        ),
                      );

                      final hasConfirmation = await updateController.checkSignatureOrImage(widget.userId!, widget.taskId!);

                      String finalStatus;
                      if (hasConfirmation) {
                        finalStatus = "delivered";
                        showStatusDialog(context, "Delivered Successful", isSuccess: true);
                      } else {
                        finalStatus = "rejected";
                        showStatusDialog(context, "Delivery has been Rejected", isSuccess: false);
                      }

                      final success = await updateController.updateStatus(widget.userId!, widget.taskId!, finalStatus);
                      if (success && mounted) {
                        setState(() {
                          status = finalStatus;
                          for (var task in tasks) {
                            task['status'] = finalStatus;
                          }
                        });
                      }
                    } else {
                      final success = await updateController.updateStatus(widget.userId!, widget.taskId!, nextStatus);
                      if (success && mounted) {
                        setState(() {
                          status = nextStatus;
                          updateButtonText(status);
                          for (var task in tasks) {
                            task['status'] = nextStatus;
                          }
                        });

                        if (nextStatus == "picked up") {
                          showStatusDialog(context, "Picked Up Successful", isSuccess: true);
                        }
                      }
                    }
                  },
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        selectedItemColor: const Color(0xFF2D4CC8),
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListPageSchedule(userId: widget.userId),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(userId: widget.userId!, userName: '',),
              ),
            );
          }
          setState(() {
            _bottomIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}