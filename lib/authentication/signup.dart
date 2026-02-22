import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // สำหรับระบบลงทะเบียน
import 'package:cloud_firestore/cloud_firestore.dart'; // สำหรับเก็บข้อมูลลงฐานข้อมูล
import 'warpper.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // [1] ประกาศตัวควบคุม (Controllers) เพื่อรับค่าจากช่องกรอกข้อมูล
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // คืนค่าหน่วยความจำเมื่อไม่ใช้งานหน้านี้แล้ว
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // [2] ฟังก์ชันสมัครสมาชิก (Logic หลัก)
  // --------------------------------------------------------------------------
  Future<void> signUp() async {
    // 1. ตรวจสอบว่ากรอกข้อมูลครบหรือไม่ (เบื้องต้น)
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showErrorMessage("กรุณากรอกข้อมูลให้ครบถ้วน");
      return;
    }

    // 2. แสดงวงกลมโหลด (Loading)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 3. สร้างบัญชีใหม่ใน Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 4. ถ้าสร้างบัญชีสำเร็จ ให้เก็บข้อมูลส่วนตัวอื่นๆ ลง Cloud Firestore
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid; // ใช้ UID จาก Auth มาเป็น ID ของเอกสาร

        await addUserDetails(
          uid,
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
        );
      }

      // 5. ปิด Loading
      if (mounted) Navigator.pop(context);

      // 6. สมัครเสร็จแล้ว ส่งไปหน้า Wrapper เพื่อเช็คสถานะและเข้าหน้า Home ต่อไป
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Wrapper()), // ตรวจสอบชื่อ Class ในไฟล์ warpper.dart
              (route) => false, // ล้าง Stack หน้าจอก่อนหน้าทิ้งทั้งหมด
        );
      }
    } on FirebaseAuthException catch (e) {
      // ปิด Loading เมื่อเกิด Error
      if (mounted) Navigator.pop(context);

      // จัดการ Error Message ตาม Code ของ Firebase
      String msg = e.message ?? "เกิดข้อผิดพลาด";
      if (e.code == 'email-already-in-use') msg = "อีเมลนี้ถูกใช้งานไปแล้ว";
      if (e.code == 'weak-password') msg = "รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร";

      showErrorMessage(msg);
    }
  }

  // --------------------------------------------------------------------------
  // [3] ฟังก์ชันบันทึกข้อมูลส่วนตัวลง Firestore
  // --------------------------------------------------------------------------
  Future<void> addUserDetails(String uid, String username, String email, String phone) async {
    // บันทึกข้อมูลลงใน Collection 'users' โดยใช้ UID เป็นชื่อเอกสาร (Doc ID)
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
      'email': email,
      'phone_number': phone,
      'role': 'user',        // กำหนดสิทธิ์ผู้ใช้เริ่มต้น
      'created_at': DateTime.now(), // บันทึกเวลาที่สมัคร
      'provider': 'email',   // บอกแหล่งที่มาว่าสมัครด้วยอีเมล
    });
  }

  // --------------------------------------------------------------------------
  // [4] ฟังก์ชันแสดงหน้าต่างแจ้งเตือน Error
  // --------------------------------------------------------------------------
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("สมัครสมาชิกไม่สำเร็จ"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ตกลง"),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // [5] ส่วนแสดงผลหน้าจอ (User Interface)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)], // พื้นหลังไล่เฉดสีฟ้า
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // ส่วนหัวข้อ
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // ส่วน Card สีขาวด้านล่าง (บรรจุฟอร์มกรอกข้อมูล)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // เรียกใช้ Widget _input ย่อยที่เราสร้างไว้
                        _input(Icons.person, "Username", _usernameController),
                        _input(Icons.email, "Email", _emailController),
                        _input(Icons.phone, "Mobile Number", _phoneController),
                        _input(Icons.lock, "Password", _passwordController, isPassword: true),

                        const SizedBox(height: 20),

                        // ปุ่มยืนยันการสมัคร
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            onPressed: signUp, // เรียกใช้ฟังก์ชันสมัครสมาชิก
                            child: const Text(
                              "Create Account",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ปุ่มสลับไปหน้า Login
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Text("Already have an account? Sign In"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // [6] Widget ย่อย (Helper) สำหรับสร้าง TextField เพื่อลดการเขียนซ้ำ
  // --------------------------------------------------------------------------
  Widget _input(IconData icon, String hint, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword, // ถ้าเป็นรหัสผ่านจะซ่อนตัวอักษรเป็นจุด
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}