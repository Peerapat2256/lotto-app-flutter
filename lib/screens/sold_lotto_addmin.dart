import 'package:flutter/material.dart';
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
        appBar: AppBar(
          backgroundColor: const Color(0xFF0C6FBB),
          toolbarHeight: 80,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          title: const Text(
            "ขายออก",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            onTap: (index) {
              controller.setSelectedType(index == 0 ? "sold" : "available");
            },
            tabs: const [
              Tab(text: "รายการขายออก"),
              Tab(text: "รายการที่ยังไม่ขาย"),
            ],
          ),
        ),
        body: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
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
      return const Center(
        child: Text(
          "ไม่มีสลาก",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          final number = (ticket["lotto_number"] ?? "").toString();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "สลาก",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: number
                              .split('')
                              .map(
                                (digit) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      244,
                                      232,
                                      131,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    digit,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "ชุดที่ ${ticket['lotto_id'] ?? '-'}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "งวดวันที่ ${ticket['draw_date'] ?? '-'}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "${ticket['price'] ?? '-'}",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 236, 172, 193),
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      const Text(
                        "บาท",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
