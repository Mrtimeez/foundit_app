import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'postdetail_screen.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  // แปลง Timestamp เป็นข้อความ
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";
    final DateTime postTime = (timestamp as Timestamp).toDate();
    final Duration diff = DateTime.now().difference(postTime);
    if (diff.inMinutes < 60) return "${diff.inMinutes} นาทีที่แล้ว";
    if (diff.inHours < 24) return "${diff.inHours} ชม. ที่แล้ว";
    return "${diff.inDays} วันที่แล้ว";
  }

  // กำหนดสีตาม status
  Color _statusColor(String status) {
    switch (status) {
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

  // Dialog ยืนยันลบโพส
  void _confirmDelete(BuildContext context, String docId, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ลบโพส"),
        content: Text("ต้องการลบ \"$title\" ใช่หรือไม่?"),
        actions: [
          // ปุ่มยกเลิก
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          // ปุ่มลบ → ลบ document จาก Firestore
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(docId)
                  .delete();
            },
            child: const Text("ลบ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ดึง UID ของ User ที่ Login อยู่
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "โพสของฉัน",
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ดึงเฉพาะโพสที่ uid ตรงกับ User ที่ Login อยู่
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: uid)          // กรองเฉพาะโพสของตัวเอง
            .orderBy('createdAt', descending: true) // ใหม่สุดขึ้นก่อน
            .snapshots(),
        builder: (context, snapshot) {

          // รอโหลดข้อมูล
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ถ้ายังไม่มีโพส
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "ยังไม่มีโพส",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // ดึงข้อมูลจากแต่ละ document
              final data = docs[index].data() as Map<String, dynamic>;
              final String docId = docs[index].id; // ID ของ document

              final String title    = data['title']    ?? "ไม่มีชื่อ";
              final String desc     = data['desc']     ?? "";
              final String location = data['location'] ?? "";
              final String phone    = data['phone']    ?? "";
              final String lineId   = data['lineId']   ?? "";
              final String status   = data['status']   ?? "รอการติดต่อ";
              final String? imageUrl = data['imageUrl'];
              final String time     = _formatTime(data['createdAt']);

              return GestureDetector(
                // กดเพื่อดูรายละเอียด
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(
                        docId: docId,       // ส่ง docId ไปให้แก้ไข/ลบได้
                        title: title,
                        desc: desc,
                        location: location,
                        phone: phone,
                        lineId: lineId,
                        time: time,
                        status: status,
                        imageUrl: imageUrl,
                      ),
                    ),
                  );
                },
                // กดค้างเพื่อลบโพส
                onLongPress: () => _confirmDelete(context, docId, title),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      // รูปโพส ถ้ามี URL แสดงรูปจริง ถ้าไม่มีแสดงไอคอน
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null
                            ? Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                            : _placeholder(),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ชื่อสิ่งของ
                            Text(
                              title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // รายละเอียด
                            Text(
                              desc,
                              style: const TextStyle(color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Badge สถานะ
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // เวลาโพส
                      Text(
                        time,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
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

  // Widget placeholder ตอนไม่มีรูป
  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image, color: Color(0xFF2196F3), size: 30),
    );
  }
}