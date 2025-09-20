import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testapi/controller/SignaturePhotoController.dart';
import 'package:testapi/database/SignaturePhotoDB.dart';
import 'package:testapi/widgets/SignaturePhotoWidget.dart';
import 'package:testapi/widgets/app_bottom_nav.dart';
import '../controller/updateController.dart';
import '../controller/user_controller.dart';
import '../database/updateDB.dart';
import 'ListPageSchedule.dart';
import 'MapLauncherExample.dart';
import 'Profile.dart';

class SetRoutePage extends StatefulWidget {
  final int? userId;
  final int? taskId;

  const SetRoutePage({super.key, this.userId, this.taskId});

  @override
  State<SetRoutePage> createState() => _SetRoutePageState();
}

class _SetRoutePageState extends State<SetRoutePage> {
  final updateController = UpdateController(UpdateService());
  final signaturePhotoController = Signaturephotocontroller(SignaturePhotoDB());
  final UserController _userController = UserController();
  List<Map<String, dynamic>> tasks = [];
  int _bottomIndex = 0;
  String _userName = 'Kitty';

  String status = "pending";
  String buttonText = "Picked Up";

  void updateStatusBySignatureAndImage() {
    if (tasks.isEmpty) return;
    final sig = tasks.first['signature'];
    final img = tasks.first['image'];
    final newStatus = (sig == null && img == null) ? 'enroute' : 'delivered';
    if (status != newStatus) {
      setState(() {
        status = newStatus;
        for (var task in tasks) {
          task['status'] = newStatus;
        }
      });
    }
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

  void updateButtonText(String newStatus) {
    if (newStatus == "pending") {
      buttonText = "Picked Up";
    } else if (newStatus == "picked up") {
      buttonText = "Enroute";
    } else if (newStatus == "enroute") {
      buttonText = "Enroute";
    }
  }

  Future<void> _loadUserName() async {
    if (widget.userId != null) {
      try {
        final user = await _userController.getUserById(widget.userId!);
        if (user != null && user['name'] != null) {
          setState(() {
            _userName = user['name'].toString();
          });
        }
      } catch (e) {
        print('Error loading user name: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print(
      "SetRoutePage initState called with userId=${widget.userId}, taskId=${widget.taskId}",
    );
    fetchTasks();
    _loadUserName();
  }

  Future<void> fetchTasks() async {
    if (widget.userId == null || widget.taskId == null) return;

    print(
      "fetchTasks called with userId=${widget.userId}, taskId=${widget.taskId}",
    );

    final data = await updateController.fetchTaskDeliverDetails(
      userId: widget.userId!,
      taskId: widget.taskId!,
    );

    if (data != null && data.isNotEmpty) {
      // signature / image
      for (var task in data) {
        if (task['signature'] != null && task['signature'] is String) {
          try {
            task['signature'] = base64Decode(task['signature']);
            print("signature decoded, length=${task['signature'].length}");
          } catch (e) {
            print("signature decode failed: $e");
            task['signature'] = null;
          }
        }
        if (task['image'] != null && task['image'] is String) {
          try {
            task['image'] = base64Decode(task['image']);
            print("image decoded, length=${task['image'].length}");
          } catch (e) {
            print("image decode failed: $e");
            task['image'] = null;
          }
        }
      }

      setState(() {
        tasks = data; // now tasks signature / image already is Uint8List
        print("fetched task for taskId=${widget.taskId}: $tasks");

        status = tasks.first['status'] ?? "pending";
        updateButtonText(status);
      });
    } else {
      print(
        "No data found for userId=${widget.userId} and taskId=${widget.taskId}",
      );
    }
  }

  String getNextStatus(String currentStatus) {
    if (currentStatus == "pending") return "picked up";
    if (currentStatus == "picked up") return "enroute";
    return currentStatus;
  }

  void showStatusDialog(
    BuildContext context,
    String message, {
    bool isSuccess = true,
  }) {
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
        title: const Text("Set Route", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // check have status update if have then return true trigger load
            Navigator.pop(context, status != "pending");
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
                      status == "picked up" ||
                              status == "enroute" ||
                              status == "delivered" ||
                              status == "rejected"
                          ? "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/icon-park--delivery%20(1).png"
                          : "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/icon-park--delivery.png",
                      width: 45,
                      height: 45,
                      color: (status == "pending" && status != "rejected")
                          ? const Color(0xFFA0CFFF)
                          : Colors.white,
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                    const SizedBox(width: 14),
                    Image.network(
                      status == "enroute" ||
                              status == "delivered" ||
                              status == "rejected"
                          ? "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/streamline-cyber-color--pickup-truck%20(1).png"
                          : "https://idximjrqcfioksobtulx.supabase.co/storage/v1/object/public/updateStatus/streamline-cyber-color--pickup-truck.png",
                      width: 45,
                      height: 45,
                      color:
                          (status == "pending" || status == "picked up") &&
                              status != "rejected"
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
                      color:
                          status == "pending" ||
                              status == "picked up" ||
                              status == "enroute"
                          ? const Color(0xFFA0CFFF)
                          : (status == "rejected" ? null : Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // card area + signature/photo/reject
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount:
                        (status == 'enroute' ||
                            status == 'delivered' ||
                            status == 'rejected')
                        ? tasks.length + 1
                        : tasks.length,
                    itemBuilder: (context, index) {
                      // enroute / delivered status，last item is SignaturePhotoWidget + preview
                      if ((status == 'enroute' ||
                              status == 'delivered' ||
                              status == 'rejected') &&
                          index == tasks.length) {
                        // take the first task used for signature and photo preview(assume only have one task need signature/photo)
                        final previewTask = tasks.isNotEmpty
                            ? tasks.first
                            : null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: SignaturePhotoWidget(
                                signatureData: previewTask?['signature'],
                                imageData: previewTask?['image'],
                                userId: widget.userId,
                                taskId: widget.taskId,
                                status: status,
                                reasonOfRejected:
                                    previewTask?['reasonOfRejected'],
                                onSignatureSaved: (signature) async {
                                  if (signature != null &&
                                      signature.isNotEmpty) {
                                    final signatureStr = base64Encode(
                                      signature,
                                    );
                                    final success =
                                        await signaturePhotoController
                                            .updateConfirmationField(
                                              userId: widget.userId!,
                                              taskId: widget.taskId!,
                                              status: "delivered",
                                              fields: {
                                                "signature": signatureStr,
                                              },
                                            );
                                    if (success) {
                                      showStatusDialog(
                                        context,
                                        "The order is delivered successfully",
                                        isSuccess: true,
                                      );
                                      await fetchTasks();
                                      updateStatusBySignatureAndImage();
                                    }
                                  }
                                },
                                onPhotoTaken: (photo) async {
                                  if (photo != null && photo.isNotEmpty) {
                                    final photoStr = base64Encode(photo);
                                    final success =
                                        await signaturePhotoController
                                            .updateConfirmationField(
                                              userId: widget.userId!,
                                              taskId: widget.taskId!,
                                              status: "delivered",
                                              fields: {"image": photoStr},
                                            );
                                    if (success) {
                                      showStatusDialog(
                                        context,
                                        "The order is delivered successfully",
                                        isSuccess: true,
                                      );
                                      await fetchTasks();
                                      updateStatusBySignatureAndImage();
                                    }
                                  }
                                },
                                onReject: () {
                                  if (status == 'rejected') {
                                    setState(() {
                                      status = 'delivered';
                                      for (var task in tasks) {
                                        task['status'] = 'delivered';
                                      }
                                    });
                                    showStatusDialog(
                                      context,
                                      "Undo rejected, delivery marked as delivered",
                                      isSuccess: true,
                                    );
                                  } else {
                                    setState(() {
                                      status = 'rejected';
                                      for (var task in tasks) {
                                        task['status'] = 'rejected';
                                      }
                                    });
                                    showStatusDialog(
                                      context,
                                      "Delivery has been rejected",
                                      isSuccess: true,
                                    );
                                  }
                                },
                                onDataChanged: () async {
                                  await fetchTasks();
                                  updateStatusBySignatureAndImage();
                                },
                              ),
                            ),
                          ],
                        );
                      }
                      final task = tasks[index];
                      final formattedDateTime = formatDateTime(
                        task['duedate'],
                        task['time'],
                      );

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // title + subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['component_name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(task['workshop'] ?? ''),
                                    const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.black54,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            task['destination'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: Colors.black54,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(formattedDateTime),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.more_horiz,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MapLauncherExample(
                                        initialTaskId: widget.taskId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // button area
          if (status != "delivered" &&
              status != "rejected" &&
              status != "enroute")
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

                      final success = await updateController.updateStatus(
                        widget.userId!,
                        widget.taskId!,
                        nextStatus,
                      );
                      if (!success) {
                        showStatusDialog(
                          context,
                          "Failed to update status in database",
                          isSuccess: false,
                        );
                        return;
                      }

                      showStatusDialog(
                        context,
                        "Enroute Successful",
                        isSuccess: true,
                      );
                      await Future.delayed(const Duration(seconds: 1));
                    } else {
                      final success = await updateController.updateStatus(
                        widget.userId!,
                        widget.taskId!,
                        nextStatus,
                      );
                      if (success && mounted) {
                        setState(() {
                          status = nextStatus;
                          updateButtonText(status);
                          for (var task in tasks) {
                            task['status'] = nextStatus;
                          }
                        });

                        if (nextStatus == "picked up") {
                          showStatusDialog(
                            context,
                            "Picked Up Successful",
                            isSuccess: true,
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: AppBottomNav(
        selectedIndex: _bottomIndex,
        onTap: (index) {
          setState(() {
            _bottomIndex = index;
          });
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
                builder: (_) =>
                    ProfilePage(userId: widget.userId!, userName: _userName),
              ),
            );
          }
        },
      ),
    );
  }
}
