import 'package:flutter/material.dart';
import 'package:foundit/navigation_bar.dart';
import 'forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State {
  // Controller สำหรับรับค่า Email ที่ผู้ใช้พิมพ์
  TextEditingController email = TextEditingController();
  // Controller สำหรับรับค่า Password ที่ผู้ใช้พิมพ์
  TextEditingController password = TextEditingController();

  // ฟังก์ชันสำหรับ Login ด้วย Email และ Password
  signIn() async {
    // แสดง Loading dialog ระหว่างรอผลจาก Firebase
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // พยายาม Login ด้วย Email และ Password ที่ผู้ใช้กรอก
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),       // trim() เพื่อตัด space หน้า-หลัง
        password: password.text.trim(), // trim() เพื่อตัด space หน้า-หลัง
      );

      // ปิด Loading dialog เมื่อ Login สำเร็จ
      if (mounted) Navigator.pop(context);

      print("Login Success!");

      // นำทางไปหน้า MainNavigation และลบหน้า Login ออกจาก stack
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // ปิด Loading dialog เมื่อเกิด Error
      if (mounted) Navigator.pop(context);

      // พิมพ์ Error Code และ Message ออกมาใน Console เพื่อ Debug
      print("Firebase Error Code: ${e.code}");
      print("Firebase Message: ${e.message}");

      // กำหนดข้อความ Error เริ่มต้น
      String message = "เกิดข้อผิดพลาด";

      // เช็ค Error Code แล้วกำหนดข้อความให้เหมาะสม
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        // Email หรือ Password ไม่ถูกต้อง
        message = "อีเมลหรือรหัสผ่านไม่ถูกต้อง";
      } else if (e.code == 'invalid-email') {
        // รูปแบบ Email ไม่ถูกต้อง เช่น ไม่มี @
        message = "รูปแบบอีเมลไม่ถูกต้อง";
      } else if (e.code == 'too-many-requests') {
        // Login ผิดบ่อยเกินไป Firebase จะ block ชั่วคราว
        message = "ล็อกอินผิดบ่อยเกินไป โปรดรอสักครู่";
      } else {
        // กรณีอื่นๆ ให้แสดงข้อความจาก Firebase โดยตรง
        message = e.message ?? "เกิดข้อผิดพลาด";
      }

      // แสดง SnackBar แจ้ง Error ให้ผู้ใช้ทราบ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                // ไอคอน Error สีขาว
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                // ข้อความ Error (Expanded เพื่อป้องกัน overflow)
                Expanded(child: Text(message)),
              ],
            ),
            // พื้นหลังสีแดง
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ฟังก์ชันสำหรับ Login ด้วย Google Account
  signInWithGoogle() async {
    // แสดง Loading dialog ระหว่างรอผลจาก Google
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // สร้าง instance ของ GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Sign out ก่อนทุกครั้ง เพื่อให้ Google แสดง account picker
      await googleSignIn.signOut();

      // เปิดหน้าต่างให้ผู้ใช้เลือก Google Account
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // ถ้าผู้ใช้กดยกเลิก ให้ปิด Loading แล้วหยุดทำงาน
      if (googleUser == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      // ดึง Token จาก Google Account ที่เลือก
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // สร้าง Firebase Credential จาก Token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login เข้า Firebase Auth
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // เช็คว่า Login สำเร็จและมี UID
      if (userCredential.user != null) {
        final String uid = userCredential.user!.uid;
        final String email = userCredential.user!.email ?? '';
        final String displayName = userCredential.user!.displayName ?? 'Google User';

        // เช็คว่ามีข้อมูลใน Firestore แล้วหรือยัง
        // ถ้า Login ซ้ำจะได้ไม่ทับข้อมูลเดิม
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (!docSnapshot.exists) {
          // ถ้ายังไม่มี → สร้างใหม่โดยเรียก addUserDetails() เหมือน Signup
          await addUserDetails(
            uid,
            displayName, // username ใช้ชื่อจาก Google
            email,       // email จาก Google
            '',          // phone ว่างไว้ก่อน
          );
          print("สร้าง User ใหม่ใน Firestore สำเร็จ");
        } else {
          print("User มีอยู่แล้ว ไม่ต้องสร้างใหม่");
        }
      }

      // ปิด Loading dialog
      if (mounted) Navigator.pop(context);

      // นำทางไปหน้า MainNavigation และลบหน้า Login ออกจาก stack
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } catch (e) {
      // ปิด Loading dialog เมื่อเกิด Error
      if (mounted) Navigator.pop(context);

      print("Google Sign In Error: $e");

      // แสดง SnackBar แจ้ง Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เข้าสู่ระบบด้วย Google ไม่สำเร็จ: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,  // ขยายเต็มความกว้างหน้าจอ
        height: double.infinity, // ขยายเต็มความสูงหน้าจอ
        decoration: const BoxDecoration(
          // ไล่สีพื้นหลังจากบนลงล่าง
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2EC4FF), // สีฟ้าอ่อนด้านบน
              Color(0xFF2196F3), // สีฟ้าเข้มด้านล่าง
            ],
          ),
        ),
        child: SafeArea(
          // SafeArea ป้องกัน content ถูก notch หรือ status bar บัง
          child: SingleChildScrollView(
            // SingleChildScrollView รองรับกรณี keyboard popup แล้ว content ล้น
            child: Column(
              children: [
                const SizedBox(height: 60), // ระยะห่างด้านบน

                /// ---------- Card หลัก ----------
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24), // margin ซ้าย-ขวา
                  padding: const EdgeInsets.all(24),                  // padding ภายใน
                  decoration: BoxDecoration(
                    color: Colors.white,                              // พื้นหลังสีขาว
                    borderRadius: BorderRadius.circular(24),          // มุมโค้ง
                  ),
                  child: Column(
                    children: [
                      // หัวข้อ Sign In
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      /// ช่องกรอก Email
                      TextField(
                        controller: email, // เชื่อมกับ controller เพื่อดึงค่า
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email), // ไอคอนด้านหน้า
                          hintText: "Email",
                          filled: true,
                          fillColor: Colors.grey.shade100,     // พื้นหลังสีเทาอ่อน
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30), // มุมโค้ง
                            borderSide: BorderSide.none,             // ไม่มีเส้นขอบ
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// ช่องกรอก Password
                      TextField(
                        controller: password, // เชื่อมกับ controller เพื่อดึงค่า
                        obscureText: true,    // ซ่อนตัวอักษร (แสดงเป็น ***)
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock), // ไอคอนด้านหน้า
                          hintText: "Password",
                          filled: true,
                          fillColor: Colors.grey.shade100,    // พื้นหลังสีเทาอ่อน
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30), // มุมโค้ง
                            borderSide: BorderSide.none,             // ไม่มีเส้นขอบ
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      /// ปุ่ม Forgot Password ชิดขวา
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // นำทางไปหน้า ForgotPasswordScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      /// ปุ่ม Sign In หลัก
                      SizedBox(
                        width: double.infinity, // ขยายเต็มความกว้าง
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (() => signIn()), // เรียกฟังก์ชัน signIn()
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3), // สีฟ้า
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // มุมโค้ง
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ข้อความ or sign in using
                      const Text("or sign in using"),
                      const SizedBox(height: 16),

                      /// ปุ่ม Social Login ( Google)
                      Row(
                        children: [
                          /// ปุ่ม Google Login
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                signInWithGoogle(); // เรียกฟังก์ชัน signInWithGoogle()
                              },
                              icon: const Icon(
                                Icons.g_mobiledata,
                                color: Colors.white,
                                size: 28,
                              ),
                              label: const Text(
                                "Google",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFFDB4437), // สีแดง Google
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                /// ปุ่ม Sign Up สำหรับผู้ที่ยังไม่มีบัญชี
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ข้อความ Don't have an account?
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        // นำทางไปหน้า Signup และแทนที่หน้า Login ใน stack
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // ระยะห่างด้านล่าง
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// เอาไว้ใช้สำหรับเก็บ login google ไปลงใน DB
Future<void> addUserDetails(
    String uid,
    String username,
    String email,
    String phone,
    ) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'uid': uid,
    'username': username,
    'email': email,
    'phone': phone,
    'provider': 'google',
    'createdAt': FieldValue.serverTimestamp(),
  });
}