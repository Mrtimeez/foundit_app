import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foundit/view/browse_screen.dart';
import 'package:foundit/view/my_posts_screen.dart';
import 'package:foundit/view/postdetail_screen.dart';
import 'package:foundit/view/report_screen.dart';
import 'package:foundit/view/postdetail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser;

  signout() async {
    await FirebaseAuth.instance.signOut();
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
          "Found it",
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _welcomeCard(),
            const SizedBox(height: 20),

            //ฉันทำของหาย
            GestureDetector(
              onTap: () {
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

            //พบของ
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

            //โพสของฉัน
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
//---------------------- ส่วนของการ์ด -------------------------------------
            _sectionTitle("รายการล่าสุด"),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              // ดึงโพสทั้งหมดจาก collection 'posts' เรียงจากใหม่ไปเก่า
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // ระหว่างรอโหลด
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ถ้าไม่มีโพสเลย
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

                // มีโพส → สร้าง GridView จากข้อมูลจริง
                final docs = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0, // ✅ เปลี่ยนเป็น 1.0 ให้ card เป็นสี่เหลี่ยมจตุรัส
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _itemCard(
                      context,
                      docId: docs[index].id,
                      title: data['title'] ?? "ไม่มีชื่อ",
                      desc: data['desc'] ?? "",
                      location: data['location'] ?? "",
                      phone: data['phone'] ?? "",
                      lineId: data['lineId'] ?? "",
                      imageUrl: data['imageUrl'],
                      time: _formatTime(data['createdAt']),
                      status: data['status'] ?? "รอการติดต่อ",
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


  Widget _welcomeCard() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      // ดึงข้อมูล realtime จาก Firestore ตาม UID ของ User ที่ Login อยู่
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // ค่า default ถ้ายังโหลดไม่เสร็จ
        String username = "ยินดีต้อนรับ";
        String? photoURL;

        // ถ้าโหลดข้อมูลสำเร็จให้ดึงมาใช้
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          username = data['username'] ?? "ยินดีต้อนรับ";
          photoURL = data['photoURL']; // URL รูปจาก Cloudinary
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // แสดงรูปจาก Cloudinary ถ้ามี ถ้าไม่มีแสดงไอคอน default
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFBBDEFB),
                backgroundImage: photoURL != null
                    ? NetworkImage(photoURL) // รูปจาก Cloudinary
                    : null,
                child: photoURL == null
                    ? const Icon(Icons.person, color: Color(0xFF1E88E5))
                    : null,
              ),
              const SizedBox(width: 12),
              // แสดงชื่อ User แทนข้อความ "ยินดีต้อนรับ" คงที่
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

  //ไปหน้า Detail

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
        String? imageUrl,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(
              docId: docId,
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ✅ รูปกินครึ่งบนของ card พอดี ใช้ Expanded แทน height คงที่
            Expanded(
              flex: 3, // รูปกิน 3 ส่วน
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14), // มุมโค้งแค่ด้านบน
                ),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover, // ครอบรูปให้เต็มพื้นที่สม่ำเสมอ
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image,
                        color: Color(0xFF2196F3), size: 40),
                  ),
                )
                    : Container(
                  color: const Color(0xFFE3F2FD),
                  child: const Center(
                    child: Icon(Icons.image,
                        color: Color(0xFF2196F3), size: 40),
                  ),
                ),
              ),
            ),

            // ✅ ข้อมูลด้านล่าง กิน 2 ส่วน
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      desc,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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

// แปลง Firestore Timestamp เป็นข้อความ เช่น "5 ชม. ที่แล้ว"
String _formatTime(dynamic timestamp) {
  if (timestamp == null) return "";

  final DateTime postTime = (timestamp as Timestamp).toDate();
  final Duration diff = DateTime.now().difference(postTime);

  if (diff.inMinutes < 60) {
    return "${diff.inMinutes} นาทีที่แล้ว";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} ชม. ที่แล้ว";
  } else {
    return "${diff.inDays} วันที่แล้ว";
  }
}

