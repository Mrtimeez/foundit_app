import 'package:flutter/material.dart';
import 'package:foundit/view/Homepage.dart';
import 'package:foundit/view/search_screen.dart';
import 'package:foundit/view/setting_screen.dart';

// หน้านี้ต้องเป็น StatefulWidget เพราะเราต้องมีการกดปุ่มแล้ว "เปลี่ยนหน้าจอ" (อัปเดต State)
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // --------------------------------------------------------------------------
  // ตัวแปรเก็บหน้าปัจจุบัน (เริ่มต้นที่ 0 คือหน้าแรก)
  // 0 = หน้าแรก, 1 = ค้นหา, 2 = ตั้งค่า
  // --------------------------------------------------------------------------
  int _currentIndex = 0;

  // --------------------------------------------------------------------------
  // กล่องเก็บหน้าจอทั้งหมด (เรียงตามลำดับ Index ด้านบน)
  // --------------------------------------------------------------------------
  final List<Widget> _pages = [
    const Homepage(),       // Index 0
    const SearchScreen(),   // Index 1
    const SettingsScreen(), // Index 2
  ];

  // --------------------------------------------------------------------------
  // ส่วนสร้างหน้าจอ (UI)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ตัว Body จะเปลี่ยนไปเรื่อยๆ ตามค่า _currentIndex ที่เรากดเลือก
      body: _pages[_currentIndex],

      // แถบเมนูด้านล่าง
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // บอกให้แถบเมนูรู้ว่าตอนนี้เราอยู่หน้าไหน (ปุ่มจะได้เป็นสีฟ้าถูกอัน)
        selectedItemColor: const Color(0xFF2196F3), // สีตอนกดเลือก (สีฟ้า)

        // ฟังก์ชันเมื่อมีการกดปุ่มที่แถบเมนู
        onTap: (index) {
          // สั่งรีเฟรชหน้าจอ (setState) แล้วเอาค่าตัวเลขปุ่มที่กด มาใส่แทนหน้าปัจจุบัน
          setState(() {
            _currentIndex = index;
          });
        },

        // รายการปุ่มทั้งหมด (ต้องเรียงลำดับให้ตรงกับตัวแปร _pages ด้านบนนะ)
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "หน้าแรก"),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "ค้นหา"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "ตั้งค่า"),
        ],
      ),
    );
  }
}