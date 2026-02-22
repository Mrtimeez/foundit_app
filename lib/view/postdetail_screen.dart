import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ตัวจัดการฐานข้อมูล

// หน้านี้ใช้ StatefulWidget เพราะเราต้องมีการ "อัปเดตหน้าจอ" ทันทีเวลาเปลี่ยนสถานะของหาย
class PostDetailScreen extends StatefulWidget {
  final String? docId; // ID ของโพส (เอาไว้ใช้ตอนสั่งลบ/แก้ไข)
  final String title;
  final String desc;
  final String location;
  final String status;
  final String phone;
  final String lineId;
  final String time;
  final String? imageUrl; // ลิงก์รูปภาพ

  const PostDetailScreen({
    super.key,
    this.docId,
    required this.title,
    required this.desc,
    required this.location,
    required this.status,
    required this.phone,
    required this.lineId,
    required this.time,
    this.imageUrl,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late String status; // ตัวแปรเก็บสถานะ "ปัจจุบัน" เพื่อเอาไว้โชว์บนจอ

  @override
  void initState() {
    super.initState();
    status = widget.status; // ตอนเปิดหน้ามาครั้งแรก ให้ดึงสถานะที่ส่งมาไปเก็บไว้ก่อน
  }

  // --------------------------------------------------------------------------
  // [1] ฟังก์ชันกำหนดสีป้ายสถานะ (เหมือนเดิมเลย)
  // --------------------------------------------------------------------------
  Color _statusColor(String s) {
    switch (s) {
      case "พบของแล้ว": return Colors.green;
      case "มีคนติดต่อ": return Colors.blue;
      case "คืนของแล้ว": return Colors.grey;
      default: return Colors.orange;
    }
  }

  // --------------------------------------------------------------------------
  // ฟังก์ชัน "เปลี่ยนสถานะ"
  // เด้งหน้าต่างให้เลือกสถานะใหม่ -> บันทึกลงฐานข้อมูล -> เปลี่ยนสีป้ายบนจอ
  // --------------------------------------------------------------------------
  void _changeStatus() async {
    // ถ้าไม่มี docId (แสดงว่าเปิดดูจากหน้า Feed รวม ไม่ใช่หน้าของฉัน) ห้ามให้แก้!
    if (widget.docId == null) return;

    // เปิดหน้าต่าง (Dialog) ขึ้นมาให้เลือกสถานะ
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เปลี่ยนสถานะ"),
        content: Column(
          mainAxisSize: MainAxisSize.min, // ให้กล่องใหญ่พอดีกับตัวเลือก
          children: [
            _statusBtn("รอการติดต่อ"),
            _statusBtn("มีคนติดต่อ"),
            _statusBtn("พบของแล้ว"),
            _statusBtn("คืนของแล้ว"),
          ],
        ),
      ),
    );

    // ถ้าผู้ใช้กดเลือกสถานะมา (ไม่ได้กดทิ้งไปเฉยๆ)
    if (result != null) {
      // 1. แอบส่งข้อมูลไปอัปเดตในฐานข้อมูล Firestore
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.docId!)
          .update({'status': result}); // เปลี่ยนแค่ช่อง status

      // 2. สั่งรีเฟรชหน้าจอ (setState) เพื่อให้ป้ายเปลี่ยนสีตามสถานะใหม่ทันที
      setState(() => status = result);
    }
  }

  // Widget ย่อย: ทำปุ่มกดเลือกสถานะใน Dialog
  Widget _statusBtn(String s) {
    return ListTile(
      title: Text(s),
      leading: Icon(Icons.circle, size: 12, color: _statusColor(s)), // ใส่จุดสีๆ หน้าข้อความ
      onTap: () => Navigator.pop(context, s), // พอกดปุ๊บ ให้ส่งข้อความนั้นกลับไป
    );
  }

  // --------------------------------------------------------------------------
  // ฟังก์ชัน "ลบโพส"
  // ถามก่อนลบ ป้องกันมือลั่น แล้วไปลบข้อมูลจากฐานข้อมูลจริงๆ
  // --------------------------------------------------------------------------
  void _deletePost() {
    if (widget.docId == null) return; // ไม่ใช่เจ้าของ ห้ามลบ!

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: const Text("ต้องการลบโพสนี้ใช่หรือไม่?"),
        actions: [
          // ปุ่มยกเลิก
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),

          // ปุ่มยืนยันลบ
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // ปิดหน้าต่างถามก่อน

              // สั่งลบข้อมูลทิ้งจากฐานข้อมูลเลย
              await FirebaseFirestore.instance.collection('posts').doc(widget.docId!).delete();

              // ลบเสร็จแล้ว ให้เด้งกลับไปหน้าก่อนหน้า (ปิดหน้ารายละเอียดนี้ทิ้งไป)
              if (mounted) Navigator.pop(context);
            },
            child: const Text("ลบโพส", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ส่วนจัดหน้าจอ (UI)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        title: const Text("รายละเอียดโพส"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ส่วนโชว์รูปภาพ (ถ้ามีรูปลิงก์มาก็โชว์ ถ้าไม่มีก็โชว์กรอบว่างๆ)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.imageUrl != null
                  ? Image.network(
                widget.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover, // จัดรูปให้เต็มกรอบแบบไม่เบี้ยว
                errorBuilder: (_, __, ___) => _placeholderImage(), // ถ้ารูปโหลดไม่ขึ้น
              )
                  : _placeholderImage(),
            ),
            const SizedBox(height: 16),

            // การ์ดสีขาวสำหรับโชว์ข้อมูลรายละเอียดทั้งหมด
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row("ชื่อสิ่งของ", widget.title),
                  _row("รายละเอียด", widget.desc),
                  _row("สถานที่", widget.location),
                  _row("เบอร์โทร", widget.phone),
                  _row("Line ID", widget.lineId),
                  _row("เวลา", widget.time),
                  const SizedBox(height: 12),

                  // ป้ายสถานะ
                  const Text("สถานะ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(status, style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ----------------------------------------------------------------
            // โซนปุ่มกด "แก้ไข/ลบ"
            // เช็คว่าถ้ามี docId ส่งมา (แปลว่าเป็นเจ้าของโพส) ถึงจะโชว์ปุ่ม 2 อันนี้
            // ----------------------------------------------------------------
            if (widget.docId != null) ...[
              // ปุ่มแก้ไขสถานะ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _changeStatus,
                  icon: const Icon(Icons.edit),
                  label: const Text("แก้ไขสถานะ"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ปุ่มลบโพส
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _deletePost,
                  icon: const Icon(Icons.delete),
                  label: const Text("ลบโพส"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ], // สิ้นสุดโซนเช็คเจ้าของ
          ],
        ),
      ),
    );
  }
  // Widget ย่อย: โชว์กรอบสีฟ้าพร้อมไอคอนรูปภาพ (เอาไว้โชว์ตอนคนโพสไม่ได้ใส่รูปมา)
  Widget _placeholderImage() {
    return Container(
      width: double.infinity, height: 200,
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(16)),
      child: const Center(child: Icon(Icons.image, size: 64, color: Color(0xFF2196F3))),
    );
  }

  // Widget ย่อย: จัดเรียงข้อความ "หัวข้อสีฟ้า" ไว้บน "รายละเอียดสีดำ"
  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
          const SizedBox(height: 4),
          // ถ้าไม่ได้พิมพ์รายละเอียดมา (ค่าว่าง) ให้ใส่เครื่องหมายขีด (-) แทน จะได้ไม่แหว่ง
          Text(value.isEmpty ? "-" : value),
        ],
      ),
    );
  }
}