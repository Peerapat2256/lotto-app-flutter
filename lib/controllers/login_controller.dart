import 'package:flutter/material.dart';
import 'package:flutter_backend/screens/admin.dart';
import 'package:flutter_backend/screens/home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_backend/service/api_service.dart';
import 'package:flutter_backend/models/md_respone.dart';

class LoginController extends ChangeNotifier {
  bool _showPassword = false;
  bool get showPassword => _showPassword;

  bool _loading = false;
  bool get loading => _loading;

  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController passwordContrller = TextEditingController(text: "");
  TextEditingController useridContrller = TextEditingController(text: "");
  late BuildContext _context;

  ApiService apiService = ApiService();

  void eyePassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void setContext(inContext) {
    _context = inContext;
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void login() async {
    //validate
    //email
    //password
    
    _setLoading(true);
    
    try {
      final data = {
        "email": emailController.text,
        "password": passwordContrller.text,
        "userid": useridContrller.text,
      };

      final response = await apiService.postRequest(
        "/user/login",
        data,
        token: '',
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
      print("API Response: $response");
      MdRespone dataRespont = MdRespone.fromJson(response);

      if (dataRespont.status == "success") {
        print("Login success");

        final storage = FlutterSecureStorage();

        await storage.write(
          key: "accessToken",
          value: response["data"]["accessToken"],
        );
        await storage.write(
          key: "refreshToken",
          value: response["data"]["refreshToken"],
        );

        await storage.write(
          key: "username",
          value: response["data"]["username"].toString(),
        );
        await storage.write(
          key: "wallet",
          value: response["data"]["wallet"].toString(),
        );
        await storage.write(
          key: "email",
          value: response["data"]["email"].toString(),
        );
        await storage.write(
          key: "user_id",
          value: response["data"]["userid"].toString(),
        );
        // print(response["data"]["wallet"]);
        // print(response["data"]["username"]);
        final role = response["data"]["role"];

        _setLoading(false);

        if (role == "admin") {
          Navigator.push(
            _context,
            MaterialPageRoute(builder: (context) => Admin()),
          );
        } else {
          Navigator.push(
            _context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } else {
        _setLoading(false);
        
        print("Login faild");
        print(dataRespont.message);

        showDialog(
          context: _context,
          builder: (BuildContext context) => StatefulBuilder(
            builder: (context, setState) => LayoutBuilder(
              builder: (context, constraints) {
                return AlertDialog(
                  title: Row(
                    children: const [
                      Icon(
                        Icons.info,
                        color: Color.fromARGB(255, 232, 110, 102),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Warring",
                        style: TextStyle(
                          fontFamily: "Sriracha",
                          color: Color.fromARGB(255, 232, 110, 102),
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    dataRespont.message,
                    style: const TextStyle(fontFamily: "Sriracha"),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          fontFamily: "Sriracha",
                          color: Color.fromARGB(255, 232, 110, 102),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      _setLoading(false);
      print(e);
      
      String errorMessage = "เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่อีกครั้ง";
      
      // Check if timeout error
      if (e.toString().contains('timeout') || e.toString().contains('Connection timeout')) {
        errorMessage = "หมดเวลาการเชื่อมต่อ กรุณาตรวจสอบอินเทอร์เน็ตและลองใหม่อีกครั้ง";
      }
      
      // แสดง error dialog
      showDialog(
        context: _context,
        builder: (BuildContext context) => AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.error,
                color: Color.fromARGB(255, 232, 110, 102),
              ),
              SizedBox(width: 8),
              Text(
                "Error",
                style: TextStyle(
                  fontFamily: "Sriracha",
                  color: Color.fromARGB(255, 232, 110, 102),
                ),
              ),
            ],
          ),
          content: Text(
            errorMessage,
            style: const TextStyle(fontFamily: "Sriracha"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  fontFamily: "Sriracha",
                  color: Color.fromARGB(255, 232, 110, 102),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}