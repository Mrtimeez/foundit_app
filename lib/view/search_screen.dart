import 'package:flutter/material.dart';               // import Flutter UI framework
import 'package:cloud_firestore/cloud_firestore.dart'; // import Firestore สำหรับดึงข้อมูล
import 'item_detail_screen.dart';                      // import หน้า PostDetailScreen สำหรับดูรายละเอียด

// SearchScreen เป็น StatefulWidget เพราะมีการเปลี่ยนแปลง UI (ค้นหา, filter)
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState(); // สร้าง State ของหน้านี้
}

class _SearchScreenState extends State<SearchScreen> {
  // Controller สำหรับรับค่าที่พิมพ์ในช่องค้นหา
  final TextEditingController _searchController = TextEditingController();

  // เก็บ keyword ที่ผู้ใช้พิมพ์ค้นหา (แปลงเป็นตัวเล็กหมดเพื่อค้นหาแบบ case-insensitive)
  String _keyword = "";

  // เก็บประเภท filter ที่เลือกอยู่ "all" = ทั้งหมด, "lost" = ของหาย, "found" = พบของ
  String _filterType = "all";

  // ฟังก์ชันแปลง Firestore Timestamp เป็นข้อความภาษาไทย เช่น "5 นาทีที่แล้ว"
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return ""; // ถ้าไม่มีเวลาให้คืนค่าว่าง
    final DateTime postTime = (timestamp as Timestamp).toDate(); // แปลง Timestamp เป็น DateTime
    final Duration diff = DateTime.now().difference(postTime);   // คำนวณเวลาที่ผ่านมา
    if (diff.inMinutes < 60) return "${diff.inMinutes} นาทีที่แล้ว"; // ถ้าน้อยกว่า 60 นาทีให้แสดงเป็นนาที
    if (diff.inHours < 24) return "${diff.inHours} ชม. ที่แล้ว";     // ถ้าน้อยกว่า 24 ชั่วโมงให้แสดงเป็นชั่วโมง
    return "${diff.inDays} วันที่แล้ว";                              // ถ้ามากกว่านั้นให้แสดงเป็นวัน
  }

  // ฟังก์ชันกำหนดสี Badge ตามสถานะของโพส
  Color _statusColor(String status) {
    switch (status) {
      case "พบของแล้ว":   // สถานะพบของแล้ว → สีเขียว
        return Colors.green;
      case "มีคนติดต่อ":  // สถานะมีคนติดต่อ → สีน้ำเงิน
        return Colors.blue;
      default:             // สถานะอื่นๆ (รอการติดต่อ, กำลังตามหา) → สีส้ม
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // คืน memory ของ Controller เมื่อออกจากหน้านี้
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // พื้นหลังสีฟ้าอ่อน
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3), // AppBar สีฟ้า
        elevation: 0,                             // ไม่มีเงาใต้ AppBar
        centerTitle: true,                        // ชื่อหน้าอยู่ตรงกลาง
        title: const Text(
          "ค้นหา",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // ตัวหนังสือสีขาวตัวหนา
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // ระยะห่างรอบ body ทุกด้าน 16px
        child: Column(
          children: [

            // ช่องค้นหา
            TextField(
              controller: _searchController,           // เชื่อมกับ Controller
              onChanged: (value) {
                // ทุกครั้งที่พิมพ์ให้อัปเดต keyword และ rebuild UI
                setState(() => _keyword = value.toLowerCase().trim());
              },
              decoration: InputDecoration(
                hintText: "ค้นหาของหาย หรือ ของที่พบ...", // ข้อความ placeholder
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)), // ไอคอนแว่นขยายด้านหน้า
                // ถ้ามี keyword อยู่ให้แสดงปุ่ม X ล้างคำค้นหา ถ้าไม่มีให้ซ่อน
                suffixIcon: _keyword.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey), // ไอคอน X สีเทา
                  onPressed: () {
                    _searchController.clear();        // ล้างข้อความในช่องค้นหา
                    setState(() => _keyword = "");    // ล้าง keyword และ rebuild UI
                  },
                )
                    : null,
                filled: true,                                          // ให้พื้นหลัง TextField มีสี
                fillColor: Colors.white,                               // พื้นหลังสีขาว
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),             // ขอบมน 30px
                  borderSide: BorderSide.none,                         // ไม่มีเส้นขอบ
                ),
              ),
            ),

            const SizedBox(height: 12), // ระยะห่าง 12px ระหว่างช่องค้นหาและ filter chips

            // แถว Filter Chips สำหรับกรองประเภทโพส
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // จัด chips ให้อยู่กึ่งกลาง
              children: [
                _filterChip("ทั้งหมด", "all"),  // chip ดูทั้งหมด
                const SizedBox(width: 8),         // ระยะห่างระหว่าง chip
                _filterChip("🔍 ของหาย", "lost"), // chip กรองเฉพาะของหาย
                const SizedBox(width: 8),          // ระยะห่างระหว่าง chip
                _filterChip("📦 พบของ", "found"), // chip กรองเฉพาะพบของ
              ],
            ),

            const SizedBox(height: 12), // ระยะห่าง 12px ระหว่าง filter chips และรายการ

            // ดึงโพสทั้งหมดจาก Firestore แบบ Realtime ใช้ Expanded เพื่อให้ ListView กินพื้นที่ที่เหลือ
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // ดึงข้อมูลจาก collection 'posts' เรียงจากใหม่ไปเก่า
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('createdAt', descending: true) // ใหม่สุดขึ้นก่อน
                    .snapshots(),                           // รับข้อมูล realtime
                builder: (context, snapshot) {

                  // ระหว่างรอโหลดข้อมูลให้แสดงวงกลมหมุน
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // ถ้าไม่มีข้อมูลหรือยังไม่มีโพสเลย
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "ยังไม่มีโพส",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  // กรองข้อมูลตาม filterType และ keyword
                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>; // แปลงข้อมูลเป็น Map
                    final title = (data['title'] ?? "").toLowerCase(); // ดึงชื่อ แปลงเป็นตัวเล็ก
                    final desc = (data['desc'] ?? "").toLowerCase();   // ดึงรายละเอียด แปลงเป็นตัวเล็ก
                    final String type = data['type'] ?? "lost";        // ดึงประเภทโพส ถ้าไม่มีให้ default เป็น lost

                    // ถ้าเลือก filter ไม่ใช่ "all" และ type ไม่ตรงกับที่เลือกให้ข้ามโพสนี้ไป
                    if (_filterType != "all" && type != _filterType) return false;

                    // ถ้าไม่ได้พิมพ์ keyword ให้แสดงทุกโพสที่ผ่าน filter type
                    if (_keyword.isEmpty) return true;

                    // ถ้ามี keyword ให้เช็คว่า title หรือ desc มีคำที่ค้นหาไหม
                    return title.contains(_keyword) || desc.contains(_keyword);
                  }).toList(); // แปลงผลลัพธ์เป็น List

                  // ถ้ากรองแล้วไม่มีผลลัพธ์
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "ไม่พบข้อมูล",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  // สร้าง ListView จากข้อมูลที่กรองแล้ว
                  return ListView.builder(
                    itemCount: docs.length, // จำนวน item ทั้งหมด
                    itemBuilder: (context, index) {
                      // ดึงข้อมูลจากแต่ละ document มาใส่ตัวแปร
                      final data = docs[index].data() as Map<String, dynamic>;

                      final String title    = data['title']    ?? "ไม่มีชื่อ";   // ชื่อสิ่งของ
                      final String desc     = data['desc']     ?? "";             // รายละเอียด
                      final String location = data['location'] ?? "";             // สถานที่
                      final String phone    = data['phone']    ?? "";             // เบอร์โทร
                      final String lineId   = data['lineId']   ?? "";             // Line ID
                      final String status   = data['status']   ?? "รอการติดต่อ"; // สถานะ
                      final String? imageUrl = data['imageUrl'];                  // URL รูปภาพ (อาจเป็น null)
                      final String time     = _formatTime(data['createdAt']);     // เวลาโพสแปลงเป็นข้อความ

                      // แต่ละ card กดได้เพื่อไปดูรายละเอียด
                      return InkWell(
                        onTap: () {
                          // เปิดหน้า PostDetailScreen พร้อมส่งข้อมูลโพสไป
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
                          margin: const EdgeInsets.only(bottom: 12),  // ระยะห่างด้านล่างแต่ละ card
                          padding: const EdgeInsets.all(14),           // padding ภายใน card
                          decoration: BoxDecoration(
                            color: Colors.white,                       // พื้นหลัง card สีขาว
                            borderRadius: BorderRadius.circular(16),   // มุมโค้ง 16px
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.06),  // เงาสีน้ำเงินโปร่งแสง
                                blurRadius: 6,                         // ความเบลอของเงา
                                offset: const Offset(0, 3),            // เงาอยู่ด้านล่าง 3px
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // รูปโพส: ถ้ามี URL แสดงรูปจริง ถ้าไม่มีแสดง placeholder
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12), // ตัดมุมรูปโค้ง 12px
                                child: imageUrl != null
                                    ? Image.network(
                                  imageUrl,                        // โหลดรูปจาก URL
                                  width: 60,                       // กว้าง 60px
                                  height: 60,                      // สูง 60px
                                  fit: BoxFit.cover,               // ครอบรูปให้เต็มพื้นที่
                                  errorBuilder: (_, __, ___) =>
                                      _placeholderIcon(),          // ถ้าโหลดรูปไม่ได้ให้แสดง placeholder
                                )
                                    : _placeholderIcon(), // ถ้าไม่มี URL ให้แสดง placeholder
                              ),
                              const SizedBox(width: 14), // ระยะห่างระหว่างรูปและข้อมูล

                              // ข้อมูลโพส ขยายเต็มพื้นที่ที่เหลือ
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // จัดข้อความชิดซ้าย
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(fontWeight: FontWeight.bold), // ชื่อสิ่งของตัวหนา
                                      maxLines: 1,                                          // แสดงแค่ 1 บรรทัด
                                      overflow: TextOverflow.ellipsis,                      // ถ้ายาวเกินให้ตัดเป็น ...
                                    ),
                                    Text(
                                      desc,
                                      style: const TextStyle(color: Colors.grey), // รายละเอียดสีเทา
                                      maxLines: 1,                                 // แสดงแค่ 1 บรรทัด
                                      overflow: TextOverflow.ellipsis,             // ถ้ายาวเกินให้ตัดเป็น ...
                                    ),
                                    const SizedBox(height: 6), // ระยะห่างก่อน Badge สถานะ

                                    // Badge แสดงสถานะโพส
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10, // padding ซ้ายขวา
                                        vertical: 4,    // padding บนล่าง
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(status).withOpacity(0.15), // สีพื้นหลัง Badge โปร่งแสง
                                        borderRadius: BorderRadius.circular(20),        // ขอบโค้งมน
                                      ),
                                      child: Text(
                                        status, // ข้อความสถานะ
                                        style: TextStyle(
                                          color: _statusColor(status),  // สีตัวหนังสือตามสถานะ
                                          fontSize: 12,                  // ขนาดตัวหนังสือ
                                          fontWeight: FontWeight.bold,   // ตัวหนา
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // เวลาโพสแสดงด้านขวาสุด
                              Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 11,        // ขนาดเล็ก
                                  color: Colors.grey,  // สีเทา
                                ),
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

  // Widget สร้าง Filter Chip แต่ละอัน
  Widget _filterChip(String label, String value) {
    final bool isSelected = _filterType == value; // เช็คว่า chip นี้ถูกเลือกอยู่ไหม

    return GestureDetector(
      onTap: () => setState(() => _filterType = value), // เมื่อกดให้เปลี่ยน filterType และ rebuild
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // padding ภายใน chip
        decoration: BoxDecoration(
          // ถ้าเลือกอยู่ให้พื้นหลังสีฟ้า ถ้าไม่เลือกให้สีขาว
          color: isSelected ? const Color(0xFF2196F3) : Colors.white,
          borderRadius: BorderRadius.circular(30), // ขอบโค้งมนเป็นแคปซูล
          border: Border.all(
            // ถ้าเลือกอยู่ให้เส้นขอบสีฟ้า ถ้าไม่เลือกให้สีเทาอ่อน
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label, // ข้อความบน chip เช่น "ทั้งหมด", "🔍 ของหาย"
          style: TextStyle(
            // ถ้าเลือกอยู่ให้ตัวหนังสือสีขาว ถ้าไม่เลือกให้สีเทา
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontSize: 13,
            // ถ้าเลือกอยู่ให้ตัวหนา ถ้าไม่เลือกให้ตัวปกติ
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Widget placeholder แสดงเมื่อโพสไม่มีรูปภาพ
  Widget _placeholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),      // พื้นหลังสีฟ้าอ่อนมาก
        borderRadius: BorderRadius.circular(12), // มุมโค้ง 12px
      ),
      child: const Icon(Icons.inventory, color: Color(0xFF2196F3)), // ไอคอนกล่องสีฟ้า
    );
  }
}