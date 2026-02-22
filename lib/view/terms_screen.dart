import 'package:flutter/material.dart';

// หน้านี้มีแค่ข้อความให้อ่านอย่างเดียว ไม่มีการกดปุ่มสลับค่า เลยใช้ StatelessWidget
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  // --------------------------------------------------------------------------
  // แม่พิมพ์สำหรับสร้าง "กล่องเงื่อนไข" แต่ละหมวดหมู่
  // รับค่า: หัวข้อ (title), ไอคอน (icon), และรายการข้อความย่อย (items)
  // --------------------------------------------------------------------------
  Widget _section(String title, IconData icon, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18), // ขอบโค้งมน
        boxShadow: [
          // เงาสีฟ้าอ่อนๆ ให้การ์ดดูลอยขึ้นมา
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // โซนหัวข้อ (ไอคอน + ชื่อหมวดหมู่)
          Row(
            children: [
              // กรอบวงกลมสีฟ้าอ่อนรองรับไอคอน
              CircleAvatar(
                backgroundColor: const Color(0xFFE3F2FD),
                child: Icon(icon, color: const Color(0xFF2196F3)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // โซนข้อความย่อย (วนลูปสร้างจุด Bullet ตามจำนวนข้อความที่ส่งมา)
          ...items.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // ให้จุดไข่ปลาอยู่บรรทัดบนสุดเสมอ
                children: [
                  const Text("•  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                  // ใช้ Expanded ครอบข้อความไว้
                  // ถ้าข้อความยาวเกินหน้าจอ มันจะตัดขึ้นบรรทัดใหม่ให้อัตโนมัติ (ไม่ Error จอเหลืองดำ)
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14, height: 1.5), // height: 1.5 คือระยะห่างบรรทัดให้อ่านง่าย
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      backgroundColor: const Color(0xFFF4F9FF), // พื้นหลังสีฟ้าอ่อนสบายตา

      // แถบด้านบน
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0, // ปิดเงาใต้ AppBar ให้กลืนไปกับ Header
        title: const Text(
          "เงื่อนไขและข้อตกลงการใช้งาน",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // หน้าจอไถขึ้นลงได้
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ----------------------------------------------------------------
            // กล่อง Header ไล่สี (Gradient) ด้านบนสุด
            // ----------------------------------------------------------------
            Container(
              width: double.infinity, // กว้างเต็มจอ (ตามที่ Padding อนุญาต)
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                // ไล่สีจากฟ้าเข้ม ไปฟ้าอ่อน
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ข้อตกลงการใช้งานระบบแจ้งของหาย–ของพบ",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "โปรดอ่านเงื่อนไขทั้งหมดก่อนใช้งาน เพื่อความปลอดภัยของผู้ใช้และความถูกต้องของข้อมูล",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "อัปเดตล่าสุด: 2026",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ----------------------------------------------------------------
            // โซนเรียกใช้กล่องเงื่อนไขแต่ละข้อ
            // ----------------------------------------------------------------
            _section("วัตถุประสงค์ของระบบ", Icons.info_outline, [
              "ใช้สำหรับแจ้งของหายและของที่พบเท่านั้น",
              "ช่วยให้ผู้ใช้สามารถติดต่อกันเพื่อติดตามทรัพย์สิน",
              "ไม่ใช่แพลตฟอร์มซื้อขายสินค้า",
              "ไม่อนุญาตให้ใช้เพื่อการโฆษณา",
            ]),

            _section("การใช้งานทั่วไป", Icons.rule, [
              "ผู้ใช้ต้องกรอกข้อมูลตามความเป็นจริง",
              "รายละเอียดควรครบถ้วนและตรวจสอบได้",
              "ห้ามสร้างรายการปลอมหรือทำให้ผู้อื่นเข้าใจผิด",
              "หนึ่งเหตุการณ์ควรโพสต์เพียงหนึ่งรายการ",
            ]),

            _section("เนื้อหาและพฤติกรรมต้องห้าม", Icons.block, [
              "ห้ามใช้คำหยาบคาย ดูหมิ่น หรือคุกคาม",
              "ห้ามโพสต์ข้อมูลเท็จ",
              "ห้ามใช้รูปภาพที่ไม่เกี่ยวข้อง",
              "ห้ามเปิดเผยข้อมูลส่วนบุคคลของผู้อื่น",
              "ห้ามแอบอ้างความเป็นเจ้าของทรัพย์สิน",
            ]),

            _section("ความรับผิดชอบของผู้ใช้", Icons.verified_user, [
              "ผู้ใช้รับผิดชอบเนื้อหาที่โพสต์ทั้งหมด",
              "ควรตรวจสอบข้อมูลก่อนกดบันทึก",
              "การนัดรับของควรทำในที่ปลอดภัย",
              "ควรมีหลักฐานยืนยันความเป็นเจ้าของ",
              "การติดต่อกันนอกระบบถือเป็นความรับผิดชอบของผู้ใช้",
            ]),

            _section("ความเป็นส่วนตัวและข้อมูล", Icons.lock, [
              "ข้อมูลจะใช้เพื่อแสดงผลภายในระบบ",
              "ระบบจะไม่เผยแพร่ข้อมูลเกินความจำเป็น",
              "ไม่ควรโพสต์เลขบัตรหรือข้อมูลสำคัญ",
              "แนะนำให้ใช้ข้อมูลติดต่อเฉพาะที่จำเป็น",
            ]),

            _section("สิทธิ์ของผู้ดูแลระบบ", Icons.admin_panel_settings, [
              "สามารถลบโพสต์ที่ไม่เหมาะสมได้",
              "สามารถระงับบัญชีที่ฝ่าฝืนกฎ",
              "สามารถแก้ไขเงื่อนไขได้ในอนาคต",
              "การตัดสินของผู้ดูแลถือเป็นที่สิ้นสุด",
            ]),

            const SizedBox(height: 20),

            // ข้อความปิดท้าย
            const Text(
              "การใช้งานระบบนี้ถือว่าผู้ใช้รับทราบและยอมรับเงื่อนไขทั้งหมด",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),

            const SizedBox(height: 30), // เว้นที่ว่างด้านล่างสุดนิดนึง จะได้เลื่อนจอสบายๆ
          ],
        ),
      ),
    );
  }
}