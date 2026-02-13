import 'package:flutter/material.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  Widget section(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 10),
          ...items.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text("• $e"),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text("ศูนย์ลูกค้าสัมพันธ์"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            section("บริการช่วยเหลือ", [
              "แจ้งปัญหาการใช้งานระบบ",
              "ติดตามสถานะรายการของหาย",
              "ขอแก้ไขข้อมูลบัญชี",
              "รายงานโพสต์ไม่เหมาะสม",
            ]),

            section("ช่องทางช่วยเหลือ", [
              "แชทในแอพ",
              "อีเมลฝ่ายสนับสนุน",
              "โทร Call Center",
              "แบบฟอร์มติดต่อออนไลน์",
            ]),

            section("ระยะเวลาดำเนินการ", [
              "ตอบกลับภายใน 24 ชั่วโมง",
              "กรณีเร่งด่วนภายใน 2 ชั่วโมง",
              "วันหยุดอาจใช้เวลานานขึ้น",
            ]),
          ],
        ),
      ),
    );
  }
}
