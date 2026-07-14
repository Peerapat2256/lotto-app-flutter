import 'package:flutter_backend/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl;
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? Config.baseUrl;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Future<dynamic> getRequest(String endPoint, {required String token}) async {
  //   final respons = await http.get(
  //     Uri.parse('$baseUrl$endPoint'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (respons.statusCode == 200) {
  //     return json.decode(respons.body);
  //   } else {
  //     print("Failed GET $endPoint, status: ${respons.statusCode}");
  //     print("Body: ${respons.body}");
  //     throw Exception("Failed to load data");
  //   }
  // }

  // Future<dynamic> postRequest(
  //   String endPoint,
  //   Map<String, dynamic> data, {
  //   String? token,
  // }) async {
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  //   };

  //   final respons = await http.post(
  //     Uri.parse('$baseUrl$endPoint'),
  //     headers: headers,
  //     body: json.encode(data),
  //   );

  //   if (respons.statusCode == 200 || respons.statusCode == 201) {
  //     return json.decode(respons.body);
  //   } else {
  //     throw Exception("Failed to load data: ${respons.body}");
  //   }
  // }

  // Future<dynamic> putRequest(String endPoint, Map<String, dynamic> data) async {
  //   final respons = await http.put(
  //     Uri.parse('$baseUrl$endPoint'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(data),
  //   );

  //   if (respons.statusCode == 200) {
  //     return json.decode(respons.body);
  //   } else {
  //     throw Exception("Failed to load data");
  //   }
  // }

  // Future<dynamic> deleteRequest(
  //   String endPoint,
  //   Map<String, dynamic> data,
  // ) async {
  //   final respons = await http.delete(Uri.parse('$baseUrl$endPoint'));

  //   if (respons.statusCode == 200) {
  //     return json.decode(respons.body);
  //   } else {
  //     throw Exception("Failed to load data");
  //   }
  // }

  /////////////////fix////////////////////////

  // ---------------- Internal helper ----------------
  Future<Map<String, String>> _buildHeaders({
    bool withAuth = false,
    String? token,
  }) async {
    final actualToken =
        token ??
        (withAuth ? (await storage.read(key: 'accessToken') ?? '') : '');
    return {
      'Content-Type': 'application/json',
      if (actualToken.isNotEmpty) 'Authorization': 'Bearer $actualToken',
    };
  }

  dynamic _handleResponse(http.Response response) {
    try {
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        throw Exception(
          "Request failed (${response.statusCode}): "
          "${body is Map && body['message'] != null ? body['message'] : response.body}",
        );
      }
    } catch (e) {
      throw Exception(
        "Invalid response (${response.statusCode}): ${response.body}",
      );
    }
  }

  // ---------------- Base HTTP methods ----------------
  Future<dynamic> getRequest(
    String endPoint, {
    bool withAuth = false,
    String? token,
  }) async {
    final headers = await _buildHeaders(withAuth: withAuth, token: token);
    final response = await http.get(
      Uri.parse('$baseUrl$endPoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> postRequest(
    String endPoint,
    Map<String, dynamic> data, {
    bool withAuth = false,
    String? token,
  }) async {
    final headers = await _buildHeaders(withAuth: withAuth, token: token);
    final response = await http.post(
      Uri.parse('$baseUrl$endPoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patchRequest(
    String endPoint,
    Map<String, dynamic> data, {
    bool withAuth = false,
    String? token,
  }) async {
    final headers = await _buildHeaders(withAuth: withAuth, token: token);
    final response = await http.patch(
      Uri.parse('$baseUrl$endPoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> putRequest(
    String endPoint,
    Map<String, dynamic> data, {
    bool withAuth = false,
    String? token,
  }) async {
    final headers = await _buildHeaders(withAuth: withAuth, token: token);
    final response = await http.put(
      Uri.parse('$baseUrl$endPoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> deleteRequest(
    String endPoint, {
    bool withAuth = false,
    String? token,
  }) async {
    final headers = await _buildHeaders(withAuth: withAuth, token: token);
    final response = await http.delete(
      Uri.parse('$baseUrl$endPoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // ---------------- Convenience functions ----------------
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> data) async {
    return await postRequest('/user/register', data);
  }

  Future<Map<String, dynamic>> loginUser(Map<String, dynamic> data) async {
    final res = await postRequest('/user/login', data);
    if (res is Map<String, dynamic> && res['status'] == 'success') {
      if (res['data'] != null) {
        await storage.write(
          key: 'accessToken',
          value: res['data']['accessToken'],
        );
        await storage.write(
          key: 'refreshToken',
          value: res['data']['refreshToken'],
        );
        await storage.write(key: 'email', value: res['data']['email']);
        await storage.write(
          key: 'wallet',
          value: res['data']['wallet'].toString(),
        );
        await storage.write(key: 'username', value: res['data']['username']);
        await storage.write(
          key: 'user_id',
          value: res['data']['user_id'].toString(),
        );
      }
      return res;
    }
    throw Exception("Login failed: $res");
  }

  Future<Map<String, dynamic>> refreshToken() async {
    final refreshToken = await storage.read(key: 'refreshToken') ?? '';
    if (refreshToken.isEmpty)
      throw Exception("No refreshToken found in storage");
    return await postRequest('/user/refreshtoken', {
      'refreshToken': refreshToken,
    });
  }

  Future<Map<String, dynamic>> logout() async {
    final refreshToken = await storage.read(key: 'refreshToken') ?? '';
    final res = await postRequest('/user/logout', {
      'refreshToken': refreshToken,
    }, withAuth: true);
    await storage.deleteAll();
    return res;
  }

  Future<Map<String, dynamic>> getUserProfile(
    String email, {
    bool withAuth = true,
    String? token,
  }) async {
    final encoded = Uri.encodeComponent(email);
    final res = await getRequest(
      '/user/$encoded',
      withAuth: withAuth,
      token: token,
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception("Invalid response format for getUserProfile: $res");
  }

  Future<List<Map<String, dynamic>>> getLottoList({
    bool withAuth = true,
    String? token,
  }) async {
    final res = await getRequest('/lotto', withAuth: withAuth, token: token);
    print('Response from /lotto: $res');

    if (res is Map && res['data'] is List) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  Future<Map<String, dynamic>> createPurchase(
    int userId,
    int lottoId, {
    bool withAuth = true,
    String? token,
  }) async {
    final res = await postRequest(
      '/api/purchases',
      {"user_id": userId, "lotto_id": lottoId},
      withAuth: withAuth,
      token: token,
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception("Invalid response from createPurchase: $res");
  }

  Future<Map<String, dynamic>> cancelPurchase(
    int purchaseId, {
    bool withAuth = true,
    String? token,
  }) async {
    final res = await patchRequest(
      '/api/purchases/$purchaseId/cancel',
      {},
      withAuth: withAuth,
      token: token,
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception("Invalid response from cancelPurchase: $res");
  }

  Future<List<Map<String, dynamic>>> getCart(
    int userId, {
    bool withAuth = true,
    String? token,
  }) async {
    final res = await getRequest(
      '/api/cart?user_id=$userId',
      withAuth: withAuth,
      token: token,
    );

    // กรณี backend ส่ง List ตรง ๆ (เผื่อไว้)
    if (res is List) {
      return List<Map<String, dynamic>>.from(res);
    }

    // กรณี backend ส่ง { success, data }
    if (res is Map<String, dynamic>) {
      if (res['success'] == true && res['data'] is List) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      // ถ้าไม่ success ให้โยน error ออกไปจะได้เห็นสาเหตุ
      if (res['success'] == false) {
        throw Exception(res['message'] ?? 'โหลดตะกร้าไม่สำเร็จ');
      }
    }

    throw Exception('Unexpected cart response: ${res.runtimeType}');
  }

  Future<Map<String, dynamic>> checkout(
    int userId, {
    bool withAuth = true,
    String? token,
  }) async {
    final res = await postRequest(
      '/api/checkout',
      {"user_id": userId},
      withAuth: withAuth,
      token: token,
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception("Invalid response from checkout: $res");
  }

  Future<List<Map<String, dynamic>>> getUserPurchases({
    bool withAuth = true,
    String? token,
  }) async {
    final userId = await storage.read(key: 'user_id');

    print("getUserPurchases apiservice  = $userId");

    if (userId == null) return [];

    final res = await getRequest(
      '/api/purchases/$userId',
      withAuth: withAuth,
      token: token,
    );

    print("API getUserPurchases Response = $res");

    if (res is Map<String, dynamic> &&
        res['success'] == true &&
        res['purchases'] != null) {
      return List<Map<String, dynamic>>.from(res['purchases']);
    }
    return [];
  }

  Future<Map<String, dynamic>> claimPrize(
    int lottoId, {
    bool withAuth = true,
    String? token,
  }) async {
    final res = await postRequest(
      '/api/claim-prize',
      {"lotto_id": lottoId},
      withAuth: withAuth,
      token: token,
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception("Invalid response from claimPrize: $res");
  }
}
