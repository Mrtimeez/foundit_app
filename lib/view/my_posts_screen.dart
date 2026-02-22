import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'postdetail_screen.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  // --------------------------------------------------------------------------
  // ฟังก์ชันแปลงเวลา (Time Ago)
  // แปลงจากเวลาที่โพส (Timestamp) ให้เป็นข้อความอ่านง่ายๆ เช่น "5 นาทีที่แล้ว"
  // --------------------------------------------------------------------------
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";
    final DateTime postTime = (timestamp as Timestamp).toDate(); // แปลงเป็นวันที่
    final Duration diff = DateTime.now().difference(postTime);   // หาความห่างของเวลา

    if (diff.inMinutes < 60) return "${diff.inMinutes} นาทีที่แล้ว";
    if (diff.inHours < 24) return "${diff.inHours} ชม. ที่แล้ว";
    return "${diff.inDays} วันที่แล้ว";
  }

  // --------------------------------------------------------------------------
  // ฟังก์ชันเปลี่ยนสีป้ายสถานะ (เหมือนหน้า Detail เลย)
  // --------------------------------------------------------------------------
  Color _statusColor(String status) {
    switch (status) {
      case "พบของแล้ว": return Colors.green;
      case "มีคนติดต่อ": return Colors.blue;
      case "คืนของแล้ว": return Colors.grey;
      default: return Colors.orange;
    }
  }

  // --------------------------------------------------------------------------
  // ฟังก์ชัน "ยืนยันการลบโพส"
  // เด้งหน้าต่างขึ้นมาถามก่อนลบ ป้องกันผู้ใช้มือลั่น
  // --------------------------------------------------------------------------
  void _confirmDelete(BuildContext context, String docId, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ลบโพส"),
        content: Text("ต้องการลบ \"$title\" ใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // กดยกเลิก ก็แค่ปิดหน้าต่าง
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // ปิดหน้าต่างก่อน
              // สั่งลบข้อมูลออกจาก Firestore โดยใช้ ID ของโพสนั้นๆ
              await FirebaseFirestore.instance.collection('posts').doc(docId).delete();
            },
            child: const Text("ลบ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ส่วนแสดงผลหน้าจอ (UI)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // ดึงรหัสประจำตัว (UID) ของคนที่กำลังใช้งานแอปอยู่ตอนนี้
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // สีพื้นหลัง
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("โพสของฉัน", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
      ),

      // ดึงข้อมูลจากฐานข้อมูลแบบ Real-time (ถ้ามีการลบ/เพิ่ม มันจะอัปเดตเองทันที)
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: uid) // กรอง: เอาเฉพาะโพสที่มี uid ตรงกับตัวเรา
            .orderBy('createdAt', descending: true) // เรียง: เอาโพสใหม่สุดขึ้นก่อน
            .snapshots(),
        builder: (context, snapshot) {

          // ระหว่างรอโหลดข้อมูล ให้โชว์วงกลมหมุนๆ
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ถ้าไม่มีข้อมูล หรือไม่มีโพสเลย ให้โชว์หน้าว่างๆ สวยๆ
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("ยังไม่มีโพส", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs; // เก็บรายการโพสทั้งหมดไว้ในตัวแปร docs

          // สร้างรายการ List ของโพส (ไถขึ้นลงได้)
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length, // จำนวนรอบที่ต้องสร้าง = จำนวนโพสที่มี
            itemBuilder: (context, index) {

              // ดึงข้อมูลแต่ละกล่องออกมา
              final data = docs[index].data() as Map<String, dynamic>;
              final String docId = docs[index].id; // รหัสอ้างอิงของโพส (เอาไว้ใช้ตอนลบ/แก้ไข)

              // เตรียมข้อมูล (ใช้ ?? ป้องกันกรณีบางค่าไม่มีในฐานข้อมูล จะได้ไม่ Error)
              final String title    = data['title']    ?? "ไม่มีชื่อ";
              final String desc     = data['desc']     ?? "";
              final String location = data['location'] ?? "";
              final String phone    = data['phone']    ?? "";
              final String lineId   = data['lineId']   ?? "";
              final String status   = data['status']   ?? "รอการติดต่อ";
              final String? imageUrl = data['imageUrl'];
              final String time     = _formatTime(data['createdAt']);

              // ปุ่มที่กดได้ทั้งแบบ "แตะ" และ "กดค้าง"
              return GestureDetector(
                // แตะ 1 ครั้ง: เปิดหน้า Detail พร้อมส่งข้อมูลข้ามหน้าไปให้
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(
                        docId: docId, // ส่ง ID ไปด้วย เผื่อในหน้า Detail มีปุ่มลบ/แก้ไขอีก
                        title: title,
                        desc: desc,
                        location: location,
                        phone: phone,
                        lineId: lineId,
                        time: time,
                        status: status,
                        imageUrl: imageUrl, // ของเดิมไม่มีบรรทัดนี้นะ แต่คุณมีใน Constructor หน้าโน้น
                      ),
                    ),
                  );
                },
                // กดค้าง: เรียกฟังก์ชันยืนยันการลบ
                onLongPress: () => _confirmDelete(context, docId, title),

                // รูปแบบการ์ดของแต่ละโพส
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      // ส่วนของรูปภาพ ถ้ามีรูปก็โหลดจากเน็ต ถ้าไม่มีก็โชว์ไอคอน (placeholder)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null
                            ? Image.network(
                          imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(), // ถ้ารูปลิงก์เสีย โชว์ไอคอนแทน
                        )
                            : _placeholder(),
                      ),

                      const SizedBox(width: 14),

                      // ส่วนของข้อความตรงกลาง
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis), // ellipsis คือถ้าข้อความยาวไป ให้จุดๆๆ (...)
                            const SizedBox(height: 4),
                            Text(desc, style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            // ป้ายสถานะ
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                              child: Text(status, style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),

                      // เวลาโพส ชิดขวาสุด
                      Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // รูปภาพสำรอง (Placeholder)
  // โชว์ตอนที่โพสนั้นไม่ได้แนบรูปมา
  // --------------------------------------------------------------------------
  Widget _placeholder() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.image, color: Color(0xFF2196F3), size: 30),
    );
  }
}