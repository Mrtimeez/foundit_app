import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import หน้าจอที่เกี่ยวข้อง (เช็คชื่อ Path ให้ตรงกับโปรเจคของคุณ)
import 'package:foundit/authentication/login_screen.dart';
import 'package:foundit/navigation_bar.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    // ใช้ StreamBuilder ในการเฝ้าสังเกตสถานะการ Login
    return StreamBuilder<User?>(
      // [1] Stream: authStateChanges() คือ "สายธารข้อมูล" จาก Firebase
      // มันจะส่งข้อมูลมาทุกครั้งที่มีการ Login, Logout หรือตอนเปิดแอป
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // [2] ตรวจสอบสถานะการเชื่อมต่อ (ConnectionState)
        // ระหว่างที่รอ Firebase ตอบกลับมาว่ามี User ไหม ให้โชว์วงกลมโหลดก่อน
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // [3] ตรวจสอบว่ามีข้อมูล User หรือไม่ (snapshot.hasData)
        if (snapshot.hasData) {
          // ถ้ามีข้อมูล (Login อยู่) -> ส่งไปหน้าหลักที่มี Bottom Navigation
          return const MainNavigation();
        } else {
          // ถ้าไม่มีข้อมูล (ยังไม่ Login หรือ Logout แล้ว) -> ส่งไปหน้า Login
          return const LoginScreen();
        }
      },
    );
  }
}