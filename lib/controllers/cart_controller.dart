
import 'package:flutter/material.dart';
import 'package:flutter_backend/service/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class CartController extends ChangeNotifier {
  final ApiService api = ApiService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> items = [];
  int? userId;
  bool loading = false;

  CartController() {
    _initUser();
    initializeDateFormatting('th_TH', null); 
  }

  Future<void> _initUser() async {
    debugPrint("hellocart controller");
    final idStr = await storage.read(key: 'user_id');
    userId = idStr != null ? int.tryParse(idStr) : null;
    debugPrint("cart_controller userid = $userId");
    // debugPrint("_initUser userId ===== $userId");
    if (userId != null) await fetchCart();
  }

  String formatThaiDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "ยังไม่ประกาศรางวัล";
    try {
      DateTime date = DateTime.parse(dateStr);
      final thaiYear = date.year + 543;
      return "${date.day} ${DateFormat.MMMM('th_TH').format(date)} $thaiYear";
    } catch (e) {
      return "ยังไม่ประกาศรางวัล";
    }
  }

 

  Future<void> fetchCart() async {
   debugPrint("hello fetchCart cart_controller userid = $userId");
    if (userId == null) return;
    loading = true;
    notifyListeners();
    try {
      final data = await api.getCart(userId!);
      debugPrint(" fetchCart raw data = $data");



      // ✅ แปลง draw_date เป็นภาษาไทยก่อนเก็บ
      items = data.map<Map<String, dynamic>>((item) {
        return {
          ...item,
          "draw_date": item['draw_date'] != null
              ? formatThaiDate(item['draw_date'])
              : null,
        };
      }).toList();
    } catch (e) {
      debugPrint("โหลดตะกร้าล้มเหลว: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  double get total {
    return items.fold(0, (sum, e) => sum + (e['price'] as num).toDouble());
  }

  Future<String> cancelItem(int purchaseId) async {
    try {
      await api.cancelPurchase(purchaseId);
      await fetchCart();
      return "ยกเลิกรายการแล้ว";
    } catch (e) {
      return "ยกเลิกล้มเหลว: $e";
    }
  }

  Future<Map<String, dynamic>> checkout() async {
    if (userId == null) {
      return {"success": false, "message": "กรุณาล็อกอินใหม่"};
    }
    try {
      final result = await api.checkout(userId!);
      if (result['success'] == true) {
        if (result['wallet_after'] != null) {
          await storage.write(
            key: "wallet",
            value: result['wallet_after'].toString(),
          );
        }
        await fetchCart();
      }
      return result;
    } catch (e) {
      return {"success": false, "message": "ชำระเงินล้มเหลว: $e"};
    }
  }
}
