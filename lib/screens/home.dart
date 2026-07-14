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
  {"icon": Icons.home, "label": "หน้าแรก"},
  {"icon": Icons.shopping_bag, "label": "ซื้อลอตโต้"},
  {"icon": Icons.shopping_cart, "label": "ตะกร้า"},
  {"icon": Icons.search, "label": "ตรวจรางวัล"},
  {"icon": Icons.person, "label": "คุณ"},
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
      final formatter = NumberFormat("#,##0", "th_TH"); 
      return formatter.format(number);
    } catch (e) {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              SizedBox(
                width: 65,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      "https://fiverr-res.cloudinary.com/image/upload/f_auto,q_auto,t_profile_small/v1/attachments/profile/photo/b91c25cc1491be439d52cd5bb915ad42-1753531201742/f0dd0529-b943-48d9-a82c-19d6ccf248f9.jpg",
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  _username,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MenuPage()),
              );
            },
          ),
        ],
      ),

      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 การ์ดยอดเงินคงเหลือ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C6FBB),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: Container(
                  height: 130,
                  padding: const EdgeInsets.only(top: 25, left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ยอดเงินคงเหลือ",
                        style: GoogleFonts.notoSansThai(
                          color: Colors.white70,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${_formatCurrency(_wallet)} บาท",
                        style: GoogleFonts.notoSansThai(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _menuButton(Icons.shopping_bag, "ซื้อลอตโต้", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LottoPage(currentIndex: 1),
                      ),
                    );
                  }),
                  _menuButton(Icons.confirmation_number, "ลอตโต้ของฉัน", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LottoMePage(),
                      ),
                    );
                  }),
                  _menuButton(Icons.search, "ตรวจรางวัล", () {
                    _onTabTapped(3);
                  }),
                  _menuButton(Icons.account_balance_wallet, "ยอดเงิน", () {}),
                  _menuButton(Icons.logout, "ออกจากระบบ", () {
                    LogoutController().logout(context);
                  }),
                ],
              ),
            ],
          ),
        ),
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
                  color: const Color.fromARGB(255, 255, 255, 255),
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
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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

  Widget _menuButton(IconData icon, String title, VoidCallback onTap) {
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
            Icon(icon, size: 40, color: Colors.grey[500]),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.notoSansThai(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
