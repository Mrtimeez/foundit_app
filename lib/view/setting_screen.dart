import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import หน้าต่างๆ ที่ต้องกดเชื่อมไปหา (เช็คชื่อไฟล์ของคุณให้ชัวร์นะครับ)
import 'package:foundit/authentication/login_screen.dart';
import 'edit_profile_screen.dart';
import 'terms_screen.dart';
import 'version_screen.dart';
import 'contact_us_screen.dart';
import 'support_center_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // --------------------------------------------------------------------------
  // ฟังก์ชันออกจากระบบ (Logout)
  // --------------------------------------------------------------------------
  void _signOut(BuildContext context) async {
    // 1. สั่ง Firebase ให้ Logout ตัดการเชื่อมต่อ
    await FirebaseAuth.instance.signOut();

    // 2. เด้งกลับไปหน้า Login พร้อมกับ "ล้างประวัติหน้าจอทั้งหมด"
    // (เพื่อป้องกันไม่ให้ผู้ใช้กดปุ่ม Back กลับมาหน้าแอปได้อีกหลังจากออกไปแล้ว)
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  // --------------------------------------------------------------------------
  // ส่วนสร้างหน้าจอหลัก (UI)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // สีพื้นหลังสบายตา

      // ปุ่มลอย (Floating Action Button) มุมขวาล่าง สำหรับกดออกจากระบบ
      floatingActionButton: FloatingActionButton(
        onPressed: () => _signOut(context),
        backgroundColor: const Color(0xFF2196F3),
        tooltip: 'ออกจากระบบ',
        child: const Icon(Icons.logout, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ----------------------------------------------------------------
            // โซน Header สีฟ้าด้านบน (รูปโปรไฟล์ + ชื่อ + อีเมล)
            // ----------------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 24, left: 16, right: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30), // ทำมุมโค้งด้านล่างให้ดูละมุน
                ),
              ),
              child: Column(
                children: [
                  // หัวข้อ "ข้อมูล"
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ข้อมูล",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ใช้ StreamBuilder เพื่อ "ดึงข้อมูลผู้ใช้แบบ Real-time"
                  // ถ้ามีการแก้ชื่อหรือเปลี่ยนรูปจากหน้าอื่น หน้านี้จะอัปเดตเองทันที!
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid) // ดึงเฉพาะข้อมูลของตัวเอง
                        .snapshots(),
                    builder: (context, snapshot) {

                      // ระหว่างรอโหลดข้อมูลจากเน็ต
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(color: Colors.white);
                      }

                      // เตรียมตัวแปรเริ่มต้น (เผื่อหาข้อมูลไม่เจอ)
                      String username = "User";
                      String email = FirebaseAuth.instance.currentUser?.email ?? "";
                      String? photoURL;

                      // ถ้ามีข้อมูลในฐานข้อมูล ให้เอามาเขียนทับตัวแปรด้านบน
                      if (snapshot.hasData && snapshot.data!.exists) {
                        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                        username = data['username'] ?? username;
                        photoURL = data['photoURL'];
                      }

                      return Column(
                        children: [
                          // กรอบรูปโปรไฟล์วงกลม
                          Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              // ถ้าระบบมีรูป -> โชว์รูป / ถ้าไม่มีรูป -> โชว์ไอคอนคน
                              child: photoURL != null
                                  ? Image.network(
                                photoURL!,
                                key: ValueKey(photoURL), // สำคัญมาก! ทำให้รูปอัปเดตทันทีถ้า URL เปลี่ยน
                                fit: BoxFit.cover,
                                // โชว์วงกลมโหลดระหว่างดึงรูปภาพ
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                // ถ้ารูปลิงก์พัง ให้โชว์ไอคอนคนแทน
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 50, color: Color(0xFF2196F3)),
                              )
                                  : const Icon(Icons.person, size: 50, color: Color(0xFF2196F3)),
                            ),
                          ),
                          const SizedBox(height: 12), // เพิ่มระยะห่างนิดนึงให้สวยงาม

                          // โชว์ชื่อ และ อีเมล
                          Text(
                            username,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            email,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 14),

                          // ปุ่มกดไปหน้า "แก้ไขข้อมูล"
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
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

            // ----------------------------------------------------------------
            // โซนเมนูย่อยด้านล่าง
            // เรียกใช้ฟังก์ชัน _menu() เพื่อสร้างปุ่มเรียงกันลงมา
            // ----------------------------------------------------------------
            _menu(context, Icons.description, "เงื่อนไขและข้อตกลง", const TermsScreen()),
            _menu(context, Icons.mail, "ติดต่อเรา", const ContactUsScreen()),
            _menu(context, Icons.support_agent, "ศูนย์ลูกค้าสัมพันธ์", const SupportCenterScreen()),
            _menu(context, Icons.info, "เวอร์ชั่น", const VersionScreen()),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // แม่พิมพ์สำหรับสร้าง "ปุ่มเมนู" แบบการ์ดสีขาว
  // --------------------------------------------------------------------------
  Widget _menu(BuildContext context, IconData icon, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF2196F3)), // ไอคอนหน้าข้อความ
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold, // ตัวหนา
              fontSize: 16,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16), // ลูกศรชี้ขวา
          onTap: () {
            // พอกดปุ๊บ ให้พาไปหน้าที่กำหนดไว้
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
        ),
      ),
    );
  }
}