import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. อย่าลืม import firebase_auth

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // 2. ตัวควบคุมช่องกรอกข้อความ
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // 3. ฟังก์ชันส่งอีเมลรีเซ็ตรหัสผ่าน
  Future passwordReset() async {
    // ตรวจสอบว่ากรอกอีเมลหรือยัง
    if (_emailController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text("กรุณากรอกอีเมล"),
        ),
      );
      return;
    }

    // แสดง Loading
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // ปิด Loading
      if (mounted) Navigator.pop(context);

      // แสดงข้อความสำเร็จ
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text("ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว\nกรุณาตรวจสอบอีเมลของคุณ"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // ปิด Dialog
                    Navigator.pop(context); // กลับไปหน้า Login
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      // ปิด Loading
      if (mounted) Navigator.pop(context);

      // แปลง Error เป็นข้อความที่เข้าใจง่าย
      String errorMessage = e.message ?? "เกิดข้อผิดพลาด";
      if (e.code == 'user-not-found') {
        errorMessage = "ไม่พบอีเมลนี้ในระบบ";
      } else if (e.code == 'invalid-email') {
        errorMessage = "รูปแบบอีเมลไม่ถูกต้อง";
      }

      // แสดง Error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(errorMessage),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("ตกลง"))
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2EC4FF),
              Color(0xFF2196F3),
            ],
          ),
        ),
        child: SafeArea( //SafeArea กันติดขอบจอมือถือรุ่นใหม่
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),

                /// ---------- Card ----------
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Enter your email address and we will send you a link to reset your password.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 24),

                      /// Email Field
                      TextField(
                        controller: _emailController, // เชื่อม Controller ตรงนี้
                        keyboardType: TextInputType.emailAddress, // แป้นพิมพ์แบบอีเมล
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          hintText: "Email",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Send Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: passwordReset, // เรียกฟังก์ชัน reset
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Send Reset Link",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Back to Sign In
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Back to Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}