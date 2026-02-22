import 'package:flutter/material.dart'; // นำเข้าไลบรารีพื้นฐานของ Flutter สำหรับสร้าง UI
import 'package:firebase_auth/firebase_auth.dart'; // นำเข้าไลบรารีของ Firebase สำหรับจัดการระบบสมาชิก (Authentication)
// นำเข้าหน้าจอต่างๆ ภายในแอปพลิเคชัน เพื่อใช้สำหรับการเปลี่ยนหน้า (Navigation)
import 'package:foundit/view/browse_screen.dart';
import 'package:foundit/view/my_posts_screen.dart';
import 'package:foundit/view/postdetail_screen.dart';
import 'package:foundit/view/report_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';// นำเข้าไลบรารีจัดการฐานข้อมูล (Firestore) เพื่อดึงข้อมูลโพสต์และผู้ใช้งาน

// คลาส Homepage เป็นหน้าจอหลักของแอป ใช้ StatefulWidget เพราะข้อมูลในหน้าอาจมีการเปลี่ยนแปลง
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // สร้างตัวแปร user เพื่อเก็บข้อมูลของผู้ใช้งานที่กำลังเข้าสู่ระบบอยู่ ณ ปัจจุบัน
  // จะใช้ตัวแปรนี้เพื่อตรวจสอบ UID ว่าใครคือผู้ใช้งานปัจจุบัน
  final user = FirebaseAuth.instance.currentUser;

  // ฟังก์ชันสำหรับออกจากระบบ
  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  // ฟังก์ชันแปลงข้อความสถานะให้เป็นสี (Color) เพื่อนำไปแสดงผลบน Badge
  // การแยกเป็นฟังก์ชันทำให้โค้ดเป็นระเบียบและเรียกใช้ซ้ำได้ง่าย
  Color _statusColor(String status) {
    switch (status) {
    // กลุ่มสถานะของโพสต์ประเภท "พบของ" (found)
      case "กำลังตามหาเจ้าของ":
        return Colors.blue;
      case "มีคนติดต่อ":
        return Colors.purple;
      case "คืนของแล้ว":
        return Colors.grey;

    // กลุ่มสถานะของโพสต์ประเภท "ของหาย" (lost)
      case "กำลังตามหา":
        return Colors.orange;
      case "พบของแล้ว":
        return Colors.green;

    // สีเริ่มต้นกรณีที่ข้อมูลในฐานข้อมูลไม่ตรงกับเงื่อนไขใดเลย
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold เปรียบเสมือนโครงสร้างหลักของหน้าจอ
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // กำหนดสีพื้นหลังหลักของหน้าแอป

      // ส่วนหัวของแอป (AppBar)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // ปิดเงาใต้แถบ AppBar ให้กลืนไปกับพื้นหลัง
        centerTitle: true,
        title: const Text(
          "Found it",
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // SingleChildScrollView ช่วยให้หน้าจอสามารถเลื่อนขึ้นลงได้ กรณีที่เนื้อหายาวเกินขอบเขตหน้าจอ
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ส่วนที่ 1: การ์ดต้อนรับ (แสดงรูปโปรไฟล์และชื่อผู้ใช้งาน)
            _welcomeCard(),
            const SizedBox(height: 20), // เพิ่มระยะห่างระหว่างองค์ประกอบ

            // ส่วนที่ 2: ปุ่มเมนูหลักของแอป
            // ใช้ GestureDetector เพื่อดักจับเหตุการณ์การกด (onTap) ของผู้ใช้
            GestureDetector(
              onTap: () {
                // คำสั่ง Navigator.push ใช้สำหรับเปลี่ยนหน้าไปยัง ReportScreen (แจ้งของหาย)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportScreen(),
                  ),
                );
              },
              child: _actionCard(
                icon: Icons.sentiment_dissatisfied,
                title: "ฉันทำของหาย",
                subtitle: "แจ้งของหายเพื่อให้คนช่วยหา",
                color: const Color(0xFF42A5F5),
              ),
            ),
            const SizedBox(height: 14),

            // ปุ่มเมนู: ฉันพบของ
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BrowseScreen(),
                  ),
                );
              },
              child: _actionCard(
                icon: Icons.campaign,
                title: "ฉันพบของ",
                subtitle: "แจ้งของที่พบเพื่อคืนเจ้าของ",
                color: const Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(height: 30),

            // ปุ่มเมนู: โพสต์ของฉัน
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyPostsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "โพสของฉัน",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ส่วนที่ 3: แสดงรายการโพสต์ล่าสุดจากผู้ใช้ทุกคน
            _sectionTitle("รายการล่าสุด"),
            const SizedBox(height: 16),

            // ใช้ StreamBuilder เพื่อดึงข้อมูลจาก Firestore แบบ Realtime (ถ้ามีคนโพสต์ใหม่ หน้าจอนี้จะอัปเดตเองทันที)
            StreamBuilder<QuerySnapshot>(
              // สั่งดึงข้อมูลจาก Collection 'posts' โดยเรียงลำดับจากเวลาที่สร้าง (createdAt) จากใหม่ไปเก่า (descending: true)
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // ตรวจสอบสถานะการดึงข้อมูล: ถ้าระบบกำลังเชื่อมต่อหรือดึงข้อมูล ให้แสดงวงกลมโหลด
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ตรวจสอบข้อมูล: ถ้าดึงข้อมูลสำเร็จแต่ไม่มีข้อมูลเลย (หรือไม่มี Collection นี้) ให้แสดงข้อความแจ้งเตือน
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        "ยังไม่มีรายการ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                // หากมีข้อมูล นำเอกสาร (documents) ทั้งหมดมาเก็บไว้ในตัวแปร docs
                final docs = snapshot.data!.docs;

                // สร้าง GridView เพื่อแสดงโพสต์เป็นตาราง
                return GridView.builder(
                  shrinkWrap: true, // ตั้งค่าเป็น true เพื่อให้ GridView ใช้พื้นที่เท่าที่จำเป็น (ใช้คู่กับ SingleChildScrollView ด้านนอก)
                  physics: const NeverScrollableScrollPhysics(), // ปิดการเลื่อนของ GridView เพื่อป้องกันการขัดแย้งกับการเลื่อนของ SingleChildScrollView
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // กำหนดให้แสดง 2 คอลัมน์
                    crossAxisSpacing: 12, // ระยะห่างระหว่างคอลัมน์ (แนวนอน)
                    mainAxisSpacing: 12, // ระยะห่างระหว่างแถว (แนวตั้ง)
                    childAspectRatio: 0.75, // อัตราส่วนความกว้างต่อความสูงของการ์ดแต่ละใบ (0.75 คือแนวตั้งยาวกว่าแนวนอนเล็กน้อย)
                  ),
                  itemCount: docs.length, // จำนวนการ์ดที่จะสร้าง เท่ากับจำนวนโพสต์ที่ดึงมาได้
                  itemBuilder: (context, index) {
                    // แปลงข้อมูลแต่ละ document ให้เป็น Map (key-value) เพื่อให้อ่านค่าได้ง่าย
                    final data = docs[index].data() as Map<String, dynamic>;

                    // ส่งข้อมูลที่ได้ไปยังฟังก์ชัน _itemCard เพื่อวาด UI ของการ์ดแต่ละใบ
                    return _itemCard(
                      context,
                      docId: docs[index].id, // ใช้ ID ของเอกสารอ้างอิงสำหรับการแก้ไขหรือลบ
                      title: data['title'] ?? "ไม่มีชื่อ", // ถ้าไม่มีคีย์นี้ ให้ใช้ค่าเริ่มต้น "ไม่มีชื่อ"
                      desc: data['desc'] ?? "",
                      location: data['location'] ?? "",
                      phone: data['phone'] ?? "",
                      lineId: data['lineId'] ?? "",
                      imageUrl: data['imageUrl'],
                      time: _formatTime(data['createdAt']), // แปลงเวลาจาก Timestamp เป็นข้อความที่อ่านง่าย
                      status: data['status'] ?? "รอการติดต่อ",
                      type: data['type'] ?? "lost",
                      postOwnerId: data['uid'], // ส่ง UID ของเจ้าของโพสต์ไปตรวจสอบสิทธิ์
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // ส่วนประกาศฟังก์ชันสำหรับการสร้าง UI ย่อย (Widgets)
  // ---------------------------------------------------------

  // ฟังก์ชันสร้างการ์ดแสดงรูปโปรไฟล์และชื่อผู้ใช้งาน
  Widget _welcomeCard() {
    final currentUser = FirebaseAuth.instance.currentUser;

    // ใช้ StreamBuilder ดึงข้อมูลตาราง 'users' เฉพาะของผู้ใช้งานคนนี้
    // เพื่อให้เวลาผู้ใช้เปลี่ยนรูปหรือเปลี่ยนชื่อ ข้อมูลในหน้าโฮมจะเปลี่ยนตามทันที
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String username = "ยินดีต้อนรับ";
        String? photoURL;

        // ตรวจสอบว่ามีข้อมูลและข้อมูลนั้นมีอยู่จริง
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          username = data['username'] ?? "ยินดีต้อนรับ";
          photoURL = data['photoURL'];
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // สร้างวงกลมสำหรับใส่รูปโปรไฟล์
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                // ClipOval ทำหน้าที่ตัดรูปสี่เหลี่ยมให้กลายเป็นวงกลม
                child: ClipOval(
                  child: photoURL != null
                      ? Image.network(
                    photoURL!,
                    key: ValueKey(photoURL), // บังคับให้ Flutter โหลดรูปใหม่ทุกครั้งที่ URL รูปมีการเปลี่ยนแปลง
                    fit: BoxFit.cover, // ปรับให้รูปขยายเต็มพื้นที่วงกลม
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 50, color: Color(0xFF2196F3)),
                  )
                      : const Icon(Icons.person, size: 50, color: Color(0xFF2196F3)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "ยินดีต้อนรับ, $username",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  // ฟังก์ชันสร้าง UI สำหรับปุ่มเมนูหลัก (เช่น ทำของหาย, พบของ)
  // รับค่าเป็น Parameter เพื่อนำไปใช้ซ้ำได้โดยไม่ต้องเขียนโค้ดใหม่
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสร้างข้อความหัวข้อหมวดหมู่
  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างการ์ดของแต่ละโพสต์สำหรับนำไปใส่ใน GridView
  Widget _itemCard(
      BuildContext context, {
        required String docId,
        required String title,
        required String desc,
        required String location,
        required String phone,
        required String lineId,
        required String time,
        required String status,
        required String type,
        String? imageUrl,
        String? postOwnerId,
      }) {
    return GestureDetector(
      onTap: () {
        // ดึง UID ของคนที่กำลังใช้งานแอปอยู่ตอนนี้
        final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

        // ตรวจสอบว่าคนที่ใช้งานอยู่คือเจ้าของโพสต์นี้หรือไม่ (นำ UID ปัจจุบัน มาเทียบกับ UID ที่บันทึกไว้ในโพสต์)
        final bool isOwner = currentUid == postOwnerId;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isOwner
            // กรณีที่ 1: เป็นเจ้าของโพสต์
            // ส่ง docId ไปที่หน้า PostDetailScreen ด้วย เพื่อให้ระบบรู้ว่าสามารถแสดงปุ่ม "แก้ไข/ลบ" ได้
                ? PostDetailScreen(
              docId: docId,
              title: title,
              desc: desc,
              location: location,
              phone: phone,
              lineId: lineId,
              time: time,
              status: status,
              imageUrl: imageUrl,
            )
            // กรณีที่ 2: ไม่ใช่เจ้าของโพสต์
            // ไม่ส่ง docId ไป เพื่อป้องกันไม่ให้ผู้ใช้ลบหรือแก้ไขข้อมูลของคนอื่น
                : PostDetailScreen(
              title: title,
              desc: desc,
              location: location,
              phone: phone,
              lineId: lineId,
              time: time,
              status: status,
              imageUrl: imageUrl, // สำคัญ: ต้องส่ง imageUrl ไปด้วยเพื่อให้รูปแสดงเมื่อคลิกเข้าไปดูรายละเอียด
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        // ใช้ Column เพื่อแบ่งพื้นที่การ์ดบน-ล่าง
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนบน: รูปภาพของโพสต์ (ใช้ Expanded เพื่อให้รูปภาพกินพื้นที่ 3 ส่วนจาก 5 ส่วน)
            Expanded(
              flex: 3,
              child: ClipRRect(
                // ทำมุมโค้งเฉพาะด้านบนซ้ายและขวาของการ์ด
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover, // ให้รูปภาพขยายเต็มพื้นที่โดยไม่ผิดสัดส่วน (อาจโดนตัดขอบบางส่วน)
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image,
                        color: Color(0xFF2196F3), size: 40),
                  ),
                )
                // กรณีที่ไม่มีรูปให้แสดงไอคอนแทน
                    : Container(
                  color: const Color(0xFFE3F2FD),
                  child: const Center(
                    child: Icon(Icons.image,
                        color: Color(0xFF2196F3), size: 40),
                  ),
                ),
              ),
            ),

            // ส่วนล่าง: รายละเอียดข้อความ (ใช้ Expanded เพื่อให้ข้อความกินพื้นที่ 2 ส่วนจาก 5 ส่วน)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // กระจายระยะห่างของข้อความบนสุดและล่างสุดให้พอดีพื้นที่
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1, // บังคับให้แสดงข้อความแค่บรรทัดเดียว
                      overflow: TextOverflow.ellipsis, // ถ้าข้อความยาวเกินให้ตัดแล้วใส่จุดไข่ปลา (...)
                    ),
                    Text(
                      desc,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // แถวสำหรับแสดงป้ายกำกับ (Badge) ประเภทและสถานะ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ป้ายแสดงประเภทโพสต์ (ของหาย หรือ พบของ)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: type == 'lost'
                                ? Colors.red.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type == 'lost' ? "ของหาย" : "พบของ",
                            style: TextStyle(
                              color: type == 'lost' ? Colors.red : Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ป้ายแสดงสถานะปัจจุบัน โดยสีของป้ายจะดึงมาจากฟังก์ชัน _statusColor
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            // ตั้งค่าสีพื้นหลังป้ายให้เป็นสีใส 15% (withOpacity)
                            color: _statusColor(status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ข้อความแสดงเวลาที่โพสต์อยู่ล่างสุด
                    Text(
                      time,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ส่วนของฟังก์ชันตัวช่วย (Helper Function) ที่อยู่นอกคลาสหลัก
// ---------------------------------------------------------

// ฟังก์ชันสำหรับแปลงเวลาจากระบบฐานข้อมูล (Timestamp) ให้เป็นข้อความที่ผู้ใช้อ่านเข้าใจได้
String _formatTime(dynamic timestamp) {
  // ตรวจสอบความปลอดภัย หากไม่ได้ส่งเวลามาให้คืนค่าเป็นช่องว่าง
  if (timestamp == null) return "";

  // แปลงชนิดข้อมูลจาก Timestamp (ของ Firebase) ให้เป็น DateTime (ของ Dart)
  final DateTime postTime = (timestamp as Timestamp).toDate();

  // คำนวณหาความแตกต่างระหว่างเวลาปัจจุบัน กับ เวลาที่โพสต์
  final Duration diff = DateTime.now().difference(postTime);

  // แสดงผลลัพธ์ตามช่วงเวลา
  if (diff.inMinutes < 60) {
    return "${diff.inMinutes} นาทีที่แล้ว";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} ชม. ที่แล้ว";
  } else {
    return "${diff.inDays} วันที่แล้ว";
  }
}