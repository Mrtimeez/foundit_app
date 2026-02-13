import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  File? _image;
  final picker = ImagePicker();

  final nameController =
  TextEditingController(text: "Sasi Tienpuek");

  final emailController =
  TextEditingController(text: "example@email.com");

  final oldPass = TextEditingController();
  final newPass = TextEditingController();

  Future pickImage() async {
    final picked =
    await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text("แก้ไขข้อมูล"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage:
                _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.camera_alt,
                    size: 40,
                    color: Color(0xFF2196F3))
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            _input("ชื่อผู้ใช้", nameController),
            const SizedBox(height: 16),

            _input("อีเมล", emailController),
            const SizedBox(height: 16),

            _input("รหัสผ่านเก่า", oldPass, isPass: true),
            const SizedBox(height: 16),

            _input("รหัสผ่านใหม่", newPass, isPass: true),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (oldPass.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("กรุณากรอกรหัสเก่าก่อน")),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("บันทึกข้อมูลสำเร็จ")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("บันทึก"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String label,
      TextEditingController controller,
      {bool isPass = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
