import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ==================== Cloudinary Config ====================
// เก็บค่า Config ของ Cloudinary ไว้ที่นี่
class CloudinaryConfig {
  static const String cloudName = "das1fev8e";
  static const String uploadPreset = "profile_images";
}
// ===========================================================

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ไฟล์รูปภาพที่เลือกจาก Gallery (ยังไม่ได้ Upload)
  File? _image;

  // instance ของ ImagePicker สำหรับเปิด Gallery
  final picker = ImagePicker();

  // Controllers สำหรับรับค่าจาก TextField ต่างๆ
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController(); // แสดงเฉยๆ ไม่ให้แก้ไข

  // Controllers สำหรับส่วนเปลี่ยนรหัสผ่าน (ใช้เฉพาะ Email User)
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();

  // ดึงข้อมูล User ที่ Login อยู่ปัจจุบัน
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // ตัวแปรควบคุมสถานะ Loading ทั่วไป (ตอนบันทึก)
  bool _isLoading = false;
  // ตัวแปรควบคุมสถานะ Loading ตอน Upload รูป
  bool _isUploading = false;
  // เก็บ URL รูปโปรไฟล์ปัจจุบันที่โหลดมาจาก Firestore
  String? _currentPhotoUrl;
  // ตัวแปรเก็บว่า User คนนี้ Login ด้วย Google หรือเปล่า
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();

    // เช็คว่า User Login ด้วย Google หรือเปล่า โดยดูจาก providerData
    _isGoogleUser = currentUser?.providerData
        .any((info) => info.providerId == 'google.com') ??
        false;

    // โหลดข้อมูลปัจจุบันมาใส่ใน TextField
    _loadUserData();
  }

  @override
  void dispose() {
    // คืน memory เมื่อออกจากหน้านี้
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  // ฟังก์ชันดึงข้อมูล User จาก Firebase Auth และ Firestore มาแสดงใน TextField
  Future<void> _loadUserData() async {
    if (currentUser == null) return; // ถ้าไม่มี User ให้หยุดทันที

    // ดึง Email จาก Firebase Auth มาแสดง
    _emailController.text = currentUser!.email ?? "";

    try {
      // ดึงข้อมูลเพิ่มเติม (username, phone, photoURL) จาก Firestore
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      // ถ้ามีข้อมูลใน Firestore ให้นำมาใส่ใน TextField
      if (userDoc.exists) {
        final Map<String, dynamic> data =
        userDoc.data() as Map<String, dynamic>;

        // อัปเดต UI ด้วย setState
        setState(() {
          _usernameController.text = data['username'] ?? "";
          _phoneController.text = data['phone_number'] ?? "";
          _currentPhotoUrl = data['photoURL']; // เก็บ URL รูปโปรไฟล์ปัจจุบัน
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  // ฟังก์ชันเปิด Gallery เพื่อเลือกรูปโปรไฟล์
  Future<void> _pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // บีบอัดรูปเหลือ 70% เพื่อลดขนาดไฟล์ก่อน Upload
      maxWidth: 512,    // จำกัดความกว้างสูงสุด 512px เพื่อลดขนาดไฟล์
      maxHeight: 512,   // จำกัดความสูงสูงสุด 512px เพื่อลดขนาดไฟล์
    );

    // ถ้าเลือกรูปได้ ให้ setState เพื่ออัปเดต UI แล้ว Upload ทันที
    if (picked != null) {
      setState(() {
        _image = File(picked.path); // เก็บไฟล์รูปที่เลือกเพื่อแสดง Preview
      });

      // Upload รูปขึ้น Cloudinary ทันทีหลังเลือก
      await _uploadImageToCloudinary(_image!);
    }
  }

  // ฟังก์ชัน Upload รูปขึ้น Cloudinary แล้วบันทึก URL ลง Firestore
  Future<void> _uploadImageToCloudinary(File imageFile) async {
    setState(() => _isUploading = true); // แสดงสถานะกำลัง Upload

    try {
      // สร้าง URL Endpoint สำหรับ Upload ของ Cloudinary
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload",
      );

      // สร้าง Multipart Request สำหรับส่งไฟล์ (HTTP POST แบบ form-data)
      final request = http.MultipartRequest('POST', uri);

      // ใส่ Upload Preset ที่สร้างไว้ใน Cloudinary Dashboard
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;

      // ตั้งชื่อไฟล์ตาม UID ของ User เพื่อให้ทับไฟล์เก่าได้เลย
      // ถ้าอัปโหลดรูปใหม่จะ replace รูปเก่าอัตโนมัติ ไม่เปลืองพื้นที่
      request.fields['public_id'] = currentUser!.uid;

      // แนบไฟล์รูปภาพเข้าไปใน Request
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // ส่ง Request ไปยัง Cloudinary แล้วรอ Response
      final response = await request.send();

      // อ่าน Response Body ที่ได้กลับมาเป็น String
      final responseBody = await response.stream.bytesToString();

      // แปลง JSON String เป็น Map เพื่อดึงข้อมูล
      final jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        // Upload สำเร็จ → ดึง URL รูปจาก Response (https ปลอดภัยกว่า http)
        final String photoUrl = jsonData['secure_url'];

        // บันทึก URL ลง Firestore ใน field 'photoURL'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          'photoURL': photoUrl,                          // URL รูปโปรไฟล์ใหม่
          'updated_at': FieldValue.serverTimestamp(),   // เวลาที่แก้ไขล่าสุด
        });

        // อัปเดต URL ในหน้านี้ด้วยเพื่อให้แสดงรูปใหม่จาก Cloudinary
        setState(() {
          _currentPhotoUrl = photoUrl;
        });

        print("Upload สำเร็จ! URL: $photoUrl");

        // แจ้งว่า Upload สำเร็จ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("อัปโหลดรูปโปรไฟล์สำเร็จ"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Upload ล้มเหลว → โยน Exception พร้อม Error Message จาก Cloudinary
        print("Upload ล้มเหลว: $responseBody");
        throw Exception("Upload failed: ${jsonData['error']['message']}");
      }
    } catch (e) {
      print("Cloudinary Upload Error: $e");

      // แจ้ง Error ให้ผู้ใช้ทราบ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("อัปโหลดรูปไม่สำเร็จ: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // ปิดสถานะ Uploading ไม่ว่าจะสำเร็จหรือไม่
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ฟังก์ชันหลักสำหรับบันทึกการเปลี่ยนแปลง
  // จะแยก Logic ตาม Provider ที่ใช้ Login
  Future<void> _updateProfile() async {
    if (_isGoogleUser) {
      // Google User → Re-authenticate ด้วย Google แทน Password
      await _updateProfileForGoogleUser();
    } else {
      // Email/Password User → ต้องกรอก Password เดิมยืนยัน
      await _updateProfileForEmailUser();
    }
  }

  // ฟังก์ชันอัปเดตข้อมูลสำหรับ Google User
  Future<void> _updateProfileForGoogleUser() async {
    setState(() => _isLoading = true); // แสดง Loading

    try {
      // สร้าง instance ของ GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Sign out ก่อน เพื่อให้ Google แสดง account picker ทุกครั้ง
      await googleSignIn.signOut();

      // เปิดหน้าต่างให้ผู้ใช้เลือก Google Account เพื่อยืนยันตัวตน
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // ถ้าผู้ใช้กดยกเลิก ให้หยุดทำงาน
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // ดึง Token จาก Google Account ที่เลือก
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // สร้าง Firebase Credential จาก Token ที่ได้จาก Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // Token สำหรับเข้าถึง Google API
        idToken: googleAuth.idToken,         // Token สำหรับยืนยันตัวตน
      );

      // Re-authenticate เข้า Firebase ด้วย Google Credential
      await currentUser!.reauthenticateWithCredential(credential);

      // อัปเดตข้อมูล username และ phone_number ลง Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'username': _usernameController.text.trim(),   // ชื่อผู้ใช้ใหม่
        'phone_number': _phoneController.text.trim(),  // เบอร์โทรใหม่
        'updated_at': FieldValue.serverTimestamp(),    // เวลาที่แก้ไขล่าสุด
      });

      // แจ้งว่าบันทึกสำเร็จ แล้วปิดหน้านี้
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("บันทึกข้อมูลสำเร็จ"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // กลับไปหน้าก่อนหน้า
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
      // ปิด Loading ไม่ว่าจะสำเร็จหรือไม่
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ฟังก์ชันอัปเดตข้อมูลสำหรับ Email/Password User
  Future<void> _updateProfileForEmailUser() async {
    // ตรวจสอบว่ากรอก Password เดิมมาหรือยัง
    if (_oldPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกรหัสผ่านปัจจุบันเพื่อยืนยันการแก้ไข"),
          backgroundColor: Colors.orange,
        ),
      );
      return; // หยุดทำงานถ้าไม่ได้กรอก Password
    }

    setState(() => _isLoading = true); // แสดง Loading

    try {
      // สร้าง Credential จาก Email และ Password เดิมที่กรอกมา
      final AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: _oldPassController.text.trim(),
      );

      // Re-authenticate เพื่อยืนยันตัวตนก่อนแก้ไขข้อมูล
      await currentUser!.reauthenticateWithCredential(credential);

      // อัปเดตข้อมูล username และ phone_number ลง Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'username': _usernameController.text.trim(),   // ชื่อผู้ใช้ใหม่
        'phone_number': _phoneController.text.trim(),  // เบอร์โทรใหม่
        'updated_at': FieldValue.serverTimestamp(),    // เวลาที่แก้ไขล่าสุด
      });

      // ถ้ากรอก Password ใหม่มาด้วย ให้เปลี่ยน Password Login ด้วย
      if (_newPassController.text.isNotEmpty) {
        await currentUser!.updatePassword(_newPassController.text.trim());
      }

      // แจ้งว่าบันทึกสำเร็จ แล้วปิดหน้านี้
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("บันทึกข้อมูลสำเร็จ"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // กลับไปหน้าก่อนหน้า
      }
    } on FirebaseAuthException catch (e) {
      // จัดการ Error จาก Firebase Auth
      String message = "เกิดข้อผิดพลาด";

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = "รหัสผ่านปัจจุบันไม่ถูกต้อง"; // Password เดิมผิด
      } else if (e.code == 'weak-password') {
        message = "รหัสผ่านใหม่ต้องมีความยาวอย่างน้อย 6 ตัวอักษร";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // ปิด Loading ไม่ว่าจะสำเร็จหรือไม่
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Widget สำหรับแสดงรูปโปรไฟล์
  // แสดงรูปตามลำดับ: รูปที่เพิ่งเลือก → URL จาก Cloudinary → ไอคอน default
  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickImage, // ถ้ากำลัง Upload ให้กดไม่ได้
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.grey.shade200, // พื้นหลังสีเทาอ่อน
            // เลือก Image Provider ตามสถานะที่มีข้อมูล
            backgroundImage: _image != null
                ? FileImage(_image!)                        // รูปที่เพิ่งเลือกจาก Gallery (Preview)
                : (_currentPhotoUrl != null
                ? NetworkImage(_currentPhotoUrl!)       // รูปจาก Cloudinary URL
                : null) as ImageProvider?,
            // ถ้ายังไม่มีรูปให้แสดงไอคอน person
            child: (_image == null && _currentPhotoUrl == null)
                ? const Icon(Icons.person, size: 55, color: Colors.grey)
                : null,
          ),

          // แสดง Loading Indicator ทับรูป ตอนกำลัง Upload
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45, // พื้นหลังโปร่งแสงสีดำ
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white, // Loading สีขาว
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),

          // ไอคอนกล้องมุมล่างขวา (ซ่อนตอนกำลัง Upload)
          if (!_isUploading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3), // วงกลมสีฟ้า
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // พื้นหลังสีฟ้าอ่อน
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3), // AppBar สีฟ้า
        title: const Text(
          "แก้ไขข้อมูลส่วนตัว",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // ไอคอน Back สีขาว
      ),

      // ถ้ากำลัง Loading (บันทึก) ให้แสดง CircularProgressIndicator แทน
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------- ส่วนรูปโปรไฟล์ ----------
            Center(child: _buildProfileImage()),
            const SizedBox(height: 8),

            // Badge แสดง Provider ที่ใช้ Login
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _isGoogleUser
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isGoogleUser
                        ? Colors.red.shade200
                        : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isGoogleUser
                          ? Icons.g_mobiledata
                          : Icons.email_outlined,
                      size: 16,
                      color: _isGoogleUser ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isGoogleUser
                          ? "เข้าสู่ระบบด้วย Google"
                          : "เข้าสู่ระบบด้วย Email",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                        _isGoogleUser ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---------- ส่วนข้อมูลทั่วไป ----------
            const _SectionLabel(text: "ข้อมูลทั่วไป"),
            const SizedBox(height: 12),

            // อีเมล (Read Only ไม่ให้แก้ไข)
            _buildInput(
              label: "อีเมล",
              controller: _emailController,
              readOnly: true,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),

            // ชื่อผู้ใช้ (แก้ไขได้)
            _buildInput(
              label: "ชื่อผู้ใช้",
              controller: _usernameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // เบอร์โทรศัพท์ (แก้ไขได้)
            _buildInput(
              label: "เบอร์โทรศัพท์",
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // ---------- ส่วนรหัสผ่าน (ซ่อนถ้าเป็น Google User) ----------
            if (!_isGoogleUser) ...[
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 24),
              const _SectionLabel(
                  text: "ยืนยันการแก้ไข / เปลี่ยนรหัสผ่าน"),
              const SizedBox(height: 4),
              const Text(
                "กรุณากรอกรหัสผ่านปัจจุบันเพื่อยืนยันตัวตนก่อนบันทึก",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // รหัสผ่านปัจจุบัน (จำเป็นต้องกรอก)
              _buildInput(
                label: "รหัสผ่านปัจจุบัน (จำเป็น)",
                controller: _oldPassController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // รหัสผ่านใหม่ (ไม่บังคับ)
              _buildInput(
                label: "รหัสผ่านใหม่ (เว้นว่างถ้าไม่เปลี่ยน)",
                controller: _newPassController,
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
              ),
              const SizedBox(height: 24),
            ],

            // ---------- ปุ่มบันทึก ----------
            // แจ้งเตือน Google User ว่าจะต้องยืนยันผ่าน Google
            if (_isGoogleUser)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "การบันทึกจะขอให้ยืนยันตัวตนผ่าน Google อีกครั้ง",
                        style: TextStyle(
                            fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),

            // ปุ่มบันทึก ปิดถ้ากำลัง Upload รูปอยู่
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // ปิดปุ่มถ้ากำลัง Upload รูป ป้องกันกดซ้ำ
                onPressed: _isUploading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  // เปลี่ยนข้อความปุ่มตามสถานะ
                  _isUploading
                      ? "กำลังอัปโหลดรูป..."
                      : "บันทึกการเปลี่ยนแปลง",
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 24), // ระยะห่างด้านล่างสุด
          ],
        ),
      ),
    );
  }

  // Widget สร้าง TextField สำหรับใช้ซ้ำทั่วหน้า
  Widget _buildInput({
    required String label,                                    // ชื่อ Label
    required TextEditingController controller,                // Controller
    required IconData prefixIcon,                             // ไอคอนด้านหน้า
    bool obscureText = false,                                 // ซ่อนตัวอักษร (Password)
    bool readOnly = false,                                    // ไม่ให้แก้ไข (Email)
    TextInputType keyboardType = TextInputType.text,          // ประเภท Keyboard
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefixIcon,
          // ถ้า readOnly ให้ไอคอนสีเทา ถ้าแก้ไขได้ให้สีฟ้า
          color: readOnly ? Colors.grey : const Color(0xFF2196F3),
        ),
        filled: true,
        // ถ้า readOnly พื้นหลังสีเทา ถ้าแก้ไขได้พื้นหลังสีขาว
        fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            // ถ้า readOnly เส้นขอบไม่เปลี่ยนสี ถ้าแก้ไขได้เปลี่ยนเป็นสีฟ้า
            color: readOnly
                ? Colors.grey.shade300
                : const Color(0xFF2196F3),
            width: 2,
          ),
        ),
      ),
    );
  }
}

// Widget สำหรับ Section Label (หัวข้อแต่ละส่วน)
class _SectionLabel extends StatelessWidget {
  final String text; // ข้อความ Label

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }
}