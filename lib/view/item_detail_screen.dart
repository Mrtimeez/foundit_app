import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  // ประกาศตัวแปรเพื่อ "รอรับข้อมูล" ที่จะถูกส่งมาจากหน้าอื่น
  final String title;     // ชื่อสิ่งของ
  final String desc;      // รายละเอียด
  final String location;  // สถานที่
  final String phone;     // เบอร์โทร
  final String lineId;    // ไอดีไลน์
  final String time;      // เวลาที่โพส
  final String status;    // สถานะ (เช่น กำลังตามหา, พบของแล้ว)

  // Constructor: บังคับว่าเวลาเรียกเปิดหน้านี้ "ต้อง" ส่งข้อมูลพวกนี้มาด้วยนะ (required)
  const PostDetailScreen({
    super.key,
    required this.title,
    required this.desc,
    required this.location,
    required this.phone,
    required this.lineId,
    required this.time,
    required this.status,
  });
  // --------------------------------------------------------------------------
  // ฟังก์ชัน "เช็คสีสถานะ"
  // เปลี่ยนสีป้ายสถานะอัตโนมัติตามข้อความที่ส่งมา
  // --------------------------------------------------------------------------
  Color statusColor() {
    switch (status) {
      case "พบของแล้ว":
        return Colors.green; // ถ้าเจอแล้ว ให้เป็น สีเขียว
      case "มีคนติดต่อ":
        return Colors.blue;  // ถ้ามีคนติดต่อแล้ว ให้เป็น สีฟ้า
      default:
        return Colors.orange;// สถานะอื่นๆ (เช่น กำลังตามหา) ให้เป็น สีส้ม
    }
  }
  // --------------------------------------------------------------------------
  // ส่วนวาดหน้าจอหลัก (UI)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // สีพื้นหลังหน้าจอเป็นสีฟ้าอ่อนๆ

      // แถบเมนูด้านบน
      appBar: AppBar(
        title: const Text("รายละเอียดโพส"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2196F3), // สีตัวหนังสือและปุ่มกด (สีฟ้า)
        elevation: 0, // เอาเงาใต้ AppBar ออกให้ดูแบนๆ ทันสมัย
      ),

      // เนื้อหาตรงกลาง สามารถเลื่อนขึ้นลงได้ (กันข้อมูลยาวจนล้นจอ)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          // สร้าง "การ์ดสีขาว" มารองรับข้อความทั้งหมด
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // ทำมุมการ์ดให้โค้งๆ
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // จัดให้ข้อความชิดซ้ายทั้งหมด
            children: [

              // เรียกใช้แม่พิมพ์ _row เพื่อแสดงข้อมูลเป็นคู่ๆ (หัวข้อ + รายละเอียด)
              _row("ชื่อสิ่งของ", title),
              _row("รายละเอียด", desc),
              _row("สถานที่", location),

              // เส้นคั่นบางๆ เพื่อแบ่งสัดส่วนข้อมูลให้ดูง่ายขึ้น
              const Divider(height: 28),

              // หมวดหมู่: ช่องทางติดต่อ
              const Text(
                "ช่องทางติดต่อ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3)), // ตัวหนังสือสีฟ้า
              ),
              const SizedBox(height: 8), // เว้นระยะนิดนึง

              _row("เบอร์", phone),
              _row("LINE ID", lineId),

              // เส้นคั่นบางๆ
              const Divider(height: 28),

              _row("เวลาโพส", time),

              const SizedBox(height: 12),

              // ป้ายสถานะ (Badge) ด้านล่างสุด
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // ดึงสีจากฟังก์ชัน statusColor() มาทำให้โปร่งใส 15% เพื่อเป็นสีพื้นหลัง
                  color: statusColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status, // ข้อความสถานะ
                  style: TextStyle(
                    color: statusColor(), // สีตัวหนังสือตรงกับสถานะ
                    fontWeight: FontWeight.bold,
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
  // แม่พิมพ์สำหรับจัดเรียงข้อความ (Widget ช่วยเหลือ)
  // เอาไว้แสดง "หัวข้อสีฟ้า" และ "รายละเอียดสีดำ" เรียงต่อกันบนล่าง
  // --------------------------------------------------------------------------
  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // ระยะห่างด้านล่างแต่ละกล่อง
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวข้อ (Label) สีฟ้า ตัวหนา
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3))),
          const SizedBox(height: 4), // เว้นบรรทัด
          // ข้อความรายละเอียด (Value)
          Text(value),
        ],
      ),
    );
  }
}