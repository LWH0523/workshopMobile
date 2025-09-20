import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testapi/controller/SignaturePhotoController.dart';
import 'package:testapi/database/SignaturePhotoDB.dart';
import 'dart:typed_data';

class SignaturePhotoWidget extends StatefulWidget {
  final void Function(Uint8List? signature)? onSignatureSaved;
  final void Function(Uint8List? photo)? onPhotoTaken;
  final VoidCallback? onReject;
  final VoidCallback? onDataChanged; // 新增回调
  final dynamic signatureData; // String 或 Uint8List
  final dynamic imageData;
  final int? userId;
  final int? taskId;
  final String? status;
  final String? reasonOfRejected;

  const SignaturePhotoWidget({
    Key? key,
    this.onSignatureSaved,
    this.onPhotoTaken,
    this.onReject,
    this.signatureData,
    this.imageData,
    this.userId,
    this.taskId,
    this.status,
    this.reasonOfRejected,
    this.onDataChanged,
  }) : super(key: key);

  @override
  State<SignaturePhotoWidget> createState() => _SignaturePhotoWidgetState();
}

class _SignaturePhotoWidgetState extends State<SignaturePhotoWidget> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: const Color.fromARGB(255, 0, 0, 0),
    exportBackgroundColor: Colors.white,
  );

  Uint8List? _signatureData;
  Uint8List? _imageData;
  // bool _isSigned = false;
  // bool _imageTaken = false;
  String? _status;
  String? _reasonOfRejected;

  @override
  void initState() {
    super.initState();

    // 初始化 signature
    if (widget.signatureData != null) {
      try {
        _signatureData = widget.signatureData is Uint8List
            ? widget.signatureData as Uint8List
            : base64Decode(widget.signatureData as String);
      } catch (e) {
        print("❌ Signature decode error: $e");
      }
    }

    // 初始化 image
    if (widget.imageData != null) {
      try {
        _imageData = widget.imageData is Uint8List
            ? widget.imageData as Uint8List
            : base64Decode(widget.imageData as String);
      } catch (e) {
        print("❌ Image decode error: $e");
      }
    }

    // 初始化 status 和 reasonOfRejected
    _status = widget.status;
    _reasonOfRejected = widget.reasonOfRejected;
  }

  Future<void> showRejectDialog(
    BuildContext context,
    Function(String) onRejectConfirmed,
  ) async {
    String reason = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Delivery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter the reason for rejection:'),
              const SizedBox(height: 8),
              TextField(
                autofocus: true,
                maxLines: 2,
                onChanged: (val) => reason = val,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Reason of rejection',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Reject'),
              onPressed: () {
                if (reason.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  onRejectConfirmed(reason.trim());
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a reason.'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _clearSignature() async {
    final confirmed = await _showConfirmDialog(
      context,
      'Clear Signature',
      'Are you sure you want to clear the signature?',
    );
    if (!confirmed) return;
    _signatureController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signature has been cleared successfully.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // DB 更新
    if (widget.userId != null && widget.taskId != null) {
      final signaturePhotoController = Signaturephotocontroller(
        SignaturePhotoDB(),
      );
      final success = await signaturePhotoController.clearConfirmationFields(
        userId: widget.userId!,
        taskId: widget.taskId!,
        clearSignature: true,
      );
      print("Signature field cleared in DB: $success");
    }

    setState(() {
      _signatureData = null;
      _status = 'enroute';
    });

    // 通知父组件刷新数据
    if (widget.onDataChanged != null) {
      widget.onDataChanged!();
    }
  }

  void _saveSignature() async {
    if (_signatureController.isNotEmpty) {
      final signature = await _signatureController.toPngBytes();
      setState(() {
        _signatureData = signature;
      });
      print("Signature saved, length = ${signature?.length}");
      if (widget.onSignatureSaved != null) {
        widget.onSignatureSaved!(signature);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signature is empty. Please sign before saving.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageData = bytes;
      });
      print("📸 New photo taken, length = ${bytes.length}");
      if (widget.onPhotoTaken != null) {
        widget.onPhotoTaken!(bytes);
      }
    } else {
      print("No photo taken");
    }
  }

  void _deleteImage() async {
    final confirmed = await _showConfirmDialog(
      context,
      'Delete Photo',
      'Are you sure you want to delete the photo?',
    );
    if (!confirmed) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo has been deleted successfully.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // DB 更新
    if (widget.userId != null && widget.taskId != null) {
      final signaturePhotoController = Signaturephotocontroller(
        SignaturePhotoDB(),
      );
      final success = await signaturePhotoController.clearConfirmationFields(
        userId: widget.userId!,
        taskId: widget.taskId!,
        clearImage: true,
      );
      print("Image field cleared in DB: $success");
    }

    setState(() {
      _imageData = null;
    });

    // 通知父组件刷新数据
    if (widget.onDataChanged != null) {
      widget.onDataChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🔄 Rebuilding widget...");
    print(
      "👉 _signatureData = ${_signatureData?.length}, _imageData = ${_imageData?.length}",
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Signature 区域
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Signature',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFBFE1FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: (_signatureData != null)
                ? Image.memory(_signatureData!, fit: BoxFit.contain)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: Color(0xFFBFE1FF),
                    ),
                  ),
          ),
        ),

        // 按钮行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: _status == 'rejected' ? null : _clearSignature,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBFE1FF),
                  ),
                  child: Text('Clear', style: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: (_status == 'rejected')
                    ? ElevatedButton(
                        onPressed: () async {
                          final confirmed = await _showConfirmDialog(
                            context,
                            'Undo Rejected',
                            'Reason: ${_reasonOfRejected ?? "(none)"}\nAre you sure you want to undo rejected and mark as delivered?',
                          );
                          if (!confirmed) return;
                          if (widget.userId == null || widget.taskId == null)
                            return;
                          final signaturePhotoController =
                              Signaturephotocontroller(SignaturePhotoDB());
                          final success = await signaturePhotoController
                              .updateConfirmationField(
                                userId: widget.userId!,
                                taskId: widget.taskId!,
                                status: 'delivered',
                                fields: {'reasonOfRejected': ''},
                              );
                          if (success) {
                            setState(() {
                              _status = 'delivered';
                              _reasonOfRejected = null;
                            });
                            if (widget.onReject != null) widget.onReject!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to undo rejected.'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 19, 241, 93),
                        ),
                        child: Text(
                          'Undo Reject',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _status == 'rejected'
                            ? null
                            : () async {
                                if (_imageData == null) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Reject Delivery'),
                                      content: const Text(
                                        'You must provide a photo as evidence to reject.',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Okay'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }

                                await showRejectDialog(context, (reason) async {
                                  if (widget.userId == null ||
                                      widget.taskId == null)
                                    return;

                                  final signaturePhotoController =
                                      Signaturephotocontroller(
                                        SignaturePhotoDB(),
                                      );
                                  final success = await signaturePhotoController
                                      .updateConfirmationField(
                                        userId: widget.userId!,
                                        taskId: widget.taskId!,
                                        status: 'rejected',
                                        fields: {
                                          'reasonOfRejected': reason,
                                          'image': base64Encode(_imageData!),
                                        },
                                      );

                                  if (success) {
                                    setState(() {
                                      _status = 'rejected';
                                      _reasonOfRejected = reason;
                                    });
                                    if (widget.onReject != null)
                                      widget.onReject!();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to reject.'),
                                      ),
                                    );
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF4444),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: ElevatedButton(
                  onPressed: (_status == 'rejected' || _signatureData != null) ? null : _saveSignature,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBFE1FF),
                  ),
                  child: Text('Save', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // 图片区域
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: (_imageData != null)
              ? Row(
                  children: [
                    Container(
                      width: 225,
                      height: 175,
                      decoration: BoxDecoration(
                        color: _status == 'rejected'
                            ? Colors.grey
                            : Color(0xFFBFE1FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.memory(_imageData!, fit: BoxFit.cover),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: _status == 'rejected'
                            ? Colors.grey
                            : Color(0xFFFF4444),
                        size: 32,
                      ),
                      onPressed: _status == 'rejected' ? null : _deleteImage,
                    ),
                  ],
                )
              : Center(
                  child: GestureDetector(
                    onTap: _status == 'rejected' ? null : _pickImage,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xFFBFE1FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Color(0xFF244EB9),
                        size: 48,
                      ),
                    ),
                  ),
                ),
        ),

        SizedBox(height: 32),
      ],
    );
  }
}
