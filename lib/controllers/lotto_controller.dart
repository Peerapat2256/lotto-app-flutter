import 'package:flutter/material.dart';
import 'package:flutter_backend/service/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class LottoController extends ChangeNotifier {
  final ApiService api = ApiService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> allLotto = [];
  List<Map<String, dynamic>> filtered = [];

  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  int? userId;
  bool loading = false;

  LottoController() {
    initializeDateFormatting('th_TH', null);
    _initUser();
  }

  Future<void> _initUser() async {
    final idStr = await storage.read(key: 'user_id');
    userId = idStr != null ? int.tryParse(idStr) : null;
    await fetchLotto();
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

  Future<void> fetchLotto() async {
    loading = true;
    notifyListeners();
    try {
      final data = await api.getLottoList();
      allLotto = data;
      filtered = data;
    } catch (e) {
      debugPrint("โหลดหวยล้มเหลว: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String _pattern() {
    final buf = StringBuffer();
    for (final c in controllers) {
      if (c.text.trim().isEmpty) break;
      buf.write(c.text.trim());
    }
    return buf.toString();
  }

  bool _isSequential(String input) {
    if (input.length < 2) return false;
    for (int i = 0; i < input.length - 1; i++) {
      if (int.parse(input[i + 1]) != int.parse(input[i]) + 1) {
        return false;
      }
    }
    return true;
  }

  void applyFilter() {
    final pat = _pattern();
    if (pat.isEmpty) {
      filtered = allLotto;
    } else {
      filtered = allLotto.where((e) {
        final num = e['number'].toString();
        if (num.contains(pat)) return true;
        if (_isSequential(pat)) {
          for (int len = pat.length + 1; len <= 6; len++) {
            String extended = pat;
            int last = int.parse(pat[pat.length - 1]);
            for (int j = 1; j <= len - pat.length; j++) {
              extended += ((last + j) % 10).toString();
            }
            if (num.contains(extended)) return true;
          }
        }
        return false;
      }).toList();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> selectLotto(Map<String, dynamic> lotto) async {
    if (userId == null) {
      return {"success": false, "message": "กรุณาล็อกอินใหม่ (ไม่พบ user_id)"};
    }
    try {
      final res = await api.createPurchase(userId!, lotto['lotto_id']);
      if (res['success'] == true) {
        await fetchLotto();
        return {"success": true, "message": "เพิ่มเข้าตะกร้าแล้ว ✅"};
      }
      return {
        "success": false,
        "message": res['message'] ?? "เกิดข้อผิดพลาดไม่ทราบสาเหตุ",
      };
    } catch (e) {
      final s = e.toString();
      // ✅ จัดการข้อความเฉพาะกรณีนี้
      if (s.contains("หวยนี้ถูกเลือก/ขายไปแล้ว")) {
        return {
          "success": false,
          "message": "เลขนี้มีคนจองไปก่อนแล้ว ลองเลือกเลขอื่นนะ",
        };
      }
      return {
        "success": false,
        "message": "เกิดข้อผิดพลาด: ${s.replaceFirst('Exception: ', '')}",
      };
    }
  }
}
