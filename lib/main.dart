import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ตัวเชื่อม Firebase
import 'package:foundit/authentication/login_screen.dart';
import 'package:foundit/authentication/signup.dart';
import 'package:foundit/authentication/warpper.dart'; // ตัวเช็คสถานะว่า Login หรือยัง
import 'navigation_bar.dart';

// --------------------------------------------------------------------------
// ฟังก์ชัน main() - จุดเริ่มต้นของแอปพลิเคชัน
// --------------------------------------------------------------------------
void main() async {
  // 1. ปลุก Flutter ให้เตรียมพร้อมก่อน (จำเป็นมากเวลาจะใช้พวก Firebase หรือฐานข้อมูล)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. สั่งเชื่อมต่อแอปเราเข้ากับ Firebase
  await Firebase.initializeApp();

  // 3. สั่งรันแอปพลิเคชันเลย!
  runApp(const MyApp());
}

// --------------------------------------------------------------------------
// MyApp - โครงสร้างหลักของแอป
// --------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp คือรากฐานที่จัดการเรื่อง หน้าจอ, ธีมสี, และการเปลี่ยนหน้า
    return MaterialApp(
      // เอาป้ายคำว่า "DEBUG" สีแดงๆ มุมขวาบนออก
      debugShowCheckedModeBanner: false,

      title: 'Found it',

      // ตั้งค่าธีมสีหลักของแอป (แก้ .fromSeed เป็น ColorScheme.fromSeed ให้แล้วครับ)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // ----------------------------------------------------------------------
      // [3] หน้าแรกที่จะโชว์ตอนเปิดแอป (home)
      // โยนหน้าที่ให้ Wrapper เป็นคนคิดว่า "ควรไปหน้า Login หรือ หน้า Home ดี?"
      // ----------------------------------------------------------------------
      home: const Wrapper(),

      // ----------------------------------------------------------------------
      // [4] แผนที่นำทาง (Routes)
      // ตั้งชื่อย่อให้แต่ละหน้า เวลาจะเปลี่ยนหน้าจะได้พิมพ์แค่ชื่อสั้นๆ เช่น '/login'
      // ----------------------------------------------------------------------
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainNavigation(), // หน้าที่มีแถบเมนูด้านล่าง
      },
    );
  }
}