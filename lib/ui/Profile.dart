import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/user_controller.dart';
import '../widgets/app_bottom_nav.dart';
import 'ListPageSchedule.dart';
import 'history.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final int userId;

  const ProfilePage({super.key, required this.userName, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _bottomIndex = 1;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  /// Load avatar from database
  Future<void> _loadUserAvatar() async {
    final avatarUrl =
    await UserController().getUserAvatar(widget.userId); // From controller
    setState(() {
      _imageUrl = avatarUrl;
    });
  }

  /// Pick image and upload
  Future<void> _pickAndUploadImage() async {
    debugPrint("📷 Avatar tapped");
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      try {
        final newImageUrl =
        await UserController().updateProfilePicture(widget.userId, file);

        setState(() {
          _imageUrl = newImageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Avatar updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        ),
        title: const SizedBox.shrink(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _Avatar(
            name: widget.userName,
            imageUrl: _imageUrl, //  Display from DB or after upload
            onTap: _pickAndUploadImage,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              widget.userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              "User ID: ${widget.userId}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _ListTile(
            icon: Icons.history,
            label: 'History',
            onTap: () {
              debugPrint('Go to history for userId: ${widget.userId}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(
                    userId: widget.userId,
                    taskId: 0,
                  ),
                ),
              );
            },
          ),

          const Spacer(),
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
            // Current page, no navigation needed
          }
        },
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  const _Avatar({required this.name, this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 48,
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : const NetworkImage(
                  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop'),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.photo_camera_outlined,
                    size: 18, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ListTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2D4CC8)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
