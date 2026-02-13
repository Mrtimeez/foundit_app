import 'package:flutter/material.dart';
import 'item_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> items = [
    {
      "title": "กระเป๋าสตางค์",
      "desc": "สีดำ ใส่บัตรหลายใบ",
      "location": "โรงอาหาร",
      "phone": "0812345678",
      "lineId": "owner_blackbag",
      "time": "5 ชม. ที่แล้ว",
      "status": "รอการติดต่อ"
    },
    {
      "title": "โทรศัพท์",
      "desc": "iPhone 13 สีฟ้า",
      "location": "อาคาร A",
      "phone": "0891112222",
      "lineId": "iphone_blue",
      "time": "3 ชม. ที่แล้ว",
      "status": "มีคนติดต่อ"
    },
    {
      "title": "กุญแจรถ",
      "desc": "Honda พวงสีแดง",
      "location": "ลานจอดรถ",
      "phone": "0867778888",
      "lineId": "redkey",
      "time": "1 วันที่แล้ว",
      "status": "พบของแล้ว"
    },
  ];

  List<Map<String, String>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = items;
  }

  void _search(String keyword) {
    final results = items.where((item) {
      final title = item["title"]!.toLowerCase();
      final desc = item["desc"]!.toLowerCase();
      return title.contains(keyword.toLowerCase()) ||
          desc.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredItems = results;
    });
  }

  Color statusColor(String status) {
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
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ค้นหา",
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            //ช่องค้นหา
            TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: "ค้นหาของหาย หรือ ของที่พบ...",
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF2196F3)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            //รายการผลลัพธ์
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                child: Text(
                  "ไม่พบข้อมูล",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(
                            title: item["title"]!,
                            desc: item["desc"]!,
                            location: item["location"]!,
                            phone: item["phone"]!,
                            lineId: item["lineId"]!,
                            time: item["time"]!,
                            status: item["status"]!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin:
                      const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue
                                .withOpacity(0.06),
                            blurRadius: 6,
                            offset:
                            const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFE3F2FD),
                              borderRadius:
                              BorderRadius
                                  .circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory,
                              color: Color(
                                  0xFF2196F3),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  item["title"]!,
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),
                                Text(
                                  item["desc"]!,
                                  style:
                                  const TextStyle(
                                      color: Colors
                                          .grey),
                                ),
                                const SizedBox(
                                    height: 6),

                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      10,
                                      vertical:
                                      4),
                                  decoration:
                                  BoxDecoration(
                                    color: statusColor(
                                        item[
                                        "status"]!)
                                        .withOpacity(
                                        0.15),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        20),
                                  ),
                                  child: Text(
                                    item[
                                    "status"]!,
                                    style:
                                    TextStyle(
                                      color: statusColor(
                                          item[
                                          "status"]!),
                                      fontSize:
                                      12,
                                      fontWeight:
                                      FontWeight
                                          .bold,
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
            ),
          ],
        ),
      ),
    );
  }
}
