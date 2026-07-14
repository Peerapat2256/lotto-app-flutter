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

  void _saveUserInfo() async {
    await storage.write(key: "username", value: _nameController.text);
    await storage.write(key: "email", value: _emailController.text);
    await storage.write(key: "dob", value: _dobController.text);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("บันทึกข้อมูลสำเร็จ", style: GoogleFonts.notoSansThai()),
        backgroundColor: const Color(0xFF00E676),
      ),
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          'โปรไฟล์ของฉัน',
          style: GoogleFonts.notoSansThai(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Profile circular avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB300), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withOpacity(0.15),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 54,
                  backgroundImage: NetworkImage(
                    "https://fiverr-res.cloudinary.com/image/upload/f_auto,q_auto,t_profile_small/v1/attachments/profile/photo/b91c25cc1491be439d52cd5bb915ad42-1753531201742/f0dd0529-b943-48d9-a82c-19d6ccf248f9.jpg",
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Inputs panel container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: "ชื่อผู้ใช้ (Name)",
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      label: "อีเมล (Email)",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    // Birthday DatePicker field
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFFFB300),
                                  onPrimary: Colors.black,
                                  surface: Color(0xFF1E293B),
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _dobController.text =
                                "${picked.day}/${picked.month}/${picked.year}";
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: IgnorePointer(
                        child: _buildTextField(
                          controller: _dobController,
                          label: "วันเดือนปีเกิด",
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save changes button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFB300),
                            Color(0xFFFF8F00),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8F00).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveUserInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "บันทึกข้อมูล",
                          style: GoogleFonts.notoSansThai(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.notoSansThai(fontSize: 13, color: Colors.blueGrey.shade400),
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade500),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFB300), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
