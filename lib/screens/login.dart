import 'package:flutter/material.dart';
import 'package:flutter_backend/controllers/login_controller.dart';
import 'package:flutter_backend/controllers/register_controller.dart';
import 'package:flutter_backend/screens/register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mycontroller = Provider.of<LoginController>(context);
    mycontroller.setContext(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 40,
                      ),
                      child: Column(
                        children: [
                          // 🔹 Logo / Title
                          Text(
                            'Drawly',
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3D3C3D),
                            ),
                          ),

                          const SizedBox(height: 50),

                          // 🔹 Username / Email
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 80.0,
                              left: 15,
                              right: 15,
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: mycontroller.emailController,
                                  enabled: !mycontroller.loading,
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'อีเมล หรือ ชื่อผู้ใช้',
                                    hintStyle: GoogleFonts.notoSansThai(
                                      fontSize: 16,
                                      color: const Color.fromARGB(
                                          255, 72, 72, 72),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal: 20.0,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // 🔹 Password
                                TextField(
                                  controller: mycontroller.passwordContrller,
                                  obscureText: true,
                                  enabled: !mycontroller.loading,
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'รหัสผ่าน',
                                    hintStyle: GoogleFonts.notoSansThai(
                                      fontSize: 16,
                                      color: const Color.fromARGB(
                                          255, 72, 72, 72),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal: 20.0,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // 🔹 Login button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: mycontroller.loading
                                        ? null
                                        : () {
                                            mycontroller.login();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                        12,
                                        111,
                                        187,
                                        1.0,
                                      ),
                                      disabledBackgroundColor:
                                          Colors.grey.shade400,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                    ),
                                    child: mycontroller.loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'เข้าสู่ระบบ',
                                            style: GoogleFonts.notoSansThai(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // 🔹 Register button
                                TextButton(
                                  onPressed: mycontroller.loading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider(
                                                create: (_) =>
                                                    RegisterController(),
                                                child: const RegisterPage(),
                                              ),
                                            ),
                                          );
                                        },
                                  child: Text(
                                    'สร้างบัญชีใหม่',
                                    style: GoogleFonts.notoSansThai(
                                        color: mycontroller.loading
                                            ? Colors.grey
                                            : Colors.black,
                                        fontSize: 16),
                                  ),
                                ),
                              ],
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
          // Loading Overlay
          if (mycontroller.loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromRGBO(12, 111, 187, 1.0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'กำลังเข้าสู่ระบบ...',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3D3C3D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}