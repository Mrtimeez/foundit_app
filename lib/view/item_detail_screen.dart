import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String title;
  final String desc;
  final String location;
  final String phone;
  final String lineId;
  final String time;
  final String status;

  const PostDetailScreen({
    super.key,
    required this.title,
    required this.desc,
    required this.location,
    required this.phone,
    required this.lineId,
    required this.time,
    required this.status,
  });

  Color statusColor() {
    switch (status) {
      case "พบของแล้ว":
        return Colors.green;
      case "มีคนติดต่อ":
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        title: const Text("รายละเอียดโพส"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _row("ชื่อสิ่งของ", title),
              _row("รายละเอียด", desc),
              _row("สถานที่", location),

              const Divider(height: 28),

              const Text(
                "ช่องทางติดต่อ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3)),
              ),
              const SizedBox(height: 8),

              _row("เบอร์", phone),
              _row("LINE ID", lineId),

              const Divider(height: 28),

              _row("เวลาโพส", time),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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
