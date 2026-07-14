import 'package:flutter/material.dart';
import 'package:flutter_backend/controllers/logout_controller.dart';
import 'package:flutter_backend/screens/cart.dart';
import 'package:flutter_backend/screens/checkprize.dart';
import 'package:flutter_backend/screens/lotto.dart';
import 'package:flutter_backend/screens/lotto_me.dart';
import 'package:flutter_backend/screens/menu.dart';
import 'package:flutter_backend/screens/profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final int currentIndex;

  const HomePage({super.key, this.currentIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<Map<String, dynamic>> navItems = [
  {"icon": Icons.home_rounded, "label": "หน้าแรก"},
  {"icon": Icons.shopping_bag_rounded, "label": "ซื้อลอตโต้"},
  {"icon": Icons.shopping_cart_rounded, "label": "ตะกร้า"},
  {"icon": Icons.search_rounded, "label": "ตรวจรางวัล"},
  {"icon": Icons.person_rounded, "label": "คุณ"},
];

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  String _username = "";
  String _wallet = "0";
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _loadUserInfo();
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

  String _formatCurrency(String amount) {
    try {
      final number = double.parse(amount);
      final formatter = NumberFormat("#,##0.00", "th_TH"); 
      return formatter.format(number);
    } catch (e) {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // Slate 800
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    "https://fiverr-res.cloudinary.com/image/upload/f_auto,q_auto,t_profile_small/v1/attachments/profile/photo/b91c25cc1491be439d52cd5bb915ad42-1753531201742/f0dd0529-b943-48d9-a82c-19d6ccf248f9.jpg",
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ยินดีต้อนรับ,",
                    style: GoogleFonts.notoSansThai(
                      color: Colors.blueGrey.shade400,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _username,
                    style: GoogleFonts.notoSansThai(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notes_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MenuPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E293B), // Slate 800
              Color(0xFF0F172A), // Slate 900
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Premium Gold Wallet Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2E3A59),
                      Color(0xFF151B26),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFB300).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "บัตรเครดิต Drawly Wallet",
                          style: GoogleFonts.notoSansThai(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.nfc_rounded,
                          color: Color(0xFFFFB300),
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "ยอดเงินคงเหลือ",
                      style: GoogleFonts.notoSansThai(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${_formatCurrency(_wallet)} ฿",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFB300),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "เงินจริง",
                            style: GoogleFonts.notoSansThai(
                              color: const Color(0xFFFFB300),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                "เมนูจัดการลอตเตอรี่",
                style: GoogleFonts.notoSansThai(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Dynamic Grid Menu Buttons
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _menuButton(
                    Icons.shopping_bag_rounded,
                    "ซื้อลอตโต้",
                    const Color(0xFFFFB300),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LottoPage(currentIndex: 1),
                        ),
                      );
                    },
                  ),
                  _menuButton(
                    Icons.confirmation_number_rounded,
                    "ลอตโต้ของฉัน",
                    const Color(0xFF3F51B5),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LottoMePage(),
                        ),
                      );
                    },
                  ),
                  _menuButton(
                    Icons.search_rounded,
                    "ตรวจรางวัล",
                    const Color(0xFF00B0FF),
                    () {
                      _onTabTapped(3);
                    },
                  ),
                  _menuButton(
                    Icons.account_balance_wallet_rounded,
                    "กระเป๋าเงิน",
                    const Color(0xFF4CAF50),
                    () {
                      _onTabTapped(4);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 🔹 Logout section bar
              InkWell(
                onTap: () {
                  LogoutController().logout(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      const SizedBox(width: 16),
                      Text(
                        "ออกจากระบบ",
                        style: GoogleFonts.notoSansThai(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, color: Colors.redAccent),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.asMap().entries.map((entry) {
                int idx = entry.key;
                bool isSelected = _currentIndex == idx;
                return InkWell(
                  onTap: () => _onTabTapped(idx),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        entry.value["icon"],
                        color: isSelected ? const Color(0xFFFFB300) : Colors.blueGrey.shade400,
                        size: 28,
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
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuButton(IconData icon, String title, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadUserInfo() async {
    final username = await storage.read(key: "username");
    final wallet = await storage.read(key: "wallet");

    setState(() {
      _username = username ?? "";
      _wallet = wallet ?? "0";
    });
  }
}
