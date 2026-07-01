import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_backend/controllers/cart_controller.dart';
import 'package:flutter_backend/screens/home.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartController(),
      child: Consumer<CartController>(
        builder: (context, ctrl, _) {
          final title = ctrl.loading
              ? "ตะกร้า (กำลังโหลด...)"
              : "ตรวจสอบรายการ";

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomePage(currentIndex: 0),
                    ),
                  );
                },
              ),
              title: Text(title),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            body: Column(
              children: [
                // ✅ รายการสลาก
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: ctrl.fetchCart,
                    child: ctrl.items.isEmpty
                        ? const Center(child: Text("ยังไม่มีรายการสลาก"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: ctrl.items.length,
                            itemBuilder: (_, idx) {
                              final it = ctrl.items[idx];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 🔹 แถวบน → เลข + ราคา
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "สลาก ${it['number']}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${it['price']} บาท",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.pink,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // 🔹 แถวล่าง → งวด + ปุ่มเอาออก
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                           const SizedBox(width: 6),
                                          OutlinedButton(
                                            onPressed: () async {
                                              final msg = await ctrl
                                                  .cancelItem(it['purchase_id']);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(content: Text(msg)),
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: Colors.blue),
                                              foregroundColor: Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: const Text("เอาออก"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                // ✅ สรุปยอดรวม + ปุ่มชำระเงิน
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "ยอดชำระทั้งหมด ${ctrl.total.toStringAsFixed(2)} บาท",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: ctrl.items.isEmpty
                            ? null
                            : () async {
                                final result = await ctrl.checkout();
                                if (result['success'] == true) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("ชำระเงินสำเร็จ"),
                                      content: Text(
                                        "ก่อน: ${result['wallet_before']}\n"
                                        "เหลือ: ${result['wallet_after']}",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(
                                              context,
                                            ).pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const HomePage(),
                                              ),
                                              (route) => false,
                                            );
                                          },
                                          child: const Text("ตกลง"),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result['message'] ??
                                            "ชำระเงินไม่สำเร็จ",
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "ชำระเงิน",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
