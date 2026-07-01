import 'package:flutter/material.dart';
import 'package:flutter_backend/models/md_respone.dart';
import 'package:flutter_backend/service/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SoldLottoAdminController extends ChangeNotifier {
  ApiService apiService = ApiService();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  List<Map<String, dynamic>> soldLotto = [];
  List<Map<String, dynamic>> availableLotto = [];
  bool isLoading = false;

  String selectedType = "sold";

  void setSelectedType(String type) {
    selectedType = type;
    notifyListeners();
  }

  String _formatThaiDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoDate);
      final buddhistYear = date.year + 543;
      const thaiMonths = [
        '',
        'มกราคม',
        'กุมภาพันธ์',
        'มีนาคม',
        'เมษายน',
        'พฤษภาคม',
        'มิถุนายน',
        'กรกฎาคม',
        'สิงหาคม',
        'กันยายน',
        'ตุลาคม',
        'พฤศจิกายน',
        'ธันวาคม',
      ];
      final monthName = thaiMonths[date.month];
      return '${date.day} $monthName $buddhistYear';
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> fetchLotto() async {
    try {
      isLoading = true;
      notifyListeners();

      String? token = await storage.read(key: "accessToken");
      if (token == null) return;

      final soldResponse = await apiService.getRequest(
        "/lotto-admin-sold?type=sold",
        token: token,
      );
      MdRespone soldData = MdRespone.fromJson(soldResponse);
      if (soldData.status == "success") {
        soldLotto = List<Map<String, dynamic>>.from(soldData.data ?? [])
            .map(
              (item) => {
                ...item,
                "draw_date": _formatThaiDate(item["draw_date"]),
              },
            )
            .toList();
        print("Sold Lotto List: $soldLotto");
      }

      final availableResponse = await apiService.getRequest(
        "/lotto-admin-sold?type=available",
        token: token,
      );
      MdRespone availableData = MdRespone.fromJson(availableResponse);
      if (availableData.status == "success") {
        availableLotto =
            List<Map<String, dynamic>>.from(availableData.data ?? [])
                .map(
                  (item) => {
                    ...item,
                    "draw_date": _formatThaiDate(item["draw_date"]),
                  },
                )
                .toList();
        print("Available Lotto List: $availableLotto");
      }
    } catch (e) {
      print("Fetch lotto error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get displayedLotto =>
      selectedType == "sold" ? soldLotto : availableLotto;

  @override
  Widget build(BuildContext context) => Container();
}
