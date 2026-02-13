import 'package:flutter/material.dart';
import 'postdetail_screen.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {

  List<Map<String, String>> posts = [
    {
      "title": "กระเป๋าสตางค์",
      "desc": "สีดำ หายที่โรงอาหาร",
      "location": "โรงอาหาร",
      "status": "รอการติดต่อ",
      "phone": "0812345678",
      "lineId": "blackbag01",
    },
    {
      "title": "โทรศัพท์ iPhone",
      "desc": "หายหน้าอาคารเรียน",
      "location": "อาคาร A",
      "status": "มีคนติดต่อ",
      "phone": "0891112222",
      "lineId": "iphone_owner",
    },
    {
      "title": "กุญแจรถ",
      "desc": "พวงสีแดง",
      "location": "ลานจอดรถ",
      "status": "พบของแล้ว",
      "phone": "0867778888",
      "lineId": "redkey",
    },
  ];

  Color statusColor(String status) {
    switch (status) {
      case "พบของแล้ว":
        return Colors.green;
      case "มีคนติดต่อ":
        return Colors.blue;
      case "คืนของแล้ว":
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  void openDetail(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          title: posts[index]["title"]!,
          desc: posts[index]["desc"]!,
          location: posts[index]["location"]!,
          status: posts[index]["status"]!,
          phone: posts[index]["phone"]!,
          lineId: posts[index]["lineId"]!,
          time: posts[index]["time"]!,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (result == "delete") {
          posts.removeAt(index);
        } else {
          posts[index]["status"] = result;
        }
      });
    }
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
          "โพสของฉัน",
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, i) {
          final p = posts[i];

          return GestureDetector(
            onTap: () => openDetail(i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image,
                        color: Color(0xFF2196F3), size: 30),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p["title"]!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(p["desc"]!,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor(p["status"]!)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p["status"]!,
                            style: TextStyle(
                              color: statusColor(p["status"]!),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
