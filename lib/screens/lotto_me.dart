import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_backend/controllers/lotto_me_controller.dart';

class LottoMePage extends StatelessWidget {
  const LottoMePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LottoMeController(),
      child: Consumer<LottoMeController>(
        builder: (context, ctrl, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1E293B),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'สลากของฉัน',
                style: GoogleFonts.notoSansThai(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            ),
            body: ctrl.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                    ),
                  )
                : ctrl.purchases.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: const Color(0xFFFFB300),
                        backgroundColor: const Color(0xFF1E293B),
                        onRefresh: ctrl.fetchPurchases,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          itemCount: ctrl.purchases.length,
                          itemBuilder: (_, idx) {
                            final p = ctrl.purchases[idx];
                            return _buildPurchasedTicket(context, p, ctrl);
                          },
                        ),
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
          Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.blueGrey.shade600),
          const SizedBox(height: 16),
          Text(
            "ยังไม่มีประวัติการซื้อสลาก",
            style: GoogleFonts.notoSansThai(
              color: Colors.blueGrey.shade400,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "สลากที่คุณสั่งซื้อจะแสดงรายการที่นี่",
            style: GoogleFonts.notoSansThai(
              color: Colors.blueGrey.shade500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasedTicket(BuildContext context, Map<String, dynamic> p, LottoMeController ctrl) {
    bool hasWon = ctrl.isWinner(p);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasWon ? const Color(0xFF00E676).withOpacity(0.4) : const Color(0xFFFFB300).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative Notches
            Positioned(
              left: -10,
              top: 48,
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
              top: 48,
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasWon 
                              ? const Color(0xFF00E676).withOpacity(0.12)
                              : const Color(0xFFFFB300).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hasWon ? "ถูกรางวัล 🎉" : "ลอตเตอรี่สะสมโชค",
                          style: GoogleFonts.notoSansThai(
                            color: hasWon ? const Color(0xFF00E676) : const Color(0xFFFFB300),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "${p['lotto_price']} บาท",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ticket Numbers
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: p['lotto_number']
                          .toString()
                          .split('')
                          .map(
                            (digit) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 18),

                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "งวดวันที่ ${ctrl.formatThaiDate(p['draw_date'])}",
                            style: GoogleFonts.notoSansThai(
                              color: Colors.blueGrey.shade400,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "รหัสสลาก: #${p['lotto_id'] ?? 'N/A'}",
                            style: GoogleFonts.poppins(
                              color: Colors.blueGrey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "ซื้อสำเร็จ",
                          style: GoogleFonts.notoSansThai(
                            color: const Color(0xFFFFB300),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Display Win Details and Cashed details
                  if (hasWon && p['prizes_list'] != null) ...[
                    const SizedBox(height: 16),
                    ...p['prizes_list'].map<Widget>((prize) {
                      bool cashed = ctrl.isCashed(p, prize);
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cashed 
                              ? Colors.white.withOpacity(0.05) 
                              : const Color(0xFF00E676).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cashed ? Colors.white.withOpacity(0.1) : const Color(0xFF00E676).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cashed ? Icons.check_circle_outline_rounded : Icons.monetization_on_outlined,
                              color: cashed ? Colors.blueGrey.shade400 : const Color(0xFF00E676),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cashed
                                    ? "รางวัลที่ ${prize['prize_rank']} (${ctrl.formatPrize(prize['prize_amount'])} ฿) - รับเงินแล้ว"
                                    : "ถูกรางวัลที่ ${prize['prize_rank']} (${ctrl.formatPrize(prize['prize_amount'])} ฿) - ยังไม่ได้รับเงิน",
                                style: GoogleFonts.notoSansThai(
                                  color: cashed ? Colors.blueGrey.shade400 : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}