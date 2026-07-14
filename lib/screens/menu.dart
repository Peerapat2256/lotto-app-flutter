import 'package:flutter/material.dart';
import 'package:flutter_backend/controllers/logout_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 12, 111, 187),
        title: Text(
          'เมนู',
          style: GoogleFonts.poppins(
            color: Colors.white,        // สีตัวอักษร
            fontWeight: FontWeight.bold, // ตัวหนา
            fontSize: 22,                // ขนาดตัวอักษร
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // ✅ กลับไปหน้า home.dart
            },
          ),
        ],
        automaticallyImplyLeading: false, // ปิดปุ่ม back อัตโนมัติ

        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            _menuButton(Icons.shopping_bag, "ซื้อลอตโต้", () {
              print("กด ซื้อลอตโต้");
            }),
            _menuButton(Icons.confirmation_number, "ลอตโต้ของฉัน", () {
              print("กด ลอตโต้ของฉัน");
            }),
            _menuButton(Icons.account_balance_wallet, "ยอดเงิน", () {
              print("กด ยอดเงิน");
            }),
            _menuButton(Icons.description, "ตรวจรางวัล", () {
              print("กด ตรวจรางวัล");
            }),
            _menuButton(Icons.logout, "ออกจากระบบ", () {
              LogoutController().logout(context);
            }),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  static Widget _menuButton(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey[700]),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(   
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
