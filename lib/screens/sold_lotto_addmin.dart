import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_backend/controllers/sold_lotto_admin_controllor.dart';

class LotterySoldPage extends StatefulWidget {
  const LotterySoldPage({super.key});

  @override
  State<LotterySoldPage> createState() => _LotterySoldPageState();
}

class _LotterySoldPageState extends State<LotterySoldPage> {
  late SoldLottoAdminController controller;

  @override
  void initState() {
    super.initState();
    controller = SoldLottoAdminController();
    controller.fetchLotto();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          toolbarHeight: 80,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "จัดการรายการสลาก",
            style: GoogleFonts.notoSansThai(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFFFFB300),
            indicatorWeight: 3,
            labelColor: const Color(0xFFFFB300),
            unselectedLabelColor: Colors.blueGrey.shade400,
            labelStyle: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.notoSansThai(fontWeight: FontWeight.normal, fontSize: 14),
            onTap: (index) {
              controller.setSelectedType(index == 0 ? "sold" : "available");
            },
            tabs: const [
              Tab(text: "รายการขายออกแล้ว"),
              Tab(text: "รายการที่ยังไม่ขาย"),
            ],
          ),
        ),
        body: controller.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                ),
              )
            : TabBarView(
                children: [
                  SoldListView(isSold: true, tickets: controller.soldLotto),
                  SoldListView(
                    isSold: false,
                    tickets: controller.availableLotto,
                  ),
                ],
              ),
      ),
    );
  }
}

class SoldListView extends StatelessWidget {
  final bool isSold;
  final List<Map<String, dynamic>> tickets;
  const SoldListView({super.key, required this.isSold, required this.tickets});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.blueGrey.shade600),
            const SizedBox(height: 12),
            Text(
              "ไม่มีรายการสลาก",
              style: GoogleFonts.notoSansThai(
                fontSize: 16,
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final number = (ticket["lotto_number"] ?? "").toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSold ? Colors.redAccent.withOpacity(0.1) : const Color(0xFF00E676).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isSold ? "ขายออกแล้ว" : "พร้อมจำหน่าย",
                              style: GoogleFonts.notoSansThai(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSold ? Colors.redAccent : const Color(0xFF00E676),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "ชุดที่ ${ticket['lotto_id'] ?? '-'}",
                            style: GoogleFonts.notoSansThai(fontSize: 13, color: Colors.blueGrey.shade400),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: number
                            .split('')
                            .map(
                              (digit) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                      const SizedBox(height: 12),
                      Text(
                        "งวดวันที่ ${ticket['draw_date'] ?? '-'}",
                        style: GoogleFonts.notoSansThai(fontSize: 13, color: Colors.blueGrey.shade400),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${ticket['price'] ?? '80'}",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFFB300),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      "บาท",
                      style: GoogleFonts.notoSansThai(fontSize: 13, color: Colors.blueGrey.shade400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
