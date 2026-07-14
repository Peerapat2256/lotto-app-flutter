import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_backend/controllers/cart_controller.dart';
import 'package:flutter_backend/screens/home.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartController(),
      child: Consumer<CartController>(
        builder: (context, ctrl, _) {
          final title = ctrl.loading
              ? "กำลังโหลดข้อมูล..."
              : "ตรวจสอบรายการซื้อ";

          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomePage(currentIndex: 0),
                    ),
                  );
                },
              ),
              title: Text(
                title,
                style: GoogleFonts.notoSansThai(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              backgroundColor: const Color(0xFF1E293B),
              elevation: 0,
              centerTitle: true,
            ),
            body: Column(
              children: [
                // ✅ List of Tickets in Cart
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFFFFB300),
                    backgroundColor: const Color(0xFF1E293B),
                    onRefresh: ctrl.fetchCart,
                    child: ctrl.items.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            itemCount: ctrl.items.length,
                            itemBuilder: (_, idx) {
                              final it = ctrl.items[idx];
                              return _buildCartItemCard(context, it, ctrl);
                            },
                          ),
                  ),
                ),

                // ✅ Payment Summary Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ยอดเงินรวม:",
                              style: GoogleFonts.notoSansThai(
                                color: Colors.blueGrey.shade400,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "${ctrl.total.toStringAsFixed(2)} บาท",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFB300),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: ctrl.items.isEmpty
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFFFB300),
                                      Color(0xFFFF8F00),
                                    ],
                                  ),
                            color: ctrl.items.isEmpty ? Colors.blueGrey.shade700 : null,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: ctrl.items.isEmpty
                                ? null
                                : () async {
                                    final result = await ctrl.checkout();
                                    if (result['success'] == true) {
                                      _showSuccessDialog(context, result);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result['message'] ?? "ชำระเงินไม่สำเร็จ",
                                            style: GoogleFonts.notoSansThai(),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "ยืนยันสั่งชำระเงิน",
                              style: GoogleFonts.notoSansThai(
                                fontSize: 16,
                                color: ctrl.items.isEmpty ? Colors.blueGrey.shade400 : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.blueGrey.shade600),
          const SizedBox(height: 16),
          Text(
            "ไม่มีรายการสลากในตะกร้า",
            style: GoogleFonts.notoSansThai(
              color: Colors.blueGrey.shade400,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "คุณสามารถเลือกซื้อหวยได้จากเมนูด้านหน้า",
            style: GoogleFonts.notoSansThai(
              color: Colors.blueGrey.shade500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, Map<String, dynamic> it, CartController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "สลากหมายเลข",
                  style: GoogleFonts.notoSansThai(
                    color: Colors.blueGrey.shade400,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "${it['price']} บาท",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display digit numbers beautifully
                Row(
                  children: it['number']
                      .toString()
                      .split("")
                      .map<Widget>(
                        (digit) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            digit,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: () async {
                    final msg = await ctrl.cancelItem(it['purchase_id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg, style: GoogleFonts.notoSansThai()),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676)),
            const SizedBox(width: 10),
            Text(
              "ชำระเงินสำเร็จ",
              style: GoogleFonts.notoSansThai(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          "ยอดเงินก่อนหน้า: ${result['wallet_before']} บาท\n"
          "ยอดเงินคงเหลือ: ${result['wallet_after']} บาท",
          style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade300, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const HomePage(),
                ),
                (route) => false,
              );
            },
            child: Text(
              "ตกลง",
              style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
