import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controller/ListPageScheduleController.dart';
import '../controller/user_controller.dart';
import '../database/ListPageScheduleDB.dart';
import '../widgets/app_bottom_nav.dart';
import 'Profile.dart';
import 'update.dart';
import 'MapLauncherExample.dart';

class ListPageSchedule extends StatefulWidget {
  final int? userId;
  const ListPageSchedule({super.key, this.userId});

  @override
  State<ListPageSchedule> createState() => _ListPageScheduleState();
}

class _ListPageScheduleState extends State<ListPageSchedule> {
  final ListPageScheduleController _controller =
  ListPageScheduleController(ListPageScheduleService());
  final UserController _userController = UserController();

  bool _isTodaySelected = false;
  String _userName = 'Kitty'; // Default name
  int _bottomIndex = 0;
  int _refreshKey = 0; // Used to trigger FutureBuilder refresh

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Refresh task list
  Future<void> _refreshTasks() async {
    setState(() {
      _refreshKey++; // Increase key value to trigger FutureBuilder rebuild
    });
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
        title: Text(_userName, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              if (widget.userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      userId: widget.userId!, // Pass correct userId
                      userName: _userName,    // Pass correct userName
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User ID does not exist, cannot open Profile")),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isTodaySelected = false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isTodaySelected
                            ? const Color(0xFFE9EFFD)
                            : const Color(0xFF2D4CC8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Text(
                        'Schedule',
                        style: TextStyle(
                          color: _isTodaySelected
                              ? const Color(0xFF2D4CC8)
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isTodaySelected = true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isTodaySelected
                            ? const Color(0xFF2D4CC8)
                            : const Color(0xFFE9EFFD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color: _isTodaySelected
                              ? Colors.white
                              : const Color(0xFF2D4CC8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Summary pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FutureBuilder<int>(
              future: _isTodaySelected
                  ? _controller.getTodayPendingDeliveriesCount(userId: widget.userId)
                  : _controller.getPendingDeliveriesCount(userId: widget.userId),
              builder: (context, snapshot) {
                final int count = snapshot.data ?? 0;
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
                        TextSpan(
                          text: _isTodaySelected ? 'Today' : 'Future',
                          style: const TextStyle(
                            color: Color(0xFF2D4CC8),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
              key: ValueKey(_refreshKey), // Use refreshKey to trigger rebuild
              future: _isTodaySelected
                  ? _controller.fetchTodayTaskDeliverDetails(userId: widget.userId)
                  : _controller.fetchTaskDeliverDetails(userId: widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return Center(
                      child: Text(_isTodaySelected
                          ? 'No deliveries today'
                          : 'No deliveries'));
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
                      key: PageStorageKey('task_${task['id']}'),
                      id: task['id'] as int,
                      userId: task['user_id'] as int,
                      workshop: task['workshop'] ?? '',
                      destination: task['destination'] ?? '',
                      dateTime: _formatDateTime(
                        task['duedate'] as String?,
                        task['time'] as String?,
                      ),
                      component: task['component_name'] ?? '',
                      componentNames: (task['component_names'] as List?)?.cast<String>() ?? const <String>[],
                      status: displayStatus,
                      statusColor: statusColor,
                      isTodaySelected: _isTodaySelected,
                      onRefresh: _refreshTasks, // Pass callback
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
        bottomNavigationBar: AppBottomNav(
          selectedIndex: _bottomIndex,
          onTap: (index) {
            setState(() {
              _bottomIndex = index;
            });
            if (index == 0) {
              // 列表页，当前页面无需跳转
            } else if (index == 1) {
              if (widget.userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      userId: widget.userId!,
                      userName: _userName,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User ID does not exist, cannot open Profile")),
                );
              }
            }
          },
        ),
    );
  }
}

class _ScheduleCard extends StatefulWidget {
  final int id;
  final int userId;
  final String workshop;
  final String destination;
  final String dateTime;
  final String component;
  final List<String> componentNames;
  final String status;
  final Color statusColor;
  final bool isTodaySelected;
  final VoidCallback onRefresh;

  const _ScheduleCard({
    super.key,
    required this.id,
    required this.userId,
    required this.workshop,
    required this.destination,
    required this.dateTime,
    required this.component,
    required this.componentNames,
    required this.status,
    required this.statusColor,
    required this.isTodaySelected,
    required this.onRefresh,
  });

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard> {
  bool _componentsExpanded = false;

  @override
  void initState() {
    super.initState();
  final stored = PageStorage.of(context)
    .readState(context, identifier: 'componentsExpanded');
    if (stored is bool) {
      _componentsExpanded = stored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _allNames = (widget.componentNames.isEmpty)
        ? (widget.component.isEmpty ? <String>[] : <String>[widget.component])
        : widget.componentNames;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E8EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2D4CC8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  // Updated onTap condition
                  onTap: (widget.isTodaySelected || widget.status != 'Rejected')
                      ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SetRoutePage(
                          userId: widget.userId,
                          taskId: widget.id,
                        ),
                      ),
                    );
                    if (result == true) {
                      widget.onRefresh(); // Call parent refresh
                    }
                  }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.status == 'Rejected'
                          ? const Color(0xFFF44336)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "T${widget.id}",
                      style: TextStyle(
                        color: widget.status == 'Rejected'
                            ? Colors.white
                            : const Color(0xFF2D4CC8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.status,
                    style: TextStyle(
                      color: (widget.statusColor == const Color(0xFF4CAF50) ||
                          widget.statusColor == const Color(0xFFF44336))
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MapLauncherExample(initialTaskId: widget.id),
                      ),
                    );
                  },
                  child: const Icon(Icons.more_horiz, color: Colors.white),
                ),
              ],
            ),
          ),

          // 🔵 Content area
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.workshop,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(child: Text(widget.destination)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(widget.dateTime),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.build_outlined,
                        size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child:
                      Text(_allNames.isNotEmpty ? _allNames.first : ''),
                    ),
                    IconButton(
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _componentsExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _componentsExpanded = !_componentsExpanded;
                        });
                        PageStorage.of(context).writeState(
                          context,
                          _componentsExpanded,
                          identifier: 'componentsExpanded',
                        );
                      },
                    ),
                  ],
                ),
                if (_componentsExpanded && _allNames.length > 1) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 1; i < _allNames.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(i == 3 ? '...' : _allNames[i]),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
