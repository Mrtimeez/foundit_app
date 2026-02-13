import 'package:flutter/material.dart';
import 'package:foundit/view/Homepage.dart';
import 'package:foundit/view/search_screen.dart';
import 'package:foundit/view/setting_screen.dart';


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Homepage(),
    const SearchScreen(),
    const SettingsScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2196F3),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
