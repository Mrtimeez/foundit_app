import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // นำเข้า Firebase Auth เพื่อใช้ระบบสมัครสมาชิก
import 'warpper.dart'; // นำเข้า Wrapper หรือ Homepage เพื่อลิงก์ไปหน้าแรกเมื่อสมัครเสร็จ
import 'login_screen.dart'; // นำเข้าหน้า Login
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    // แสดง Loading
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. สร้าง User ใน Authentication (เหมือนเดิม)
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. เก็บข้อมูลเพิ่มเติมลง Cloud Firestore
      // เช็คว่า User ถูกสร้างสำเร็จและมี UID
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid; // ดึง UID ของ User ที่เพิ่งสมัคร

        await addUserDetails(
          uid,
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(), // นี่คือสิ่งที่เราอยากเก็บเพิ่ม
        );
      }

      // ปิด Loading
      if (mounted) Navigator.pop(context);

      // ไปหน้า Wrapper (เข้าสู่ระบบอัตโนมัติ)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Wrapper()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      showErrorMessage(e.message ?? "เกิดข้อผิดพลาด");
    }
  }

  // --- ฟังก์ชันแยกสำหรับบันทึกข้อมูลลง Firestore ---
  Future<void> addUserDetails(String uid, String username, String email, String phone) async {
    // ไปที่ Collection ชื่อ "users" -> สร้าง Document ชื่อเดียวกับ UID -> ใส่ข้อมูล
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'phone_number': phone, // เก็บเบอร์โทรที่นี่
      'role': 'user',        // (แถม) เก็บ Role เผื่อทำแอดมินในอนาคต
      'created_at': DateTime.now(), // (แถม) เก็บวันที่สมัคร
    });
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Registration Failed"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // --- ส่วนแสดงผลหน้าจอ (UI) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ตกแต่งพื้นหลังแบบ ไล่เฉดสี (Gradient)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // หัวข้อหน้าจอ
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // ส่วนกล่องสีขาวโค้งมนด้านล่าง
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ช่องกรอกข้อมูล โดยส่ง Controller เข้าไปเก็บค่า
                        _input(Icons.person, "Username", _usernameController),
                        _input(Icons.email, "Email", _emailController),
                        _input(Icons.phone, "Mobile Number", _phoneController,),
                        _input(Icons.lock, "Password", _passwordController, isPassword: true),

                        const SizedBox(height: 20),

                        // ปุ่ม Create Account
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            // เมื่อกดปุ่ม ให้เรียกฟังก์ชัน signUp()
                            onPressed: signUp,
                            child: const Text(
                              "Create Account",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ปุ่มลิงก์กลับไปหน้า Login
                        TextButton(
                          onPressed: () {
                            // กลับไปหน้า Login
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
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

  // Widget ย่อยสำหรับสร้างช่องกรอกข้อมูล (TextField) เพื่อลดโค้ดซ้ำ
  Widget _input(IconData icon, String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller, // เชื่อมตัวแปร Controller
        obscureText: isPassword, // ถ้าเป็นรหัสผ่าน ให้ซ่อนตัวอักษร
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