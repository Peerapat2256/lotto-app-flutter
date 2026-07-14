import 'package:flutter/material.dart';
import 'package:flutter_backend/controllers/register_controller.dart';
import 'package:flutter_backend/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
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
                    'สมัครบัญชี Admin',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFB300), // Gold for Admin label
                    ),
                  ),
                  Text(
                    'เข้าสู่ระบบแอดมินสำหรับจัดการหวย',
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
                          hintText: "ชื่อผู้ใช้ (Admin)",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: myController.emailController,
                          hintText: "อีเมล Admin",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: myController.passwordController,
                          hintText: "รหัสผ่าน Admin",
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
                              myController.register(role: 'admin');
                            },
                            child: Text(
                              "สมัครบัญชี Admin",
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
