import 'package:flutter/material.dart';
import 'package:flutter_backend/service/api_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class LottoMeController extends ChangeNotifier {
  final ApiService api = ApiService();

  List<Map<String, dynamic>> purchases = [];
  bool loading = false;

  LottoMeController() {
    initializeDateFormatting('th_TH', null);
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    loading = true;
    notifyListeners();
    try {
      final data = await api.getUserPurchases();

      // แปลง data ให้แต่ละสลากมีรางวัลเป็น List
      purchases = data.map((p) {
        List<Map<String, dynamic>> prizes = [];
        if (p['prizes'] != null && p['prizes'] is List) {
          prizes = List<Map<String, dynamic>>.from(p['prizes']);
        } else if (p['prize_rank'] != null) {
          prizes = [
            {
              'prize_rank': p['prize_rank'],
              'prize_amount': p['prize_amount'],
              'lotto_status': p['lotto_status'],
            }
          ];
        }
        return {
          ...p,
          'prizes_list': prizes,
        };
      }).toList();
    } catch (e) {
      debugPrint("โหลดประวัติไม่สำเร็จ: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
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

  String formatDrawDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "ยังไม่ประกาศรางวัล";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')} ${_getThaiMonthShort(date.month)} ${date.year + 543}";
    } catch (e) {
      return "ยังไม่ประกาศรางวัล";
    }
  }

  String _getThaiMonthShort(int month) {
    const months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return months[month];
  }

  // เช็คว่าถูกรางวัลหรือไม่
  bool isWinner(Map<String, dynamic> purchase) {
    return (purchase['prizes_list'] as List).isNotEmpty;
  }

  // เช็คว่าขึ้นเงินรางวัลแล้วหรือไม่
 bool isCashed(Map<String, dynamic> purchase, [Map<String, dynamic>? prize]) {
  prize ??= (purchase['prizes_list'] as List).isNotEmpty
      ? (purchase['prizes_list'] as List).first as Map<String, dynamic>
      : null;

  if (prize == null) return false;

  final status = prize['lotto_status'];
  if (status == null) return false;

  return status.toString() == 'cashed';
}


  // format จำนวนเงินรางวัล
String formatPrize(dynamic amount) {
  final value = double.tryParse(amount?.toString() ?? '0') ?? 0;
  
  return switch (value) {
    >= 1000000 => '${_formatDecimal(value / 1000000)} ล้าน',
    >= 1000 => '${_formatDecimal(value / 1000)} พัน',
    _ => _formatDecimal(value),
  };
}

String _formatDecimal(double number) {
  return number % 1 == 0 
    ? number.toInt().toString() 
    : number.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
}
}
