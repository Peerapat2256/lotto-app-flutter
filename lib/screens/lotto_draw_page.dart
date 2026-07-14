import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLoading = false;
  Map<String, String> prizes = {
    "prize1": "000000",
    "prize2": "000000",
    "prize3": "000000",
    "prize4": "000000",
    "prize5": "000000",
  };

  Future<void> drawPrizes() async {
    setState(() => _isLoading = true);
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("สุ่มรางวัลสำเร็จ!", style: GoogleFonts.notoSansThai()),
              backgroundColor: const Color(0xFF00E676),
            ),
          );
        } else {
          _showErrorDialog(jsonResp["message"] ?? "ไม่สามารถสุ่มรางวัลได้");
        }
      } else {
        _showErrorDialog("เซิร์ฟเวอร์ตอบสนองผิดพลาด (${response.statusCode})");
      }
    } catch (e) {
      _showErrorDialog("เกิดข้อผิดพลาดในการเชื่อมต่อ: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          "เกิดข้อผิดพลาด",
          style: GoogleFonts.notoSansThai(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: GoogleFonts.notoSansThai(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "ปิด",
              style: GoogleFonts.notoSansThai(color: const Color(0xFFFFB300)),
            ),
          ),
        ],
      ),
    );
  }

  void submitLottoResult() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LottoResultPage(prizes: prizes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          "สุ่มออกรางวัล",
          style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Settings Panel
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "เงื่อนไขการสุ่มรางวัล",
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: Colors.blueGrey.shade400,
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: Text(
                              "สุ่มจากเลขที่ขายไปแล้ว",
                              style: GoogleFonts.notoSansThai(color: Colors.white, fontSize: 14),
                            ),
                            activeColor: const Color(0xFFFFB300),
                            checkColor: Colors.black,
                            value: fromSold,
                            onChanged: (val) {
                              setState(() {
                                fromSold = val ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: Text(
                              "สุ่มเลขทั้งหมด",
                              style: GoogleFonts.notoSansThai(color: Colors.white, fontSize: 14),
                            ),
                            activeColor: const Color(0xFFFFB300),
                            checkColor: Colors.black,
                            value: allNumbers,
                            onChanged: (val) {
                              setState(() {
                                allNumbers = val ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB300),
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: Colors.blueGrey.shade800,
                          disabledForegroundColor: Colors.blueGrey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: (fromSold || allNumbers) && !_isLoading ? drawPrizes : null,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                "เริ่มออกรางวัลสุ่ม",
                                style: GoogleFonts.notoSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Prizes Display
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        prizes["prize1"] ?? "000000",
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
                            prizes["prize2"] ?? "000000",
                          ),
                          _PrizeBox(
                            "รางวัลที่ 3",
                            "80,000 ฿",
                            prizes["prize3"] ?? "000000",
                          ),
                          _PrizeBox(
                            "เลขท้าย 3 ตัว",
                            "4,000 ฿",
                            prizes["prize4"] ?? "000000",
                          ),
                          _PrizeBox(
                            "เลขท้าย 2 ตัว",
                            "2,000 ฿",
                            prizes["prize5"] ?? "000000",
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00E676),
                              Color(0xFF00C853),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: submitLottoResult,
                          child: Text(
                            "ยืนยันประกาศผลรางวัล",
                            style: GoogleFonts.notoSansThai(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
