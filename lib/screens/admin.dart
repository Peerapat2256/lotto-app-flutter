import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_backend/controllers/generatelotto_controller.dart';
import 'package:flutter_backend/controllers/logout_controller.dart';
import 'package:flutter_backend/controllers/reset_controllor.dart';
import 'package:flutter_backend/screens/lotto_draw_page.dart';
import 'package:flutter_backend/screens/sold_lotto_addmin.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        title: Text(
          "ระบบหลังบ้านแอดมิน",
          style: GoogleFonts.notoSansThai(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "เมนูจัดการระบบ",
                style: GoogleFonts.notoSansThai(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(
                      context,
                      icon: Icons.emoji_events_rounded,
                      title: "ออกรางวัล",
                      color: const Color(0xFFFFB300),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LottoDrawPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.shopping_bag_rounded,
                      title: "สลากที่ขายแล้ว",
                      color: const Color(0xFF00E676),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LotterySoldPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.add_circle_rounded,
                      title: "เพิ่มสลากใหม่",
                      color: const Color(0xFF29B6F6),
                      onTap: () => _showAddLottoDialog(context),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.refresh_rounded,
                      title: "รีเซ็ตระบบ",
                      color: Colors.redAccent,
                      onTap: () => _showResetSystemDialog(context),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.logout_rounded,
                      title: "ออกจากระบบ",
                      color: Colors.blueGrey.shade400,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddLottoDialog(BuildContext context) async {
    final countController = TextEditingController(text: "100");

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          "เพิ่มสลากใหม่",
          style: GoogleFonts.notoSansThai(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "กรุณากรอกจำนวนสลากที่ต้องการสร้าง:",
              style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade300, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0F172A),
                hintText: "จำนวนล็อตโต้",
                hintStyle: GoogleFonts.notoSansThai(color: Colors.white.withOpacity(0.3)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFB300)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "ยกเลิก",
              style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade400),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "ยืนยัน",
              style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          content: Row(
            children: [
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300))),
              const SizedBox(width: 20),
              Text(
                "กำลังสร้างสลาก...",
                style: GoogleFonts.notoSansThai(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      final controller = GenerateLottoController();
      int count = int.tryParse(countController.text) ?? 100;
      await controller.generateLotto(count: count);

      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            "สำเร็จ",
            style: GoogleFonts.notoSansThai(color: const Color(0xFF00E676), fontWeight: FontWeight.bold),
          ),
          content: Text(
            controller.message,
            style: GoogleFonts.notoSansThai(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ตกลง",
                style: GoogleFonts.notoSansThai(color: const Color(0xFFFFB300), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showResetSystemDialog(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              "รีเซ็ตระบบ",
              style: GoogleFonts.notoSansThai(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตระบบ? ข้อมูลสลากและการซื้อทั้งหมดจะถูกลบ (ยกเว้นบัญชีแอดมิน)",
          style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade300, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "ยกเลิก",
              style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade400),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "รีเซ็ตเลย",
              style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          content: Row(
            children: [
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent)),
              const SizedBox(width: 20),
              Text(
                "กำลังรีเซ็ตระบบ...",
                style: GoogleFonts.notoSansThai(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      final controller = SystemResetController();
      await controller.resetSystem();

      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            "รีเซ็ตสำเร็จ",
            style: GoogleFonts.notoSansThai(color: const Color(0xFF00E676), fontWeight: FontWeight.bold),
          ),
          content: Text(
            controller.message,
            style: GoogleFonts.notoSansThai(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ตกลง",
                style: GoogleFonts.notoSansThai(color: const Color(0xFFFFB300), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          "ออกจากระบบ",
          style: GoogleFonts.notoSansThai(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "คุณต้องการออกจากระบบใช่หรือไม่?",
          style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "ไม่ใช่",
              style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade400),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "ยืนยัน",
              style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      LogoutController().logout(context);
    }
  }
}
