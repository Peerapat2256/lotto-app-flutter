import 'package:flutter/material.dart';
import 'package:flutter_backend/controllers/generatelotto_controller.dart';
import 'package:flutter_backend/controllers/logout_controller.dart';
import 'package:flutter_backend/controllers/reset_controllor.dart';
import 'package:flutter_backend/screens/lotto_draw_page.dart';
import 'package:flutter_backend/screens/sold_lotto_addmin.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C6FBB),
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text(
          "ระบบลอตโต้(แอดมิน)",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 20,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LottoDrawPage(),
                    ),
                  );
                },
                child: _buildMenuCard(Icons.emoji_events, "ออกรางวัล"),
              ),
              InkWell(
                onTap: () async {
                  bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Row(
                        children: const [
                          Icon(Icons.refresh, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            "รีเซ็ทระบบ",
                            style: TextStyle(
                              fontFamily: "Sriracha",
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        "คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตระบบ? ข้อมูลทั้งหมดจะถูกลบ ยกเว้นแอดมิน",
                        style: TextStyle(fontFamily: "Sriracha"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "ยกเลิก",
                            style: TextStyle(
                              fontFamily: "Sriracha",
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "ยืนยัน",
                            style: TextStyle(
                              fontFamily: "Sriracha",
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm) {
                    final controller = SystemResetController();
                    await controller.resetSystem();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              "สำเร็จ",
                              style: TextStyle(
                                fontFamily: "Sriracha",
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          controller.message,
                          style: const TextStyle(fontFamily: "Sriracha"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "OK",
                              style: TextStyle(
                                fontFamily: "Sriracha",
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: _buildMenuCard(Icons.refresh, "รีเซ็ตระบบ"),
              ),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LotterySoldPage(),
                    ),
                  );
                },
                child: _buildMenuCard(Icons.shopping_bag, "ขายออก"),
              ),
              InkWell(
                onTap: () async {
                  TextEditingController countController = TextEditingController(
                    text: "100",
                  );

                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: const [SizedBox(width: 8), Text("เพิ่มสลาก")],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("กรุณากรอกจำนวนสลากที่ต้องการสร้าง:"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: countController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "จำนวนล็อตโต้",
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("ยกเลิก"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("ยืนยัน"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final controller = GenerateLottoController();
                    int count = int.tryParse(countController.text) ?? 100;
                    await controller.generateLotto(count: count);

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text("ผลลัพธ์"),
                          ],
                        ),
                        content: Text(controller.message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: _buildMenuCard(Icons.add, "เพิ่มสลาก"),
              ),

              InkWell(
                onTap: () {
                  print("Logout success");
                  LogoutController().logout(context);
                },
                child: _buildMenuCard(Icons.logout, "ออกจากระบบ"),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildMenuCard(IconData icon, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey[700]),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
