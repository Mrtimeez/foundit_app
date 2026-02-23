import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Import หน้าจออื่นๆ ที่เกี่ยวข้อง (ตรวจสอบชื่อไฟล์ให้ตรงกับโปรเจคของคุณ)
import 'package:foundit/navigation_bar.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ตัวควบคุมช่องกรอกข้อมูล
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // คืนค่าหน่วยความจำเมื่อปิดหน้าจอ
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // 1. ฟังก์ชัน Login ด้วย Email & Password
  // --------------------------------------------------------------------------
  Future<void> signIn() async {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      navigator.pop();

    } on FirebaseAuthException catch (e) {
      navigator.pop(); // ปิดตอนเกิด Error Auth

      // จัดการ Error Message
      String message = "เกิดข้อผิดพลาด";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = "อีเมลหรือรหัสผ่านไม่ถูกต้อง";
      } else if (e.code == 'too-many-requests') {
        message = "ล็อกอินผิดบ่อยเกินไป โปรดรอสักครู่";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  // --------------------------------------------------------------------------
  // 2. ฟังก์ชัน Login ด้วย Google
  // --------------------------------------------------------------------------
  Future<void> signInWithGoogle() async {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // ให้เลือก Account ใหม่ทุกครั้ง

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        navigator.pop(); // ถ้ากดยกเลิก ก็ให้ปิดวงกลม
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // บันทึกข้อมูลลง Firestore ถ้าเป็นผู้ใช้ใหม่
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (!doc.exists) {
          await addUserDetails(
            uid,
            userCredential.user!.displayName ?? 'Google User',
            userCredential.user!.email ?? '',
            '',
          );
        }
      }

      navigator.pop();

    } catch (e) {
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Error: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  // --------------------------------------------------------------------------
  // 3. ส่วนประกอบหน้าจอ UI
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2EC4FF), Color(0xFF2196F3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text("Sign In", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),

                      // Email Field
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          hintText: "Email",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          hintText: "Password",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        ),
                      ),

                      // Forgot Password Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.orange)),
                        ),
                      ),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text("or sign in using"),
                      const SizedBox(height: 20),

                      // Google Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: signInWithGoogle, //เรียกใช้งาน function login google
                          icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                          label: const Text("Google", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDB4437),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.white)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                      child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 4. ฟังก์ชันบันทึกข้อมูล User ลง Firestore
// --------------------------------------------------------------------------
Future<void> addUserDetails(String uid, String username, String email, String phone) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'uid': uid,
    'username': username,
    'email': email,
    'phone': phone,
    'provider': 'google',
    'createdAt': FieldValue.serverTimestamp(),
  });
}