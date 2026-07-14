import 'package:flutter/material.dart';
import 'package:flutter_backend/controllers/register_controller.dart';
import 'package:flutter_backend/screens/login.dart';
import 'package:flutter_backend/screens/admin_register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    final myController = Provider.of<RegisterController>(context);
    myController.setContext(context);

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Premium Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Header
                  Text(
                    'สมัครสมาชิก',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'กรอกข้อมูลส่วนตัวเพื่อเข้าร่วมระบบหวยออนไลน์',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔹 Registration Card
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: myController.nameContrller,
                          hintText: "ชื่อผู้ใช้",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: myController.emailController,
                          hintText: "อีเมล",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: myController.passwordController,
                          hintText: "รหัสผ่าน",
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: myController.walletController,
                          hintText: "จำนวนเงินเริ่มต้น",
                          icon: Icons.account_balance_wallet_outlined,
                          keyboardType: TextInputType.number,
                          suffixText: "บาท",
                        ),
                        const SizedBox(height: 30),

                        // Register Button
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFB300), // Gold
                                Color(0xFFFF8F00),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8F00).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              myController.register();
                            },
                            child: Text(
                              "สมัครบัญชี",
                              style: GoogleFonts.notoSansThai(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Back to login Link
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            "เข้าสู่ระบบ",
                            style: GoogleFonts.notoSansThai(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                        
                        // Admin Register Dialog Button
                        TextButton(
                          onPressed: () => _showAdminPasscodeDialog(context),
                          child: Text(
                            "สมัครสมาชิกสำหรับ Admin",
                            style: GoogleFonts.notoSansThai(
                              fontSize: 14,
                              color: const Color(0xFFFF8F00),
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  void _showAdminPasscodeDialog(BuildContext context) {
    final passcodeController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: Text(
            "ยืนยันสิทธิ์ Admin",
            style: GoogleFonts.notoSansThai(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "กรุณากรอกรหัสผ่าน Admin เพื่อดำเนินการสมัครสมาชิก",
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  color: Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passcodeController,
                obscureText: true,
                style: GoogleFonts.notoSansThai(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "รหัสผ่าน Admin",
                  hintStyle: GoogleFonts.notoSansThai(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFFFB300)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "ยกเลิก",
                style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade400),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (passcodeController.text == "admin088") {
                  Navigator.pop(dialogContext); // close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => RegisterController(),
                        child: const AdminRegisterPage(),
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "รหัสผ่านไม่ถูกต้อง",
                        style: GoogleFonts.notoSansThai(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                "ยืนยัน",
                style: GoogleFonts.notoSansThai(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.notoSansThai(fontSize: 15, color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
        hintText: hintText,
        hintStyle: GoogleFonts.notoSansThai(
          fontSize: 15,
          color: Colors.white.withOpacity(0.4),
        ),
        suffixText: suffixText,
        suffixStyle: GoogleFonts.notoSansThai(
          fontSize: 15,
          color: Colors.white.withOpacity(0.6),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFFFB300),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}
