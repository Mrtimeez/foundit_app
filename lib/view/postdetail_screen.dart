import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final String title;
  final String desc;
  final String location;
  final String status;
  final String phone;
  final String lineId;
  final String time;


  const PostDetailScreen({
    super.key,
    required this.title,
    required this.desc,
    required this.location,
    required this.status,
    required this.phone,
    required this.lineId,
    required this.time,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.status;
  }

  Color statusColor(String s) {
    switch (s) {
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

  void changeStatus() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เปลี่ยนสถานะ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusBtn("รอการติดต่อ"),
            _statusBtn("มีคนติดต่อ"),
            _statusBtn("พบของแล้ว"),
            _statusBtn("คืนของแล้ว"),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => status = result);
    }
  }

  Widget _statusBtn(String s) {
    return ListTile(
      title: Text(s),
      onTap: () => Navigator.pop(context, s),
    );
  }

  void deletePost() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: const Text("ต้องการลบโพสนี้ใช่หรือไม่"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, "delete");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("ลบโพส"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        title: const Text("รายละเอียดโพสของฉัน"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row("ชื่อสิ่งของ", widget.title),
                  _row("รายละเอียด", widget.desc),
                  _row("สถานที่", widget.location),
                  _row("เบอร์โทร", widget.phone),
                  _row("Line ID", widget.lineId),
                  const SizedBox(height: 12),
                  const Text("สถานะ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor(status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: changeStatus,
                child: const Text("แก้ไขสถานะ"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: deletePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("ลบโพส"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3))),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}


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
      "lineId": "wallet_owner",
    },
    {
      "title": "โทรศัพท์ iPhone",
      "desc": "หายหน้าอาคารเรียน",
      "location": "อาคาร A",
      "status": "มีคนติดต่อ",
      "phone": "0891112222",
      "lineId": "iphone_user",
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
                    child: const Icon(Icons.inventory,
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
