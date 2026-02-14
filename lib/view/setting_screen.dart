import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foundit/authentication/login_screen.dart';
import 'edit_profile_screen.dart';
import 'terms_screen.dart';
import 'version_screen.dart';
import 'contact_us_screen.dart';
import 'support_center_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ฟังก์ชันสำหรับ Logout
  void _signOut(BuildContext context) async {
    // 1. สั่ง Firebase ให้ Logout
    await FirebaseAuth.instance.signOut();

    // 2. เปลี่ยนหน้ากลับไป Login (และลบประวัติหน้าเก่าทิ้งเพื่อกันกด Back กลับมา)
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      body: SingleChildScrollView(
        child: Column(
          children: [

            //Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 60, bottom: 24, left: 16, right: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ข้อมูล",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  //--- ใช้ StreamBuilder ดึงข้อมูล ---
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(color: Colors.white);
                    }

                    String username = "User";
                    String email = FirebaseAuth.instance.currentUser?.email ?? "";
                    String? photoURL; // ✅ เพิ่มตัวแปรเก็บ URL รูป

                    if (snapshot.hasData && snapshot.data!.exists) {
                      Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                      username = data['username'] ?? username;
                      photoURL = data['photoURL']; // ✅ ดึง URL รูปจาก Firestore
                    }

                    return Column(
                      children: [
                        // ✅ แสดงรูปจาก Cloudinary ถ้ามี ถ้าไม่มีแสดงไอคอน default
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          backgroundImage: photoURL != null
                              ? NetworkImage(photoURL)  // รูปจาก Cloudinary URL
                              : null,
                          child: photoURL == null
                              ? const Icon(Icons.person, size: 50, color: Color(0xFF2196F3))
                              : null,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          username,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 14),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen()),
                            );
                          },
                          child: const Text("แก้ไขข้อมูล"),
                        ),
                      ],
                    );
                  },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _menu(context, Icons.description, "เงื่อนไขและข้อตกลง",
                const TermsScreen()),
            _menu(context, Icons.mail, "ติดต่อเรา",
                const ContactUsScreen()),
            _menu(context, Icons.support_agent, "ศูนย์ลูกค้าสัมพันธ์",
                const SupportCenterScreen()),
            _menu(context, Icons.info, "เวอร์ชั่น",
                const VersionScreen()),
          ],
        ),
      ),
// <--- 2. เพิ่มปุ่ม Floating Action Button ตรงนี้
      floatingActionButton: FloatingActionButton(
        onPressed: () => _signOut(context), // เรียกใช้ฟังก์ชัน Logout
        backgroundColor: const Color(0xFF2196F3), // สีฟ้า (theme เดียวกับแอป)
        child: const Icon(Icons.logout, color: Colors.white), // ไอคอน logout สีขาว
        tooltip: 'ออกจากระบบ',
      ),

    );
  }

  Widget _menu(BuildContext context, IconData icon,
      String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF2196F3)),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold, // ใส่คำสั่งนี้เพื่อให้ตัวหนา
                fontSize: 16, // (แถม) ปรับขนาดเพิ่มนิดหน่อยถ้าต้องการ
              ),
            ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => page));
          },
        ),
      ),
    );
  }
}
