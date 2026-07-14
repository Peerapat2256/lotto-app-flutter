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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.close, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          Text(
            "ไม่ถูกรางวัล",
            style: GoogleFonts.notoSansThai(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Text(
            "หรือไม่พบสลากใบนี้",
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // แก้ไข _buildWinningPrizeCard ให้รับ List<Datum> แทน Datum เดียว
  Widget _buildWinningPrizeCard(List<Datum> prizes) {
    // เรียงรางวัลตาม rank (รางวัลที่ 1, 2, 3, เลขท้าย 3 ตัว, เลขท้าย 2 ตัว)
    prizes.sort((a, b) => a.prizeRank.compareTo(b.prizeRank));

    // คำนวณเงินรางวัลรวม
    double totalAmount = 0;
    for (var prize in prizes) {
      totalAmount += double.parse(prize.prizeAmount);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ข้อความ "ยินดีด้วยน้า"
              Text(
                "ยินดีด้วยน้า",
                style: GoogleFonts.notoSansThai(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // หมายเลขที่ถูกรางวัล
              Text(
                prizes.first.number,
                style: GoogleFonts.notoSansThai(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 5),

              // วันที่ออกรางวัล
              Text(
                "งวดประจำวันที่ ${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year + 543}",
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // แสดงรางวัลที่ถูกทั้งหมด
              ...prizes.map(
                (prize) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C6FBB),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "ถูกรางวัลที่ ${prize.prizeRank} (${_formatPrizeAmount(prize.prizeAmount)} บาท)",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ข้อความ "รับรางวัลรวม"
              Text(
                "รับรางวัลรวม",
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),

              // จำนวนเงินรางวัลรวม
              Text(
                "${_formatPrizeAmount(totalAmount.toString())} บาท",
                style: GoogleFonts.notoSansThai(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0C6FBB),
                ),
              ),
              const SizedBox(height: 20),

              // ปุ่มขึ้นเงินรางวัล
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    _claimMultiplePrizes(prizes);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    "ขึ้นเงินรางวัลทั้งหมด",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function สำหรับจัดรูปแบบตัวเลขเงินรางวัล
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
    // แสดง confirmation dialog ก่อน
    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color.fromARGB(
        133,
        232,
        232,
        232,
      ).withOpacity(0.6), // พื้นหลังหมอกขาว/เทา
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // หัวข้อ
              Text(
                "ขึ้นเงินรางวัล",
                style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // ข้อความถาม
              Text(
                "คุณต้องการขึ้นเงินรางวัล\n${_formatPrizeAmount(prize.prizeAmount)} บาทใช่ไหม?",
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ปุ่มเลือก
              Row(
                children: [
                  // ปุ่มยกเลิก
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "ไม่ใช่",
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ปุ่มยืนยัน
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C6FBB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "ยืนยัน",
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

    // ถ้าผู้ใช้ยืนยัน ให้ทำการขึ้นเงินรางวัล
    if (confirm == true) {
      try {
        // แสดง loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54.withOpacity(0.6), // พื้นหลังหมอกขาว/เทา
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C6FBB)),
                ),
                const SizedBox(height: 16),
                Text(
                  "กำลังขึ้นเงินรางวัล...",
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );

        final result = await _controller.claimPrize(prize.lotto_id);

        // อัปเดต wallet ใน storage
        final storage = FlutterSecureStorage();
        await storage.write(
          key: "wallet",
          value: result['data']['wallet_after'].toString(),
        );

        // ปิด loading dialog
        Navigator.of(context).pop();

        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ขึ้นเงินรางวัลเรียบร้อยแล้ว จำนวน ${_formatPrizeAmount(prize.prizeAmount)} บาท",
              style: GoogleFonts.notoSansThai(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } catch (e) {
        // ปิด loading dialog ถ้ามี error
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "เกิดข้อผิดพลาดในการขึ้นเงินรางวัล: $e",
              style: GoogleFonts.notoSansThai(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _claimMultiplePrizes(List<Datum> prizes) async {
    // คำนวณเงินรางวัลรวม
    double totalAmount = 0;
    String prizeDetails = "";

    for (var prize in prizes) {
      totalAmount += double.parse(prize.prizeAmount);
      prizeDetails +=
          "รางวัลที่ ${prize.prizeRank} (${_formatPrizeAmount(prize.prizeAmount)} บาท)\n";
    }

    // แสดง confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color.fromARGB(133, 232, 232, 232).withOpacity(0.6),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ขึ้นเงินรางวัล",
                style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "รางวัลที่ถูก:",
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                prizeDetails.trim(),
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  color: Colors.black54,
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
                  color: const Color(0xFF0C6FBB),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                "คุณต้องการขึ้นเงินรางวัลทั้งหมดใช่ไหม?",
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "ไม่ใช่",
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C6FBB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "ยืนยัน",
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
        // แสดง loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54.withOpacity(0.6),
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C6FBB)),
                ),
                const SizedBox(height: 16),
                Text(
                  "กำลังขึ้นเงินรางวัล...",
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );

        // ส่ง lotto_id ไปขึ้นรางวัล (ใช้ lotto_id ตัวแรก เนื่องจากเป็นใบเดียวกัน)
        final result = await _controller.claimPrize(prizes.first.lotto_id);

        // อัปเดต wallet ใน storage
        final storage = FlutterSecureStorage();
        await storage.write(
          key: "wallet",
          value: result['data']['wallet_after'].toString(),
        );

        // ปิด loading dialog
        Navigator.of(context).pop();

        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ขึ้นเงินรางวัลเรียบร้อยแล้ว จำนวน ${_formatPrizeAmount(totalAmount.toString())} บาท",
              style: GoogleFonts.notoSansThai(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // รีเฟรชหน้าจอ
        setState(() {
          _hasSearched = false;
          checkPrizeResult = [];
        });
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "เกิดข้อผิดพลาดในการขึ้นเงินรางวัล: $e",
              style: GoogleFonts.notoSansThai(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
      body: Stack(
        children: [
          Container(
            height: 250,
            color: const Color.fromARGB(255, 45, 187, 236),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year + 543}",
                          style: GoogleFonts.notoSansThai(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: "กรอกหมายเลขสลาก",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        String number = _numberController.text.trim();
                        if (number.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("กรุณากรอกหมายเลขสลาก"),
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
                              SnackBar(content: Text(model.message)),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
                            );
                          }
                        } finally {
                          setState(() => _loading = false);
                        }
                      },
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildPrizeDisplay(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.11, // 15% ของหน้าจอ

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 0.5, color: const Color(0xFFE6E6E6)),
                Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: navItems.asMap().entries.map((entry) {
                      int idx = entry.key;
                      return Container(
                        height: 5,
                        width: 55,
                        decoration: BoxDecoration(
                          color: _currentIndex == idx
                              ? const Color(0xFF0C6FBB)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: const Color.fromARGB(
                        255,
                        241,
                        241,
                        241,
                      ).withOpacity(0.3),
                      highlightColor: const Color.fromARGB(
                        255,
                        242,
                        242,
                        242,
                      ).withOpacity(0.1),
                    ),
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Colors.white,
                      selectedItemColor: const Color(0xFF0C6FBB),
                      unselectedItemColor: const Color.fromARGB(
                        255,
                        82,
                        82,
                        82,
                      ),
                      currentIndex: _currentIndex,
                      onTap: _onTabTapped,
                      iconSize: 35,
                      selectedLabelStyle: GoogleFonts.notoSansThai(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      unselectedLabelStyle: GoogleFonts.notoSansThai(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                      ),
                      items: navItems.map((item) {
                        return BottomNavigationBarItem(
                          icon: Icon(item["icon"]),
                          label: item["label"],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
