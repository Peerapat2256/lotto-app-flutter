import 'dart:developer';
import 'package:flutter_backend/service/api_service.dart';

/// Model สำหรับผลรางวัล
class CheckprizePageControllerModel {
  String status;
  String message;
  List<Datum> data;

  CheckprizePageControllerModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CheckprizePageControllerModel.fromJson(Map<String, dynamic> json) =>
      CheckprizePageControllerModel(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

/// Model ของแต่ละรางวัล
class Datum {
  String number;
  String prizeAmount;
  int prizeRank;
  int lotto_id;

  Datum({
    required this.number,
    required this.prizeAmount,
    required this.prizeRank,
    required this.lotto_id,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    number: json["number"],
    prizeAmount: json["prize_amount"],
    prizeRank: json["prize_rank"],
    lotto_id: json["lotto_id"],
  );

  Map<String, dynamic> toJson() => {
    "number": number,
    "prize_amount": prizeAmount,
    "prize_rank": prizeRank,
    // "lotto_id": lotto_id,
  };
}

class CheckprizePageController {
  ApiService apiService = ApiService();

  // โหลดผลรางวัลตามงวด
  Future<CheckprizePageControllerModel> getPrizeByDate(DateTime date) async {
    try {
      String formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final response = await apiService.postRequest("/lotto/prize", {
        "drawdate": formattedDate,
      }, token: '');
      return CheckprizePageControllerModel.fromJson(response);
    } catch (e) {
      throw Exception("Error fetching prize: $e");
    }
  }

  // ตรวจรางวัลด้วยหมายเลข
  Future<CheckprizePageControllerModel> checkPrizeByNumber(
    String number,
    DateTime date,
    String username,
  ) async {
    try {
      String formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final response = await apiService.postRequest("/lotto/checkprize", {
        "number": number,
        "drawdate": formattedDate,
        "username": username,
      }, token: '');
      // log("username = ${username}number = ${number}drawdate = $formattedDate");

      log("API Response: $response");
      log("username = $username, number = $number, drawdate = $formattedDate");
      return CheckprizePageControllerModel.fromJson(response);
    } catch (e) {
      throw Exception("Error checking prize: $e");
    }
  }

  Future<Map<String, dynamic>> claimPrize(int lottoId) async {
    log("claimPrize lottoid: $lottoId");

    try {
      final response = await apiService.claimPrize(lottoId, withAuth: true);
      return response;
    } catch (e) {
      throw Exception("Error claiming prize: $e");
    }
  }
}
