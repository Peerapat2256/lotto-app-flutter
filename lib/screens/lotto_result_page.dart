import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_backend/screens/admin.dart';
import 'package:http/http.dart' as http;


class LottoResultPage extends StatefulWidget {
  final Map<String, String> prizes; // เก็บเลขรางวัล

  const LottoResultPage({super.key, required this.prizes});

  @override
  State<LottoResultPage> createState() => _LottoResultPageState();
}

class _LottoResultPageState extends State<LottoResultPage> {
  DateTime? _selectedDate; // วันที่ที่เลือก
  final TextEditingController _dateController = TextEditingController();

  // ฟังก์ชันเลือกวันที่
  Future<void> _pickDateCustom() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกวันที่'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              Navigator.pop(context, date);
            },
          ),
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.day} ${_monthName(picked.month)} ${picked.year + 543}";
      });
      await submitLottoResult();
    }
  }

  // ฟังก์ชันแปลงเดือนเป็นชื่อไทย
  String _monthName(int month) {
    const months = [
      "",
      "มกราคม",
      "กุมภาพันธ์",
      "มีนาคม",
      "เมษายน",
      "พฤษภาคม",
      "มิถุนายน",
      "กรกฎาคม",
      "สิงหาคม",
      "กันยายน",
      "ตุลาคม",
      "พฤศจิกายน",
      "ธันวาคม",
    ];
    return months[month];
  }

  Future<void> submitLottoResult() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกวันที่งวด')));
      return;
    }

    final url = Uri.parse("https://api-lotto-miqd.onrender.com/lotto/save");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "draw_date": _selectedDate!.toIso8601String().split("T").first,
          // "draw_date": DateTime.now()
          //     .toString()
          //     .split('.')
          //     .first, // format YYYY-MM-DD HH:MM:SS
          "prizes": {
            "1": {
              "number": widget.prizes["prize1"]!.padLeft(6, '0'),
              "amount": 6000000,
            },
            "2": {
              "number": widget.prizes["prize2"]!.padLeft(6, '0'),
              "amount": 100000,
            },
            "3": {
              "number": widget.prizes["prize3"]!.padLeft(6, '0'),
              "amount": 80000,
            },
            "4": {
              "number": widget.prizes["prize4"]!.padLeft(6, '0'),
              "amount": 4000,
            },
            "5": {
              "number": widget.prizes["prize5"]!.padLeft(6, '0'),
              "amount": 2000,
            },
          },
        }),
      );

      final jsonResp = jsonDecode(response.body);
      if (jsonResp["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกผลรางวัลเรียบร้อยแล้ว')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResp["message"] ?? 'เกิดข้อผิดพลาด')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text(
          "ประกาศผลรางวัล",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // วันที่
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_month,
                          color: Colors.grey,
                        ),
                        onPressed: _pickDateCustom, // กดเพื่อเลือกวัน
                      ),
                      hintText: "เลือกวันที่",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ผลรางวัล
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "รางวัลที่ 1",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C6FBB),
                        ),
                      ),
                      const Text(
                        "รางวัลละ: 6,000,000",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.prizes["prize1"] ?? "000000",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C6FBB),
                          letterSpacing: 4,
                        ),
                      ),
                      const Divider(height: 32),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        childAspectRatio: 4 / 2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _PrizeBox(
                            "รางวัลที่ 2",
                            "100,000",
                            widget.prizes["prize2"] ?? "000000",
                          ),
                          _PrizeBox(
                            "รางวัลที่ 3",
                            "80,000",
                            widget.prizes["prize3"] ?? "000000",
                          ),
                          _PrizeBox(
                            "เลขท้าย 3 ตัว",
                            "4,000",
                            widget.prizes["prize4"] ?? "000000",
                          ),
                          _PrizeBox(
                            "เลขท้าย 2 ตัว",
                            "2,000",
                            widget.prizes["prize5"] ?? "000000",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ปุ่มกลับหน้าหลัก
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SizedBox(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C6FBB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Admin()),
                    (route) => false,
                  );
                },
                label: const Text("กลับหน้าหลัก"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrizeBox extends StatelessWidget {
  final String title;
  final String prize;
  final String number;

  const _PrizeBox(this.title, this.prize, this.number);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            height: 2,
            fontWeight: FontWeight.w100,
            fontSize: 14,
            color: Color(0xFF0C6FBB),
          ),
        ),
        Text(
          "รางวัลละ: $prize",
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Text(
          number,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Color(0xFF0C6FBB),
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
