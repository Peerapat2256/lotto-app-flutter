import 'package:flutter/material.dart';
import 'package:flutter_backend/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_backend/controllers/lotto_controller.dart';
import 'cart.dart';

class LottoPage extends StatelessWidget {
  final dynamic currentIndex;

  const LottoPage({super.key, this.currentIndex = 1});

  Widget _buildSearchRow(LottoController ctrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Container(
          width: 40,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: TextField(
            controller: ctrl.controllers[i],
            focusNode: ctrl.focusNodes[i],
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              counterText: '',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) {
              if (v.length == 1 && i < 5) {
                ctrl.focusNodes[i + 1].requestFocus();
              }
              if (v.isEmpty && i > 0) {
                ctrl.focusNodes[i - 1].requestFocus();
              }
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

              title: const Text("ซื้อหวย"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                    await ctrl.fetchLotto();
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: 8),
                // 🔹 หัวข้อค้นหา
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        "ค้นหาเลขเด็ด",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                        child: const Text("ล้างคำ"),
                      ),
                    ],
                  ),
                ),
                _buildSearchRow(ctrl),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: ctrl.applyFilter,
                    icon: const Icon(Icons.search),
                    label: const Text("ค้นหาหมายเลข"),

                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 🔹 แสดงรายการหวย
                Expanded(
                  child: ctrl.loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: ctrl.fetchLotto,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: ctrl.filtered.length,
                            itemBuilder: (_, idx) {
                              final row = ctrl.filtered[idx];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 🔹 บรรทัดที่ 1: หัวข้อ "สลาก"
                                      const Text(
                                        "สลาก",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // 🔹 บรรทัดที่ 2: เลขหวย (ซ้าย) + ราคา (ขวา)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: row['number']
                                                .toString()
                                                .split("")
                                                .map<Widget>(
                                                  (digit) => Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 2,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.yellow[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      digit,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                          Text(
                                            "${row['price']} บาท",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.pinkAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // 🔹 บรรทัดที่ 3: งวดที่ (ซ้าย) + ปุ่มเลือก (ขวา)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "งวดวันที่ ${ctrl.formatThaiDate(row['draw_date'])}",
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              try {
                                                final res = await ctrl
                                                    .selectLotto(row);

                                                if (res['success'] == true) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: const Text(
                                                        "สำเร็จ",
                                                      ),
                                                      content: Text(
                                                        res['message'] ??
                                                            "เพิ่มลงตะกร้าแล้ว",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            "ตกลง",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: const Text(
                                                        "แจ้งเตือน",
                                                      ),
                                                      content: Text(
                                                        res['message'] ??
                                                            "เกิดข้อผิดพลาด",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            "ตกลง",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                final s = e.toString();
                                                final msg =
                                                    s.contains(
                                                      "หวยนี้ถูกเลือก/ขายไปแล้ว",
                                                    )
                                                    ? "เลขนี้มีคนจองไปก่อนแล้ว ลองเลือกเลขอื่นนะ"
                                                    : "เกิดข้อผิดพลาด: ${s.replaceFirst('Exception: ', '')}";

                                                showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text(
                                                      "แจ้งเตือน",
                                                    ),
                                                    content: Text(msg),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          "ตกลง",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.blue,
                                              side: const BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            child: const Text("เลือก"),
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
              ],
            ),
          );
        },
      ),
    );
  }
}