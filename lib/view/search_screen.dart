import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // เก็บ keyword ที่ค้นหาอยู่
  String _keyword = "";

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
      default:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ค้นหา",
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ช่องค้นหา
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // อัปเดต keyword แล้ว rebuild เพื่อ filter ใหม่
                setState(() => _keyword = value.toLowerCase().trim());
              },
              decoration: InputDecoration(
                hintText: "ค้นหาของหาย หรือ ของที่พบ...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
                suffixIcon: _keyword.isNotEmpty
                    ? IconButton(
                  // ปุ่ม X ล้างคำค้นหา
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _keyword = "");
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ดึงโพสทั้งหมดจาก Firestore แบบ Realtime
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('createdAt', descending: true) // ใหม่สุดขึ้นก่อน
                    .snapshots(),
                builder: (context, snapshot) {

                  // รอโหลดข้อมูล
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // ถ้าไม่มีโพสเลย
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("ยังไม่มีโพส",
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  // Filter ตาม keyword ที่พิมพ์ (title หรือ desc)
                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = (data['title'] ?? "").toLowerCase();
                    final desc = (data['desc'] ?? "").toLowerCase();
                    // ถ้าไม่ได้พิมพ์อะไร → แสดงทั้งหมด
                    if (_keyword.isEmpty) return true;
                    return title.contains(_keyword) || desc.contains(_keyword);
                  }).toList();

                  // ไม่พบผลลัพธ์จากการค้นหา
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("ไม่พบข้อมูล",
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      // ดึงข้อมูลจากแต่ละ document
                      final data = docs[index].data() as Map<String, dynamic>;

                      final String title = data['title'] ?? "ไม่มีชื่อ";
                      final String desc = data['desc'] ?? "";
                      final String location = data['location'] ?? "";
                      final String phone = data['phone'] ?? "";
                      final String lineId = data['lineId'] ?? "";
                      final String status = data['status'] ?? "รอการติดต่อ";
                      final String? imageUrl = data['imageUrl'];
                      final String time = _formatTime(data['createdAt']);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(
                                title: title,
                                desc: desc,
                                location: location,
                                phone: phone,
                                lineId: lineId,
                                time: time,
                                status: status,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
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
                                  errorBuilder: (_, __, ___) =>
                                      _placeholderIcon(),
                                )
                                    : _placeholderIcon(),
                              ),

                              const SizedBox(width: 14),

                              // ข้อมูลโพส
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      desc,
                                      style:
                                      const TextStyle(color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),

                                    // Badge สถานะ
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(status)
                                            .withOpacity(0.15),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: _statusColor(status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
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
            ),
          ],
        ),
      ),
    );
  }

  // Widget placeholder ตอนไม่มีรูป
  Widget _placeholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.inventory, color: Color(0xFF2196F3)),
    );
  }
}