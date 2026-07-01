import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_backend/screens/lotto_result_page.dart';
import 'package:http/http.dart' as http;

class LottoDrawPage extends StatefulWidget {
  const LottoDrawPage({super.key});

  @override
  State<LottoDrawPage> createState() => _LottoDrawPageState();
}

class _LottoDrawPageState extends State<LottoDrawPage> {
  bool fromSold = false;
  bool allNumbers = false;
  Map<String, String> prizes = {
    "prize1": "000000",
    "prize2": "000000",
    "prize3": "000000",
    "prize4": "000000",
    "prize5": "000000",
  };


  Future<void> drawPrizes() async {
    final url = Uri.parse("https://api-lotto-miqd.onrender.com/lotto/draw");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"fromSold": fromSold, "allNumbers": allNumbers}),
      );

      if (response.statusCode == 200) {
        final jsonResp = jsonDecode(response.body);
        if (jsonResp["status"] == "success") {
          setState(() {
            prizes = Map<String, String>.from(jsonResp["data"]);
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("เกิดข้อผิดพลาด"),
              content: Text(jsonResp["message"] ?? "ไม่สามารถสุ่มรางวัลได้"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ปิด"),
                ),
              ],
            ),
          );
        }
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void submitLottoResult() {
    // ส่งไปหน้า LottoResultPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LottoResultPage(prizes: prizes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: const Text(
          "สุ่มออกรางวัล",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // ส่วนเลือกการสุ่ม
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text("สุ่มจากเลขที่ขายไปแล้ว"),
                      value: fromSold,
                      onChanged: (val) {
                        setState(() {
                          fromSold = val ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text("สุ่มเลขทั้งหมด"),
                      value: allNumbers,
                      onChanged: (val) {
                        setState(() {
                          allNumbers = val ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade600,
                          foregroundColor: const Color(0xFF0C6FBB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: (fromSold || allNumbers) ? drawPrizes : null,
                        child: const Text(
                          "ออกรางวัล",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ส่วนแสดงรางวัล
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.white,
                elevation: 3,
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
                          color: Color(0xFF0C6FBB),
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        "รางวัลละ: 6,000,000",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prizes["prize1"] ?? "000000",
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
                            prizes["prize2"] ?? "000000",
                          ),
                          _PrizeBox(
                            "รางวัลที่ 3",
                            "80,000",
                            prizes["prize3"] ?? "000000",
                          ),
                          _PrizeBox(
                            "เลขท้าย 3 ตัว",
                            "4,000",
                            prizes["prize4"] ?? "000000",
                          ),
                          _PrizeBox(
                            "เลขท้าย 2 ตัว",
                            "2,000",
                            prizes["prize5"] ?? "000000",
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ปุ่มยืนยันประกาศผลรางวัล
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade600,
                            foregroundColor: const Color(0xFF0C6FBB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: submitLottoResult,
                          child: const Text(
                            "ยืนยันประกาศผลรางวัล",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
            color: Color(0xFF0C6FBB),
            fontSize: 14,
            height: 2.2,
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
            fontSize: 22,
            color: Color(0xFF0C6FBB),
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
