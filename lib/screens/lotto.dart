import 'package:flutter/material.dart';
import 'package:flutter_backend/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_backend/controllers/lotto_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart.dart';

class LottoPage extends StatelessWidget {
  final dynamic currentIndex;

  const LottoPage({super.key, this.currentIndex = 1});

  Widget _buildSearchRow(LottoController ctrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Container(
          width: 44,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ctrl.controllers[i].text.isNotEmpty 
                  ? const Color(0xFFFFB300) 
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: ctrl.controllers[i],
            focusNode: ctrl.focusNodes[i],
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFB300),
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) {
              if (v.length == 1 && i < 5) {
                ctrl.focusNodes[i + 1].requestFocus();
              }
              if (v.isEmpty && i > 0) {
                ctrl.focusNodes[i - 1].requestFocus();
              }
              ctrl.notifyListeners();
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LottoController(),
      child: Consumer<LottoController>(
        builder: (context, ctrl, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1E293B),
              elevation: 0,
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
                "ซื้อหวยออนไลน์",
                style: GoogleFonts.notoSansThai(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_rounded, color: Color(0xFFFFB300)),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                    await ctrl.fetchLotto();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: 16),
                
                // 🔹 Search Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: Color(0xFFFFB300), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "ค้นหาเลขเด็ดของคุณ",
                              style: GoogleFonts.notoSansThai(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                for (final c in ctrl.controllers) {
                                  c.clear();
                                }
                                ctrl.filtered = ctrl.allLotto;
                                ctrl.notifyListeners();
                              },
                              child: Text(
                                "ล้างค่า",
                                style: GoogleFonts.notoSansThai(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSearchRow(ctrl),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFB300),
                                Color(0xFFFF8F00),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: ctrl.applyFilter,
                            icon: const Icon(Icons.search_rounded, color: Colors.white),
                            label: Text(
                              "ค้นหาหมายเลข",
                              style: GoogleFonts.notoSansThai(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 🔹 Display list of lotteries
                Expanded(
                  child: ctrl.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFFFFB300),
                          backgroundColor: const Color(0xFF1E293B),
                          onRefresh: ctrl.fetchLotto,
                          child: ctrl.filtered.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  itemCount: ctrl.filtered.length,
                                  itemBuilder: (_, idx) {
                                    final row = ctrl.filtered[idx];
                                    return _buildTicketCard(context, row, ctrl);
                                  },
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.crop_original_rounded, size: 64, color: Colors.blueGrey.shade600),
              const SizedBox(height: 16),
              Text(
                "ไม่พบเลขสลากที่คุณค้นหา",
                style: GoogleFonts.notoSansThai(
                  color: Colors.blueGrey.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "ลองเปลี่ยนตัวเลขค้นหาด้านบนอีกครั้ง",
                style: GoogleFonts.notoSansThai(
                  color: Colors.blueGrey.shade500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> row, LottoController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB300).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative ticket notches
            Positioned(
              left: -10,
              top: 50,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -10,
              top: 50,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "สลากกินแบ่ง Drawly",
                          style: GoogleFonts.notoSansThai(
                            color: const Color(0xFFFFB300),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "${row['price']} บาท",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: const Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Ticket numbers layout
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: row['number']
                          .toString()
                          .split("")
                          .map<Widget>(
                            (digit) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Text(
                                digit,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider dashed
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "งวดวันที่ ${ctrl.formatThaiDate(row['draw_date'])}",
                        style: GoogleFonts.notoSansThai(
                          color: Colors.blueGrey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final res = await ctrl.selectLotto(row);
                            _showResultDialog(context, res['success'] == true, res['message'] ?? "เพิ่มลงตะกร้าแล้ว");
                          } catch (e) {
                            final s = e.toString();
                            final msg = s.contains("หวยนี้ถูกเลือก/ขายไปแล้ว")
                                ? "เลขนี้มีคนจองไปก่อนแล้ว ลองเลือกเลขอื่นนะ"
                                : "เกิดข้อผิดพลาด: ${s.replaceFirst('Exception: ', '')}";
                            _showResultDialog(context, false, msg);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB300),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        ),
                        child: Text(
                          "เลือกซื้อ",
                          style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, bool success, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.warning_rounded,
              color: success ? const Color(0xFF00E676) : Colors.redAccent,
            ),
            const SizedBox(width: 10),
            Text(
              success ? "สำเร็จ" : "แจ้งเตือน",
              style: GoogleFonts.notoSansThai(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.notoSansThai(color: Colors.blueGrey.shade300),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: success ? const Color(0xFF00E676) : const Color(0xFFFFB300),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
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