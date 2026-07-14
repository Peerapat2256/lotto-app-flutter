import 'package:flutter/material.dart';
import 'package:flutter_backend/controllers/logout_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          'เมนูทั้งหมด',
          style: GoogleFonts.notoSansThai(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildMenuItem(
              icon: Icons.shopping_bag_rounded,
              title: "ซื้อลอตโต้",
              subtitle: "เลือกซื้อลอตเตอรี่เลขเด็ดสะสมดวง",
              color: const Color(0xFFFFB300),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              icon: Icons.confirmation_number_rounded,
              title: "ลอตโต้ของฉัน",
              subtitle: "ดูประวัติรายการลอตเตอรี่ที่ซื้อไว้",
              color: const Color(0xFF3F51B5),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              icon: Icons.account_balance_wallet_rounded,
              title: "กระเป๋าเงินและโปรไฟล์",
              subtitle: "ดูยอดเงินและเติมเงินเข้าระบบ",
              color: const Color(0xFF4CAF50),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              icon: Icons.search_rounded,
              title: "ตรวจรางวัล",
              subtitle: "ตรวจสอบหมายเลขถูกรางวัลลอตเตอรี่",
              color: const Color(0xFF00B0FF),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 40),
            
            // Logout
            InkWell(
              onTap: () {
                LogoutController().logout(context);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Text(
                        "ออกจากระบบบัญชี",
                        style: GoogleFonts.notoSansThai(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSansThai(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.notoSansThai(
            color: Colors.blueGrey.shade400,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
