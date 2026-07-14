import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_backend/controllers/checkprize_controller.dart';
import 'package:flutter_backend/screens/cart.dart';
import 'package:flutter_backend/screens/lotto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_backend/screens/home.dart';
import 'package:flutter_backend/screens/profile.dart';

class CheckprizePage extends StatefulWidget {
  final int currentIndex;
  const CheckprizePage({super.key, this.currentIndex = 3});

  @override
  State<CheckprizePage> createState() => _CheckprizePageState();
}

class _CheckprizePageState extends State<CheckprizePage> {
  final CheckprizePageController _controller = CheckprizePageController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  final storage = FlutterSecureStorage();
  late int _currentIndex;

  List<Datum> prizeResult = [];
  List<Datum> checkPrizeResult = [];
  bool _loading = false;
  bool _hasSearched = false;

  final List<Map<String, dynamic>> navItems = [
    {"icon": Icons.home, "label": "หน้าแรก"},
    {"icon": Icons.shopping_bag, "label": "ซื้อลอตโต้"},
    {"icon": Icons.shopping_cart, "label": "ตะกร้า"},
    {"icon": Icons.search, "label": "ตรวจรางวัล"},
    {"icon": Icons.person, "label": "คุณ"},
  ];

  Map<int, List<Datum>> _groupPrizesByLottoId(List<Datum> prizes) {
    Map<int, List<Datum>> grouped = {};
    for (var prize in prizes) {
      if (!grouped.containsKey(prize.lotto_id)) {
        grouped[prize.lotto_id] = [];
      }
      grouped[prize.lotto_id]!.add(prize);
    }
    return grouped;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _loadUserInfo();
    _loadPrize(selectedDate);
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(currentIndex: 0),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LottoPage(currentIndex: 1),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CheckprizePage(currentIndex: 3),
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(currentIndex: 4),
        ),
      );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _hasSearched = false;
        checkPrizeResult = [];
      });
      _loadPrize(selectedDate);
    }
  }

  Future<void> _loadPrize(DateTime date) async {
    setState(() {
      _loading = true;
      prizeResult = [];
    });

    try {
      final model = await _controller.getPrizeByDate(date);
      setState(() {
        prizeResult = model.data;
      });
    } catch (e) {
      log("Error fetching prize: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _loadUserInfo() async {
    final username = await storage.read(key: "username");
    setState(() {
      _nameController.text = username ?? "";
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  Widget _buildLosingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sentiment_very_dissatisfied_rounded, color: Colors.redAccent, size: 54),
          const SizedBox(height: 12),
          Text(
            "เสียใจด้วยนะคุณ",
            style: GoogleFonts.notoSansThai(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "ไม่ถูกรางวัล หรือ ไม่พบสลากใบนี้ในระบบ",
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              color: Colors.blueGrey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWinningPrizeCard(List<Datum> prizes) {
    prizes.sort((a, b) => a.prizeRank.compareTo(b.prizeRank));

    double totalAmount = 0;
    for (var prize in prizes) {
      totalAmount += double.parse(prize.prizeAmount);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "ยินดีด้วย คุณถูกรางวัล! 🎉",
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E676),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Numbers
            Text(
              prizes.first.number,
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              "งวดประจำวันที่ ${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year + 543}",
              style: GoogleFonts.notoSansThai(
                fontSize: 13,
                color: Colors.blueGrey.shade400,
              ),
            ),
            const SizedBox(height: 20),

            // Prize ranks list
            ...prizes.map(
              (prize) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ถูกรางวัลที่ ${prize.prizeRank}",
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "+${_formatPrizeAmount(prize.prizeAmount)} ฿",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "รวมเงินรางวัลทั้งหมด",
              style: GoogleFonts.notoSansThai(
                fontSize: 14,
                color: Colors.blueGrey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${_formatPrizeAmount(totalAmount.toString())} บาท",
              style: GoogleFonts.notoSansThai(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00E676),
              ),
            ),
            const SizedBox(height: 20),

            // Claim button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFB300),
                    Color(0xFFFF8F00),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8F00).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  _claimMultiplePrizes(prizes);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  "ขึ้นเงินรางวัลทั้งหมด",
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrizeAmount(String amount) {
    try {
      final number = double.parse(amount);
      return number
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } catch (e) {
      return amount;
    }
  }

  // Function สำหรับขึ้นเงินรางวัล

  void _claimPrize(Datum prize) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ยืนยันขึ้นเงินรางวัล",
                style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "คุณต้องการขึ้นเงินรางวัลจำนวน\n${_formatPrizeAmount(prize.prizeAmount)} บาท ใช่ไหม?",
                style: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  color: Colors.blueGrey.shade300,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        "ไม่ใช่",
                        style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "ยืนยัน",
                        style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                ),
                const SizedBox(height: 16),
                Text(
                  "กำลังดำเนินการ...",
                  style: GoogleFonts.notoSansThai(color: Colors.white),
                ),
              ],
            ),
          ),
        );

        final result = await _controller.claimPrize(prize.lotto_id);

        final storage = FlutterSecureStorage();
        await storage.write(
          key: "wallet",
          value: result['data']['wallet_after'].toString(),
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ขึ้นเงินรางวัลเรียบร้อยแล้ว จำนวน ${_formatPrizeAmount(prize.prizeAmount)} บาท",
              style: GoogleFonts.notoSansThai(),
            ),
            backgroundColor: const Color(0xFF00E676),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e", style: GoogleFonts.notoSansThai()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _claimMultiplePrizes(List<Datum> prizes) async {
    double totalAmount = 0;
    String prizeDetails = "";

    for (var prize in prizes) {
      totalAmount += double.parse(prize.prizeAmount);
      prizeDetails += "รางวัลที่ ${prize.prizeRank} (${_formatPrizeAmount(prize.prizeAmount)} บาท)\n";
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ขึ้นเงินรางวัลทั้งหมด",
                style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                prizeDetails.trim(),
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  color: Colors.blueGrey.shade300,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "รวมเงินรางวัล ${_formatPrizeAmount(totalAmount.toString())} บาท",
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFB300),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        "ไม่ใช่",
                        style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "ยืนยัน",
                        style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                ),
                const SizedBox(height: 16),
                Text(
                  "กำลังขึ้นเงินรางวัล...",
                  style: GoogleFonts.notoSansThai(color: Colors.white),
                ),
              ],
            ),
          ),
        );

        final result = await _controller.claimPrize(prizes.first.lotto_id);

        final storage = FlutterSecureStorage();
        await storage.write(
          key: "wallet",
          value: result['data']['wallet_after'].toString(),
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ขึ้นเงินรางวัลเรียบร้อยแล้ว จำนวน ${_formatPrizeAmount(totalAmount.toString())} บาท",
              style: GoogleFonts.notoSansThai(),
            ),
            backgroundColor: const Color(0xFF00E676),
          ),
        );

        setState(() {
          _hasSearched = false;
          checkPrizeResult = [];
        });
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e", style: GoogleFonts.notoSansThai()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // แก้ไข _buildPrizeDisplay method
  Widget _buildPrizeDisplay() {
    if (_hasSearched) {
      if (checkPrizeResult.isEmpty) return _buildLosingCard();

      // จัดกลุ่มรางวัลตาม lotto_id
      Map<int, List<Datum>> groupedPrizes = _groupPrizesByLottoId(
        checkPrizeResult,
      );

      return Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          child: Column(
            children: groupedPrizes.values
                .map((prizeGroup) => _buildWinningPrizeCard(prizeGroup))
                .toList(),
          ),
        ),
      );
    }

    // แสดงรางวัลปกติ (ไม่เปลี่ยน)
    if (prizeResult.isEmpty) {
      return const Center(
        child: Text(
          "ยังไม่ได้เลือกงวดหรือไม่มีข้อมูล",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // รางวัลที่ 1
              Text(
                "รางวัลที่ 1",
                style: GoogleFonts.notoSansThai(
                  color: const Color(0xFF0C6FBB),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "รางวัลละ ${prizeResult[0].prizeAmount}",
                style: GoogleFonts.notoSansThai(color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                prizeResult[0].number,
                style: GoogleFonts.notoSansThai(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0C6FBB),
                  letterSpacing: 4,
                ),
              ),
              const Divider(height: 32),

              // แสดงรางวัลที่ 2, 3 และเลขท้าย
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _PrizeBox(
                      "รางวัลที่ 2",
                      prizeResult.length > 1 ? prizeResult[1].prizeAmount : "",
                      prizeResult.length > 1 ? prizeResult[1].number : "",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PrizeBox(
                      "รางวัลที่ 3",
                      prizeResult.length > 2 ? prizeResult[2].prizeAmount : "",
                      prizeResult.length > 2 ? prizeResult[2].number : "",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _PrizeBox(
                      "เลขท้าย 3 ตัว",
                      prizeResult.length > 3 ? prizeResult[3].prizeAmount : "",
                      prizeResult.length > 3
                          ? prizeResult[3].number.length >= 3
                                ? prizeResult[3].number.substring(
                                    prizeResult[3].number.length - 3,
                                  )
                                : prizeResult[3].number
                          : "",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PrizeBox(
                      "เลขท้าย 2 ตัว",
                      prizeResult.length > 4 ? prizeResult[4].prizeAmount : "",
                      prizeResult.length > 4
                          ? prizeResult[4].number.length >= 2
                                ? prizeResult[4].number.substring(
                                    prizeResult[4].number.length - 2,
                                  )
                                : prizeResult[4].number
                          : "",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "ตรวจผลรางวัลลอตเตอรี่",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year + 543}",
                            style: GoogleFonts.notoSansThai(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded, color: Color(0xFFFFB300), size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _numberController,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: "กรอกหมายเลขสลาก 6 หลัก",
                      hintStyle: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.3),
                        letterSpacing: 0,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFFB300), width: 1.5),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFB300),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search_rounded, color: Colors.black, size: 20),
                          onPressed: () async {
                            String number = _numberController.text.trim();
                            if (number.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("กรุณากรอกหมายเลขสลาก", style: GoogleFonts.notoSansThai()),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _loading = true;
                              _hasSearched = true;
                              checkPrizeResult = [];
                            });

                            try {
                              final model = await _controller.checkPrizeByNumber(
                                number,
                                selectedDate,
                                _nameController.text,
                              );

                              setState(() {
                                checkPrizeResult = model.data;
                              });

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(model.message, style: GoogleFonts.notoSansThai()),
                                    backgroundColor: const Color(0xFF00E676),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("เกิดข้อผิดพลาด: $e", style: GoogleFonts.notoSansThai()),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            } finally {
                              setState(() => _loading = false);
                            }
                          },
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                      ),
                    )
                  : _buildPrizeDisplay(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.asMap().entries.map((entry) {
                int idx = entry.key;
                bool isSelected = _currentIndex == idx;
                return InkWell(
                  onTap: () => _onTabTapped(idx),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          entry.value["icon"],
                          color: isSelected ? const Color(0xFFFFB300) : Colors.blueGrey.shade400,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value["label"],
                          style: GoogleFonts.notoSansThai(
                            color: isSelected ? const Color(0xFFFFB300) : Colors.blueGrey.shade400,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// widget ย่อยสำหรับรางวัล
class _PrizeBox extends StatelessWidget {
  final String title;
  final String prizeAmount;
  final String number;

  const _PrizeBox(this.title, this.prizeAmount, this.number);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.notoSansThai(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              "รางวัลละ $prizeAmount",
              style: GoogleFonts.notoSansThai(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              number,
              style: GoogleFonts.notoSansThai(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0C6FBB),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
