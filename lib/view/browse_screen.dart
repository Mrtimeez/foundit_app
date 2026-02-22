import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ตัวเลือกรูปจากเครื่อง
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // ตัวจัดการผู้ใช้
import 'package:cloud_firestore/cloud_firestore.dart'; // ฐานข้อมูลเก็บโพส
import 'package:http/http.dart' as http; // ตัวส่งข้อมูลขึ้นเน็ต

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  // [1] ตัวเก็บข้อความที่พิมพ์ในช่องต่างๆ
  final titleCtrl = TextEditingController(); // ชื่อของที่พบ
  final detailCtrl = TextEditingController(); // รายละเอียด
  final locationCtrl = TextEditingController(); // สถานที่พบ
  final phoneCtrl = TextEditingController(); // เบอร์โทร
  final lineCtrl = TextEditingController(); // ไอดีไลน์/เฟซบุ๊ก

  // [2] ตัวแปรควบคุมสถานะ
  bool _isSaving = false; // เอาไว้เช็คว่า "กำลังหมุนโหลด" หรือเปล่าตอนกดเซฟ
  File? _image; // เอาไว้เก็บไฟล์รูปที่เลือกมาจากมือถือ
  final ImagePicker _picker = ImagePicker(); // ตัวช่วยเปิดกล้อง/อัลบั้ม

  // --------------------------------------------------------------------------
  // [3] ฟังก์ชัน "ส่งรูป" ไปฝากไว้ที่เว็บ Cloudinary
  // --------------------------------------------------------------------------
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/das1fev8e/image/upload",
      );
      final request = http.MultipartRequest('POST', uri);

      // ตัวบอก Cloudinary ว่าจะเก็บไว้ที่ไหน (ต้องตั้งค่าในเว็บ Cloudinary ก่อน)
      request.fields['upload_preset'] = 'profile_images';
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return jsonData['secure_url']; // ส่ง "ที่อยู่รูปบนเว็บ" กลับไปเพื่อเอาไปลงฐานข้อมูล
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // [4] ฟังก์ชัน "บันทึกโพส" ลงฐานข้อมูล Firebase
  // --------------------------------------------------------------------------
  Future<void> _savePost() async {
    // เช็คก่อนว่าพิมพ์ชื่อของกับที่พบหรือยัง ถ้ายังไม่ให้เซฟ
    if (titleCtrl.text.trim().isEmpty || locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกชื่อสิ่งของและสถานที่พบ"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true); // เริ่มหมุนโหลด

    try {
      final String? uid =
          FirebaseAuth.instance.currentUser?.uid; // ใครเป็นคนโพส?
      if (uid == null) throw Exception("กรุณาเข้าสู่ระบบก่อน");

      // ถ้ามีรูป ให้ส่งรูปไปเก็บก่อน แล้วเอา Link รูปกลับมา
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageToCloudinary(_image!);
      }

      // เอาข้อมูลทุกอย่างไปโยนลงฐานข้อมูล Firebase
      await FirebaseFirestore.instance.collection('posts').add({
        'uid': uid,
        'title': titleCtrl.text.trim(),
        'desc': detailCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'lineId': lineCtrl.text.trim(),
        'imageUrl': imageUrl, // ลิงก์รูปที่ได้จาก Cloudinary
        'type': 'found', // บอกว่าเป็นโพส "พบของ"
        'status': 'กำลังตามหาเจ้าของ',
        'createdAt': FieldValue.serverTimestamp(), // เวลาที่บันทึก
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("บันทึกข้อมูลสำเร็จ"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // บันทึกเสร็จแล้วปิดหน้านี้ไป
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false); // หยุดหมุนโหลด
    }
  }

  // --------------------------------------------------------------------------
  // [5] ฟังก์ชัน "เลือกรูป" จากกล้องหรืออัลบั้ม
  // --------------------------------------------------------------------------
  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(
        () => _image = File(picked.path),
      ); // เก็บรูปไว้ในเครื่องชั่วคราวเพื่อรอส่ง
    }
  }

  // แสดงเมนูเด้งขึ้นมาให้เลือกว่าจะ "ถ่ายรูป" หรือ "เลือกรูป"
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
    // ล้างตัวควบคุมทิ้งเมื่อปิดหน้าจอเพื่อประหยัดแรม
    titleCtrl.dispose();
    detailCtrl.dispose();
    locationCtrl.dispose();
    phoneCtrl.dispose();
    lineCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // [6] ส่วนการออกแบบหน้าจอ (UI)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // สีพื้นหลังฟ้าอ่อนๆ
      appBar: AppBar(
        title: const Text(
          "แจ้งของที่พบ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

            _sectionTitle("ช่องทางการติดต่อ"),
            _card(
              child: Column(
                children: [
                  _field("เบอร์โทร", phoneCtrl),
                  _field("Line or FB ID", lineCtrl),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle("รูปภาพ"),
            // ส่วนที่โชว์รูปที่เลือก ถ้าไม่มีรูปจะขึ้นว่า "แตะเพื่อแนบรูป"
            GestureDetector(
              onTap: _showImagePicker,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _image == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.blue,
                            ),
                            Text("แตะเพื่อแนบรูป"),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 30),

            // ปุ่มบันทึกข้อมูล
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePost,
                // ถ้ากำลังหมุนโหลดอยู่ จะกดซ้ำไม่ได้
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "บันทึกข้อมูล",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget ย่อยๆ สำหรับช่วยวาดหน้าจอให้โค้ดดูสะอาดขึ้น ---
  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );

  Widget _field(String label, TextEditingController ctrl, {int maxLine = 1}) =>
      Padding(
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

  Widget _pickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) => ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: Text(text),
    onTap: onTap,
  );
}
