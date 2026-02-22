import 'package:flutter/material.dart';

// หน้านี้ใช้ StatelessWidget เพราะเป็นแค่หน้าโชว์ข้อมูลเฉยๆ ไม่มีการโหลดข้อมูลหรือพิมพ์อะไรเพิ่ม
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // --------------------------------------------------------------------------
  // [1] แม่พิมพ์สำหรับสร้าง "กล่องข้อมูลติดต่อ" (infoCard)
  // สร้างไว้เพื่อใช้ซ้ำ จะได้ไม่ต้องเขียนโค้ดกล่องเดิมๆ หลายรอบ
  // รับค่า 3 อย่าง: ไอคอน (icon), หัวข้อ (title), และ รายละเอียด (value)
  // --------------------------------------------------------------------------
  Widget infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14), // ระยะห่างด้านล่างของแต่ละกล่อง
      padding: const EdgeInsets.all(16), // ระยะห่างจากขอบกล่องถึงข้อความด้านใน
      decoration: BoxDecoration(
        color: Colors.white, // พื้นหลังกล่องสีขาว
        borderRadius: BorderRadius.circular(18), // ทำขอบกล่องให้โค้งมน
        boxShadow: [
          // ใส่เงาบางๆ ให้กล่องดูลอยขึ้นมา
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
          )
        ],
      ),
      // จับไอคอนและข้อความมาเรียงต่อกันในแนวนอน (ซ้ายไปขวา)
      child: Row(
        children: [
          // พื้นหลังวงกลมสีฟ้าอ่อนๆ รองรับตัวไอคอน
          CircleAvatar(
            backgroundColor: const Color(0xFFE3F2FD),
            child: Icon(icon, color: const Color(0xFF2196F3)),
          ),
          const SizedBox(width: 14), // เว้นวรรคระหว่างไอคอนกับข้อความ

          // ใช้ Expanded เพื่อให้ข้อความใช้พื้นที่ที่เหลือทั้งหมด (กันตัวหนังสือล้นจอ)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // จัดข้อความชิดซ้าย
              children: [
                // หัวข้อ (เช่น "อีเมล", "โทรศัพท์")
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4), // เว้นบรรทัดนิดนึง
                // รายละเอียด (เช่น เบอร์โทร, เว็บไซต์)
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // [2] ส่วนวาดหน้าจอหลัก (UI)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // สีพื้นหลังหน้าจอเป็นสีฟ้าอ่อนสบายตา

      // แถบด้านบนของหน้าจอ
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3), // แถบสีฟ้าเข้ม
        title: const Text("ติดต่อเรา"), // ชื่อหน้าจอ
      ),

      // พื้นที่แสดงเนื้อหาตรงกลางหน้าจอ
      body: Padding(
        padding: const EdgeInsets.all(16), // ขยับเนื้อหาให้ห่างจากขอบจอ
        child: Column(
          children: [
            // เรียกใช้แม่พิมพ์ (infoCard) ที่เราสร้างไว้ข้างบน แล้วป้อนข้อมูลใส่เข้าไปได้เลย

            // 1. กล่องอีเมล
            infoCard(Icons.email, "อีเมล", "support@founditapp.com"),

            // 2. กล่องเบอร์โทรศัพท์
            infoCard(Icons.phone, "โทรศัพท์", "02-123-4567"),

            // 3. กล่องเว็บไซต์
            infoCard(Icons.language, "เว็บไซต์", "www.founditapp.com"),

            // 4. กล่องเวลาทำการ
            infoCard(Icons.access_time, "เวลาทำการ", "ทุกวัน 08:00 - 20:00 น."),

          ],
        ),
      ),
    );
  }
}