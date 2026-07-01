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
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: Text(
                'สลากของฉัน',
                style: GoogleFonts.notoSansThai(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 25,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 12, 111, 187),
              elevation: 0,
            ),
            body: ctrl.loading
                ? const Center(child: CircularProgressIndicator())
                : ctrl.purchases.isEmpty
                    ? const Center(child: Text("ยังไม่มีประวัติการซื้อ"))
                    : RefreshIndicator(
                        onRefresh: ctrl.fetchPurchases,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: ctrl.purchases.length,
                          itemBuilder: (_, idx) {
                            final p = ctrl.purchases[idx];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  // Main Card
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Header
                                          Text(
                                            "สลาก งวดที่",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            ctrl.formatThaiDate(p['draw_date']),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Lotto Number and Price
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "สลาก",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color:
                                                            Colors.amber[300]!,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: p['lotto_number']
                                                          .toString()
                                                          .split('')
                                                          .map(
                                                            (digit) =>
                                                                Container(
                                                              width: 29,
                                                              height: 45,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          2),
                                                              child: Center(
                                                                child: Text(
                                                                  digit,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        35,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  const SizedBox(height: 28),
                                                  Text(
                                                    "${p['lotto_price']}",
                                                    style: const TextStyle(
                                                      fontSize: 40,
                                                      color: Color.fromARGB(
                                                          255, 249, 182, 190),
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "บาท ",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color.fromARGB(
                                                          255, 106, 106, 106),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Bottom info
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "งวดที่",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color.fromARGB(
                                                          255, 42, 42, 42),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    ctrl.formatDrawDate(
                                                        p['draw_date']),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  const Text(
                                                    "ชุดที่ ",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color.fromARGB(
                                                          255, 0, 0, 0),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  
                                                  Text(
                                                    "${p['lotto_id'] ?? '35'}   ",
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // แสดงรางวัลทั้งหมด
                                  if (ctrl.isWinner(p))
                                    Column(
                                      children: [
                                        for (var prize in p['prizes_list'])
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 4),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: ctrl.isCashed(p, prize)
                                                  ? Colors.amber[100]
                                                  : Colors.green[400],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                ctrl.isCashed(p, prize)
                                                    ? "รางวัลที่ ${prize['prize_rank']} จำนวน ${ctrl.formatPrize(prize['prize_amount'])} บาท (ขึ้นเงินรางวัลเเล้ว) "
                                                    : "ถูกรางวัลที่ ${prize['prize_rank']} จำนวน ${ctrl.formatPrize(prize['prize_amount'])} บาท (ยังไม่ขึ้นเงินรางวัล)",
                                                style: TextStyle(
                                                  color: ctrl.isCashed(p, prize)
                                                      ? Colors.black87
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          );
        },
      ),
    );
  }
}