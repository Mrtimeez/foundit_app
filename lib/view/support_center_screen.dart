import 'package:flutter/material.dart';

// หน้านี้โชว์ข้อมูลอย่างเดียว ไม่มีการกดเปลี่ยนค่าอะไร เลยใช้แค่ StatelessWidget
class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  // --------------------------------------------------------------------------
  // แม่พิมพ์สำหรับสร้าง "กล่องหมวดหมู่" (Section)
  // รับค่า 2 อย่าง: หัวข้อ (title) และ รายการข้อความย่อยๆ (items ที่เป็น List)
  // --------------------------------------------------------------------------
  Widget section(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // ระยะห่างระหว่างกล่อง
      padding: const EdgeInsets.all(16), // ระยะห่างจากขอบกล่องถึงตัวหนังสือด้านใน
      decoration: BoxDecoration(
        color: Colors.white, // พื้นหลังกล่องสีขาว
        borderRadius: BorderRadius.circular(18), // ทำขอบกล่องให้โค้งมน
        // ใส่เงาบางๆ ให้กล่องดูลอยขึ้นมาจากพื้นหลัง
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // จัดให้ทุกข้อความชิดซ้าย
        children: [
          // 1. โชว์ "หัวข้อ" (ตัวหนา)
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10), // เว้นบรรทัดนิดนึง

          // 2. โชว์ "รายการข้อความย่อย"
          // คำสั่ง ... (จุด 3 จุด) คือการแตกเอาข้อมูลใน List ออกมาเรียงต่อกัน
          // .map() คือการเอาข้อความแต่ละอันมาเติมจุดวงกลม (•) ไว้ข้างหน้า
          ...items.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6), // ระยะห่างแต่ละบรรทัด
            child: Text("• $e"), // ใส่จุด Bullet หน้าข้อความ
          ))
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ส่วนสร้างหน้าจอหลัก (UI)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // สีพื้นหลังหน้าจอเป็นสีฟ้าอ่อนๆ สบายตา

      // แถบด้านบน
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3), // สีฟ้าเข้ม
        title: const Text("ศูนย์ลูกค้าสัมพันธ์"),
      ),

      // ใช้ SingleChildScrollView เพื่อให้หน้าจอไถขึ้นลงได้ (กันตัวหนังสือล้นจอทะลุขอบล่าง)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // เรียกใช้แม่พิมพ์ section() แล้วโยนข้อความใส่เข้าไปได้เลย!

            // กล่องที่ 1: บริการช่วยเหลือ
            section("บริการช่วยเหลือ", [
              "แจ้งปัญหาการใช้งานระบบ",
              "ติดตามสถานะรายการของหาย",
              "ขอแก้ไขข้อมูลบัญชี",
              "รายงานโพสต์ไม่เหมาะสม",
            ]),

            // กล่องที่ 2: ช่องทางช่วยเหลือ
            section("ช่องทางช่วยเหลือ", [
              "แชทในแอพ",
              "อีเมลฝ่ายสนับสนุน",
              "โทร Call Center",
              "แบบฟอร์มติดต่อออนไลน์",
            ]),

            // กล่องที่ 3: ระยะเวลาดำเนินการ
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