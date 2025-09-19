import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../controller/detailController.dart';

class MapLauncherExample extends StatefulWidget {
  final int? initialTaskId;
  const MapLauncherExample({super.key, this.initialTaskId});

  @override
  State<MapLauncherExample> createState() => _MapLauncherExampleState();
}

class _MapLauncherExampleState extends State<MapLauncherExample> {
  final detailController _controller = detailController();
  bool isLoading = true;
  List<Map<String, dynamic>> taskItems = [];
  int? selectedTaskId;
  Map<String, dynamic>? selectedTaskData;
  List<Map<String, dynamic>> selectedTaskComponents = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    final tasks = await _controller.fetchTaskDeliverDetails();
    print("🔍 DEBUG: Fetched ${tasks.length} tasks");

    final merged = <Map<String, dynamic>>[];

    for (final task in tasks) {
      print("🔍 DEBUG: Processing task ${task['id']}");
      print("🔍 DEBUG: Task keys: ${task.keys.toList()}");
      print("🔍 DEBUG: task_deliver_component: ${task['task_deliver_component']}");

      List<Map<String, dynamic>> comps = [];

      if (task['task_deliver_component'] != null) {
        final taskDeliveryComponents = task['task_deliver_component'] as List? ?? [];
        print("🔍 DEBUG: Found ${taskDeliveryComponents.length} task_deliver_component entries");

        for (final tdc in taskDeliveryComponents) {
          print("🔍 DEBUG: tdc: $tdc");
          final component = tdc['component'];
          if (component != null) {
            print("🔍 DEBUG: Component: $component");
            comps.add({
              'id': component['id'],
              'name': component['name'],
              'workshop': component['workshop'],
              'destination': component['destination'],
              'business_hour': component['business_hour'],
              'qty': component['qty'] ?? component['quantity'] ?? 0,
            });
          }
        }
      }

      if (comps.isEmpty && task['id'] != null) {
        print("🔍 DEBUG: No components in junction table, trying separate fetch for task ${task['id']}");
        comps = await _controller.fetchComponentsByTaskId(task['id']);
        print("🔍 DEBUG: Separate fetch returned ${comps.length} components");
      }

      print("🔍 DEBUG: Final components for task ${task['id']}: ${comps.length}");
      merged.add({'task': task, 'components': comps});
    }

    // If a specific task id is provided, try to pre-select it
    if (mounted) {
      if (widget.initialTaskId != null) {
        final int? wantedId = widget.initialTaskId;
        final int index = merged.indexWhere((e) => (e['task']?['id']) == wantedId);
        if (index != -1) {
          setState(() {
            taskItems = merged;
            selectedTaskId = wantedId;
            selectedTaskData = merged[index]['task'];
            selectedTaskComponents = List<Map<String, dynamic>>.from(merged[index]['components'] ?? []);
            isLoading = false;
          });
          return;
        }
      }

      setState(() {
        taskItems = merged;
        if (merged.isNotEmpty) {
          selectedTaskId = merged.first['task']?['id'];
          selectedTaskData = merged.first['task'];
          selectedTaskComponents = List<Map<String, dynamic>>.from(merged.first['components'] ?? []);
        }
        isLoading = false;
      });
    }
  }

  Future<void> _openGoogleMaps(String address) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Widget _infoRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
          if (isAddress)
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.blue),
              onPressed: () => _openGoogleMaps(value),
            ),
        ],
      ),
    );
  }

  Widget _buildBusinessHourBox(String businessHourText) {
    final List<String> lines = businessHourText
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final RegExp multiSpace = RegExp(r"\s{2,}");
    final RegExp firstDigitSplit = RegExp(r'^(.*?)(\d.*)$');
    final List<Widget> children = [];

    for (final line in lines) {
      String day = line;
      String time = '';

      // Prefer split on 2+ spaces (common for aligned text).
      final parts = line.split(multiSpace);
      if (parts.length >= 2) {
        day = parts.first;
        time = parts.sublist(1).join(' ');
      } else {
        // Better fallback: split at the first digit (start of time like 9:30am)
        final match = firstDigitSplit.firstMatch(line);
        if (match != null) {
          day = (match.group(1) ?? '').trim();
          time = (match.group(2) ?? '').trim();
        } else {
          // Last resort: split by the first colon
          final int colonIdx = line.indexOf(':');
          if (colonIdx > 0) {
            day = line.substring(0, colonIdx).trim();
            time = line.substring(colonIdx).trim();
          }
        }
      }

      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(time)),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSignatureImageRow(String? signature, String? image) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Signature column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'signature',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (signature != null && signature.isNotEmpty && signature != 'NULL')
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(signature),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Invalid signature data'),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('No signature'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Image column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (image != null && image.isNotEmpty && image != 'NULL')
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(image),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Invalid image data'),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('No image'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  // Detail Page UI (Matching the provided image)
  Widget _buildDetailPage() {
    if (selectedTaskData == null) return const SizedBox();
    
    final task = selectedTaskData!;
    final String workshopName = selectedTaskComponents.isNotEmpty 
        ? (selectedTaskComponents.first['workshop'] ?? 'Unknown Workshop') 
        : 'Unknown Workshop';
    
    // Debug: Print component data
    print("🔍 DEBUG: Selected task components: ${selectedTaskComponents.length}");
    for (int i = 0; i < selectedTaskComponents.length; i++) {
      print("🔍 DEBUG: Component $i: ${selectedTaskComponents[i]}");
    }
    
    // Pickup location: Use component's destination (from component table)
    // If no components or no component destination, show a placeholder
    final String pickupLocation = selectedTaskComponents.isNotEmpty 
        ? (selectedTaskComponents.first['destination'] ?? 'Component destination not available')
        : 'No components found';
    
    // Shipping location: Use task's destination (from taskDeliver table)
    final String shippingLocation = task['destination'] ?? 'Task destination not available';
    
    print("🔍 DEBUG: Pickup location: $pickupLocation");
    print("🔍 DEBUG: Shipping location: $shippingLocation");
    
    final String dueDate = task['dueDate'] ?? task['duedate'] ?? '';
    final String time = task['time'] ?? '';
    final String businesshour = selectedTaskComponents.isNotEmpty 
        ? (selectedTaskComponents.first['business_hour'] ?? '')
        : '';

    // Keep date & time unchanged
    final String contact = task['user_id']?.toString() ?? '+012 345 6789';
    final String paymentType = task['paymentType'] ?? 'cash';
    final String paymentStatus = task['paymentStatus'] ?? 'pending';
    final String message = task['messageOfDeliver'] ?? 'none';
    final String? signature = task['signature'];
    final String? image = task['image'];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Pick Up Detail Section
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue Header Bar like list card with Task ID pill (only)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D4CC8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "T${task['id']}",
                          style: const TextStyle(
                            color: Color(0xFF2D4CC8),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Separate blue bar title to match shipping details
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: const Text(
                    'pick up detail',
                    style: TextStyle(
                        color: Color(0xFF2D4CC8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('destination', workshopName),
                      _buildDetailRowWithLocation('location', pickupLocation),
                      _buildDetailRow('date', dueDate),
                      _buildDetailRow('time', time),
                      if (businesshour.isNotEmpty) ...[
                        const Text('business hour', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildBusinessHourBox(businesshour),
                      ],
                      _buildDetailRow('item quantity', 'QTY: ${selectedTaskComponents.fold<int>(0, (sum, c) => sum + (int.tryParse(c['qty']?.toString() ?? '0') ?? 0))}'),
                      
                      const SizedBox(height: 16),
                      const Text(
                        'item details:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      // Item Details Table
                      if (selectedTaskComponents.isNotEmpty) ...[
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                                    Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              // Items
                              ...selectedTaskComponents.map((component) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Colors.grey.shade200),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(component['name'] ?? 'Unknown')),
                                      Text((component['qty']?.toString() ?? '0')),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Text('No components found'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Shipping Details Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shipping Details Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'shipping details',
                        style: TextStyle(
                          color: Color(0xFF2D4CC8),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRowWithLocation('shipping to', shippingLocation),
                      _buildDetailRow('contact', contact),
                      _buildDetailRow('payment type', paymentType),
                      _buildDetailRow('payment status', paymentStatus),
                      _buildDetailRow('message for deliver', message),
                      _buildSignatureImageRow(signature, image),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithLocation(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.blue),
            onPressed: () => _openGoogleMaps(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail page"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person_outline),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDetailPage(),
    );
  }
}
