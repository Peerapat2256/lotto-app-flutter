import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_backend/service/api_service.dart';

class GenerateLottoController extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  bool isLoading = false;
  String message = "";

  Future<void> generateLotto({int count = 100}) async {
    try {
      isLoading = true;
      message = "";
      notifyListeners();

      String? token = await storage.read(key: "accessToken");
      if (token == null) {
        message = "Token ไม่พบ, กรุณาเข้าสู่ระบบใหม่";
        return;
      }

      final response = await apiService.postRequest(
        "/admin/generate-lotto-batch",
        {"count": count},
        token: token,
      );

      if (response['status'] == "success") {
        message = response['message'] ?? "สร้างล็อตโต้สำเร็จ";
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
