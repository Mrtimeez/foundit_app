import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  // [1] ตัวควบคุมช่องกรอกข้อมูล (Controller)
  // ใช้สำหรับดึงค่าข้อความที่ผู้ใช้พิมพ์ในช่อง Email ออกมาใช้งาน
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    // ล้างหน่วยความจำของ Controller เมื่อหน้านี้ถูกปิดลง (ช่วยประหยัด RAM)
    _emailController.dispose();
    super.dispose();
  }

  // [2] ฟังก์ชันส่งอีเมลรีเซ็ตรหัสผ่าน (Logic หลัก)
  Future passwordReset() async {

    // --- ขั้นตอนที่ 1: ตรวจสอบข้อมูลเบื้องต้น (Validation) ---
    if (_emailController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text("กรุณากรอกอีเมล"),
        ),
      );
      return; // หยุดการทำงานถ้าไม่ได้กรอกอีเมล
    }

    // --- ขั้นตอนที่ 2: แสดงวงกลมโหลด (Loading Indicator) ---
    // เพื่อให้ผู้ใช้รู้ว่าระบบกำลังทำงาน ไม่ได้ค้าง
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันผู้ใช้กดที่ว่างเพื่อปิดตอนกำลังโหลด
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // --- ขั้นตอนที่ 3: สั่งให้ Firebase ส่งอีเมลรีเซ็ต ---
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // --- ขั้นตอนที่ 4: เมื่อสำเร็จ (Success) ---
      // ปิดวงกลมโหลด (Pop ตัวแรก)
      if (mounted) Navigator.pop(context);

      // แสดง Popup แจ้งเตือนผู้ใช้ว่าส่งเมลแล้ว
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text("ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว\nกรุณาตรวจสอบอีเมลของคุณ"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // ปิด Dialog นี้
                    Navigator.pop(context); // ย้อนกลับไปยังหน้า Login ทันที
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      // --- ขั้นตอนที่ 5: จัดการข้อผิดพลาด (Error Handling) ---

      // ปิดวงกลมโหลดก่อนแสดงข้อความ Error
      if (mounted) Navigator.pop(context);

      // แปลงรหัส Error จาก Firebase ให้เป็นภาษาไทยที่คนทั่วไปอ่านเข้าใจ
      String errorMessage = e.message ?? "เกิดข้อผิดพลาด";
      if (e.code == 'user-not-found') {
        errorMessage = "ไม่พบอีเมลนี้ในระบบ";
      } else if (e.code == 'invalid-email') {
        errorMessage = "รูปแบบอีเมลไม่ถูกต้อง";
      }

      // แสดง Popup แจ้งเตือนสาเหตุที่ส่งไม่สำเร็จ
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
        // [3] ส่วนของการตกแต่งพื้นหลัง (Background Decoration)
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient( // ไล่เฉดสีฟ้าจากบนลงล่าง
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2EC4FF), Color(0xFF2196F3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView( // ป้องกันหน้าจอ "ล้น" เวลาคีย์บอร์ดเด้งขึ้นมา
            child: Column(
              children: [
                const SizedBox(height: 80),

                // [4] บัตรรายการ (Card UI)
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
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Enter your email address and we will send you a link to reset your password.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // [5] ช่องกรอกอีเมล (Email Input)
                      TextField(
                        controller: _emailController, // เชื่อมกับ Controller ที่ประกาศไว้ข้างบน
                        keyboardType: TextInputType.emailAddress,
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

                      // [6] ปุ่มกดส่ง (Send Button)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: passwordReset, // เมื่อกดจะวิ่งไปทำงานที่ฟังก์ชันข้างบน
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Send Reset Link",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // [7] ปุ่มย้อนกลับ (Back Navigation)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // ปิดหน้านี้เพื่อย้อนกลับไปหน้าก่อนหน้า (Login)
                  },
                  child: const Text(
                    "Back to Sign In",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}