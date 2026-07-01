import 'package:flutter/material.dart';
import 'package:flutter_backend/service/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SystemResetController extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  bool isLoading = false;
  String message = "";

  // เรียก API รีเซ็ตระบบ
  Future<void> resetSystem() async {
    try {
      isLoading = true;
      message = "";
      notifyListeners();

      String? token = await storage.read(key: "accessToken");
      if (token == null) {
        message = "Token ไม่พบ, กรุณาเข้าสู่ระบบใหม่";
        return;
      }

      final response = await apiService.postRequest("/reset", {}, token: token);

      if (response['status'] == "success") {
        message = response['message'] ?? "ระบบรีเซ็ตเรียบร้อย";
      } else {
        message = response['message'] ?? "เกิดข้อผิดพลาด";
      }
    } catch (e) {
      message = "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
