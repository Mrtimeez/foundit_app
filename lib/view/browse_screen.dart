import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final titleCtrl = TextEditingController();
  final detailCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  //ช่องทางติดต่อ
  final phoneCtrl = TextEditingController();
  final lineCtrl = TextEditingController();

  // -------------- ตัวบันทึกข้อมูลลง DB -----------------------------------
  // ตัวแปรควบคุมสถานะ Loading ตอนบันทึก
  bool _isSaving = false;

  // ฟังก์ชัน Upload รูปขึ้น Cloudinary แล้วคืน URL กลับมา
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      // สร้าง URL Endpoint ของ Cloudinary
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/das1fev8e/image/upload",
      );

      // สร้าง Multipart Request สำหรับส่งไฟล์
      final request = http.MultipartRequest('POST', uri);

      // ใส่ Upload Preset ที่สร้างไว้ใน Cloudinary Dashboard
      request.fields['upload_preset'] = 'profile_images';

      // แนบไฟล์รูปภาพ
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // ส่ง Request และรอ Response
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        // คืน URL รูปที่ Upload สำเร็จ
        return jsonData['secure_url'];
      } else {
        print("Upload ล้มเหลว: $responseBody");
        return null;
      }
    } catch (e) {
      print("Cloudinary Error: $e");
      return null;
    }
  }

  // ฟังก์ชันบันทึกข้อมูลลง Firestore
  Future<void> _savePost() async {
    // เช็คว่ากรอกข้อมูลสำคัญครบหรือยัง
    if (titleCtrl.text.trim().isEmpty || locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกชื่อสิ่งของและสถานที่พบ"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true); // แสดง Loading

    try {
      // ดึง UID ของ User ที่ Login อยู่
      final String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        throw Exception("ไม่พบข้อมูลผู้ใช้ กรุณา Login ใหม่");
      }

      // ถ้ามีรูป → Upload ขึ้น Cloudinary ก่อน แล้วรับ URL กลับมา
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageToCloudinary(_image!);
      }

      // บันทึกข้อมูลลง Firestore ใน collection 'posts'
      await FirebaseFirestore.instance.collection('posts').add({
        'uid': uid, // UID ของคนที่โพส
        'title': titleCtrl.text.trim(), // ชื่อสิ่งของ
        'desc': detailCtrl.text.trim(), // รายละเอียด
        'location': locationCtrl.text.trim(), // สถานที่พบ
        'phone': phoneCtrl.text.trim(), // เบอร์โทร
        'lineId': lineCtrl.text.trim(), // Line ID
        'imageUrl': imageUrl, // URL รูปจาก Cloudinary (null ถ้าไม่มีรูป)
        'type': 'found', // ประเภทโพส (found = พบของ)
        'status': 'กำลังตามหาเจ้าของ', // สถานะเริ่มต้น
        'createdAt': FieldValue.serverTimestamp(), // เวลาที่โพส
      });

      // บันทึกสำเร็จ → แจ้งแล้วกลับหน้าก่อนหน้า
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("บันทึกข้อมูลสำเร็จ"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // แจ้ง Error ถ้าเกิดปัญหา
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // ปิด Loading ไม่ว่าจะสำเร็จหรือไม่
      if (mounted) setState(() => _isSaving = false);
    }
  }

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pickerTile(
              icon: Icons.camera_alt,
              text: "ถ่ายรูปจากกล้อง",
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            _pickerTile(
              icon: Icons.photo_library,
              text: "เลือกรูปจากอัลบั้ม",
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    detailCtrl.dispose();
    locationCtrl.dispose();
    phoneCtrl.dispose();
    lineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        title: const Text(
          "แจ้งของที่พบ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
        foregroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("ข้อมูลสิ่งของ"),
            _card(
              child: Column(
                children: [
                  _field("ชื่อสิ่งของ", titleCtrl),
                  _field("รายละเอียด", detailCtrl, maxLine: 3),
                  _field("สถานที่พบ", locationCtrl),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //กล่องช่องทางติดต่อ
            _sectionTitle("ช่องทางการติดต่อ"),
            _card(
              child: Column(
                children: [
                  _field("เบอร์โทร", phoneCtrl),
                  _field("Line ID", lineCtrl),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("รูปภาพ"),
            GestureDetector(
              onTap: _showImagePicker,
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: Color(0xFF2196F3),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "แตะเพื่อแนบรูป",
                                style: TextStyle(
                                  color: Color(0xFF2196F3),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),
                  if (_image != null)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF2196F3),
                          ),
                          onPressed: _showImagePicker,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.zero,
                ),
                // เรียก _savePost() แทนของเดิม
                // ปิดปุ่มถ้ากำลังบันทึกอยู่ ป้องกันกดซ้ำ
                onPressed: _isSaving ? null : _savePost,
                child: Ink(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Center(
                    // เปลี่ยนข้อความตามสถานะ
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "บันทึกข้อมูล",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLine = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLine,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF6FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE3F2FD),
        child: Icon(icon, color: const Color(0xFF2196F3)),
      ),
      title: Text(text),
      onTap: onTap,
    );
  }
}
