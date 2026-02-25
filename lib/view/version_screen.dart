import 'package:flutter/material.dart';

// หน้านี้มีแค่ข้อความสั้นๆ หน้าเดียว เลยใช้ StatelessWidget
class VersionScreen extends StatelessWidget {
  const VersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // แถบด้านบน (AppBar) สีฟ้า
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text("เวอร์ชั่น"),
      ),

      // ตัวหนังสืออยู่ตรงกลางหน้าจอเป๊ะๆ
      body: const Center(
        child: Text(
          "App Version A1.0.4",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}