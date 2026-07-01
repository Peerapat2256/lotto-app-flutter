
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final int currentIndex;
  const ProfilePage({super.key, this.currentIndex = 0});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController =
      TextEditingController(text: "01/01/2000");

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// โหลดข้อมูลจาก SecureStorage
  void _loadUserInfo() async {
    final username = await storage.read(key: "username");
    final email = await storage.read(key: "email");
    final dob = await storage.read(key: "dob");

    setState(() {
      _nameController.text = username ?? "";
      _emailController.text = email ?? "";
      _dobController.text = dob ?? "01/01/2000";
    });
  }

  /// บันทึกข้อมูลลง SecureStorage
  void _saveUserInfo() async {
    await storage.write(key: "username", value: _nameController.text);
    await storage.write(key: "email", value: _emailController.text);
    await storage.write(key: "dob", value: _dobController.text);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("บันทึกข้อมูลสำเร็จ")),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 12, 111, 187),
        title: Text(
          'โปรไฟล์',
          style: GoogleFonts.notoSansThai(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // รูปโปรไฟล์วงกลม
              GestureDetector(
                onTap: () {},
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    "https://fiverr-res.cloudinary.com/image/upload/f_auto,q_auto,t_profile_small/v1/attachments/profile/photo/b91c25cc1491be439d52cd5bb915ad42-1753531201742/f0dd0529-b943-48d9-a82c-19d6ccf248f9.jpg",
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ชื่อ
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: GoogleFonts.poppins(),
                  border: const UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // อีเมล
              TextFormField(
                controller: _emailController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.poppins(),
                  border: const UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // วันเดือนปีเกิด (ใช้ DatePicker)
              TextFormField(
                controller: _dobController,
                readOnly: true,
                style: GoogleFonts.poppins(),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dobController.text =
                          "${picked.day}/${picked.month}/${picked.year}";
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: "วันเดือนปีเกิด",
                  labelStyle: GoogleFonts.notoSansThai(),
                  border: const UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // ปุ่มบันทึก
              ElevatedButton(
                onPressed: _saveUserInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 111, 187),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "บันทึก",
                  style: GoogleFonts.notoSansThai(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
