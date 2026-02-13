import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Widget _section(String title, IconData icon, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE3F2FD),
                child: Icon(icon, color: const Color(0xFF2196F3)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("•  ",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14, height: 1.5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text(
          "เงื่อนไขและข้อตกลงการใช้งาน",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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

            _section(
              "วัตถุประสงค์ของระบบ",
              Icons.info_outline,
              [
                "ใช้สำหรับแจ้งของหายและของที่พบเท่านั้น",
                "ช่วยให้ผู้ใช้สามารถติดต่อกันเพื่อติดตามทรัพย์สิน",
                "ไม่ใช่แพลตฟอร์มซื้อขายสินค้า",
                "ไม่อนุญาตให้ใช้เพื่อการโฆษณา",
              ],
            ),

            _section(
              "การใช้งานทั่วไป",
              Icons.rule,
              [
                "ผู้ใช้ต้องกรอกข้อมูลตามความเป็นจริง",
                "รายละเอียดควรครบถ้วนและตรวจสอบได้",
                "ห้ามสร้างรายการปลอมหรือทำให้ผู้อื่นเข้าใจผิด",
                "หนึ่งเหตุการณ์ควรโพสต์เพียงหนึ่งรายการ",
              ],
            ),

            _section(
              "เนื้อหาและพฤติกรรมต้องห้าม",
              Icons.block,
              [
                "ห้ามใช้คำหยาบคาย ดูหมิ่น หรือคุกคาม",
                "ห้ามโพสต์ข้อมูลเท็จ",
                "ห้ามใช้รูปภาพที่ไม่เกี่ยวข้อง",
                "ห้ามเปิดเผยข้อมูลส่วนบุคคลของผู้อื่น",
                "ห้ามแอบอ้างความเป็นเจ้าของทรัพย์สิน",
              ],
            ),

            _section(
              "ความรับผิดชอบของผู้ใช้",
              Icons.verified_user,
              [
                "ผู้ใช้รับผิดชอบเนื้อหาที่โพสต์ทั้งหมด",
                "ควรตรวจสอบข้อมูลก่อนกดบันทึก",
                "การนัดรับของควรทำในที่ปลอดภัย",
                "ควรมีหลักฐานยืนยันความเป็นเจ้าของ",
                "การติดต่อกันนอกระบบถือเป็นความรับผิดชอบของผู้ใช้",
              ],
            ),

            _section(
              "ความเป็นส่วนตัวและข้อมูล",
              Icons.lock,
              [
                "ข้อมูลจะใช้เพื่อแสดงผลภายในระบบ",
                "ระบบจะไม่เผยแพร่ข้อมูลเกินความจำเป็น",
                "ไม่ควรโพสต์เลขบัตรหรือข้อมูลสำคัญ",
                "แนะนำให้ใช้ข้อมูลติดต่อเฉพาะที่จำเป็น",
              ],
            ),

            _section(
              "สิทธิ์ของผู้ดูแลระบบ",
              Icons.admin_panel_settings,
              [
                "สามารถลบโพสต์ที่ไม่เหมาะสมได้",
                "สามารถระงับบัญชีที่ฝ่าฝืนกฎ",
                "สามารถแก้ไขเงื่อนไขได้ในอนาคต",
                "การตัดสินของผู้ดูแลถือเป็นที่สิ้นสุด",
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "การใช้งานระบบนี้ถือว่าผู้ใช้รับทราบและยอมรับเงื่อนไขทั้งหมด",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
