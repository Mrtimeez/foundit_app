import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetailScreen extends StatefulWidget {
  final String docId;    // ✅ เพิ่ม ID ของ document สำหรับแก้ไข/ลบใน Firestore
  final String title;
  final String desc;
  final String location;
  final String status;
  final String phone;
  final String lineId;
  final String time;
  final String? imageUrl; // ✅ เพิ่ม URL รูปจาก Cloudinary

  const PostDetailScreen({
    super.key,
    required this.docId,
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
  late String status; // เก็บ status ปัจจุบัน

  @override
  void initState() {
    super.initState();
    status = widget.status; // ใช้ค่าเริ่มต้นจากที่ส่งมา
  }

  // กำหนดสีตาม status
  Color _statusColor(String s) {
    switch (s) {
      case "พบของแล้ว":
        return Colors.green;
      case "มีคนติดต่อ":
        return Colors.blue;
      case "คืนของแล้ว":
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  // เปิด Dialog เลือก status แล้วอัปเดตลง Firestore
  void _changeStatus() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เปลี่ยนสถานะ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusBtn("รอการติดต่อ"),
            _statusBtn("มีคนติดต่อ"),
            _statusBtn("พบของแล้ว"),
            _statusBtn("คืนของแล้ว"),
          ],
        ),
      ),
    );

    if (result != null) {
      // อัปเดต status ลง Firestore
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.docId)
          .update({'status': result});

      // อัปเดต UI ด้วย
      setState(() => status = result);
    }
  }

  // ปุ่มเลือก status ใน Dialog
  Widget _statusBtn(String s) {
    return ListTile(
      title: Text(s),
      leading: Icon(Icons.circle, size: 12, color: _statusColor(s)),
      onTap: () => Navigator.pop(context, s),
    );
  }

  // Dialog ยืนยันลบ แล้วลบจาก Firestore จริง
  void _deletePost() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: const Text("ต้องการลบโพสนี้ใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // ปิด Dialog
              // ลบ document จาก Firestore จริง
              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.docId)
                  .delete();
              if (mounted) Navigator.pop(context); // กลับหน้าก่อนหน้า
            },
            child: const Text("ลบโพส", style: TextStyle(color: Colors.white)),
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
        title: const Text("รายละเอียดโพส"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // รูปภาพโพส
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.imageUrl != null
                  ? Image.network(
                widget.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderImage(),
              )
                  : _placeholderImage(),
            ),
            const SizedBox(height: 16),

            // Card ข้อมูล
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
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

                  // Badge สถานะ
                  const Text("สถานะ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _statusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder ตอนไม่มีรูป
  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 64, color: Color(0xFF2196F3)),
      ),
    );
  }

  // แถวข้อมูลแต่ละบรรทัด
  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3))),
          const SizedBox(height: 4),
          Text(value.isEmpty ? "-" : value),
        ],
      ),
    );
  }
}