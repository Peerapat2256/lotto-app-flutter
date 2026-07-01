import 'package:flutter/material.dart';
import 'package:flutter_backend/controllers/register_controller.dart';
import 'package:flutter_backend/screens/login.dart';
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
      body: Container(
        color: Colors.white,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ปุ่ม Back
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Drawly',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3D3C3D),
                  ),
                ),
                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
                  child: Column(
                    children: [
                      _buildTextField(myController.nameContrller, "ชื่อผู้ใช้"),
                      const SizedBox(height: 16),
                      _buildTextField(myController.emailController, "อีเมล"),
                      const SizedBox(height: 16),
                      _buildTextField(
                        myController.passwordController,
                        "รหัสผ่าน",
                        obscureText: true,
                      ),

                      const SizedBox(height: 16),
                      _buildTextField(
                        myController.walletController,
                        "กรอกจำนวนเงินเริ่มต้น",
                        keyboardType: TextInputType.number,
                        suffixText: "บาท",
                      ),

                      const SizedBox(height: 30),

                      // สมัคร
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C6FBB),
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
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

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
                            fontSize: 16,
                            color: Colors.black87,
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
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.notoSansThai(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.notoSansThai(
          fontSize: 16,
          color: const Color.fromARGB(
            255,
            72,
            72,
            72,
          ), // ฟอนต์ hint ก็ใช้ notoSansThai
        ),
        suffixText: suffixText,
        suffixStyle: GoogleFonts.notoSansThai(
          fontSize: 16,
          color: Colors.black,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
