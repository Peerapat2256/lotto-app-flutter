import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isSaving = false;

  // ฟังก์ชันเลือกวันที่
  Future<void> _pickDateCustom() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          'เลือกวันที่งวดรางวัล',
          style: GoogleFonts.notoSansThai(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 300,
          height: 300,
          child: Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFFFB300),
                onPrimary: Colors.black,
                surface: Color(0xFF1E293B),
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: const Color(0xFF1E293B),
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเลือกวันที่งวด', style: GoogleFonts.notoSansThai()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final url = Uri.parse("https://api-lotto-miqd.onrender.com/lotto/save");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "draw_date": _selectedDate!.toIso8601String().split("T").first,
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
          SnackBar(
            content: Text('บันทึกผลรางวัลเรียบร้อยแล้ว!', style: GoogleFonts.notoSansThai()),
            backgroundColor: const Color(0xFF00E676),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResp["message"] ?? 'เกิดข้อผิดพลาด', style: GoogleFonts.notoSansThai()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ข้อผิดพลาดการเชื่อมต่อ: $e', style: GoogleFonts.notoSansThai()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          "ประกาศผลรางวัล",
          style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Date picker field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: _isSaving ? null : _pickDateCustom,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null ? "เลือกงวดประจำวันที่ออกรางวัล" : _dateController.text,
                        style: GoogleFonts.notoSansThai(
                          fontSize: 15,
                          color: _selectedDate == null ? Colors.white.withOpacity(0.4) : Colors.white,
                          fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFFFFB300), size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results Panel
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        "รางวัลที่ 1",
                        style: GoogleFonts.notoSansThai(
                          color: const Color(0xFFFFB300),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "รางวัลละ: 6,000,000 ฿",
                        style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade400, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.prizes["prize1"] ?? "000000",
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: Colors.white.withOpacity(0.05)),
                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        childAspectRatio: 1.1,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _PrizeBox(
                            "รางวัลที่ 2",
                            "100,000 ฿",
                            widget.prizes["prize2"] ?? "000000",
                          ),
                          _PrizeBox(
                            "รางวัลที่ 3",
                            "80,000 ฿",
                            widget.prizes["prize3"] ?? "000000",
                          ),
                          _PrizeBox(
                            "เลขท้าย 3 ตัว",
                            "4,000 ฿",
                            widget.prizes["prize4"] ?? "000000",
                          ),
                          _PrizeBox(
                            "เลขท้าย 2 ตัว",
                            "2,000 ฿",
                            widget.prizes["prize5"] ?? "000000",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Admin()),
                      (route) => false,
                    );
                  },
                  label: Text(
                    "กลับหน้าแผงควบคุม",
                    style: GoogleFonts.notoSansThai(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSansThai(
              color: Colors.blueGrey.shade300,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "รางวัลละ: $prize",
            style: GoogleFonts.notoSansThai(color: const Color(0xFFFFB300), fontSize: 11),
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
