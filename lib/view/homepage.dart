import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foundit/view/browse_screen.dart';
import 'package:foundit/view/postdetail_screen.dart';
import 'package:foundit/view/report_screen.dart';

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

            _sectionTitle("รายการล่าสุด"),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
              children: [
                _itemCard(
                  context,
                  title: "กระเป๋าสตางค์",
                  desc: "สีดำ",
                  location: "อาคาร A ชั้น 1",
                  phone: "0812345678",
                  lineId: "wallet_line",
                  time: "5 ชม. ที่แล้ว",
                ),
                _itemCard(
                  context,
                  title: "โทรศัพท์",
                  desc: "iPhone",
                  location: "โรงอาหาร",
                  phone: "0899999999",
                  lineId: "iphone_line",
                  time: "3 ชม. ที่แล้ว",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFBBDEFB),
            child: Icon(Icons.person, color: Color(0xFF1E88E5)),
          ),
          SizedBox(width: 12),
          Text(
            "ยินดีต้อนรับ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
        required String title,
        required String desc,
        required String location,
        required String phone,
        required String lineId,
        required String time,
      }) {
    return GestureDetector(
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
              status: "กำลังตามหาเจ้าของ",
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.image,
                    color: Color(0xFF2196F3), size: 40),
              ),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(desc,
                style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Text(time,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

