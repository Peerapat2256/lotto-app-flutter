import 'package:flutter/material.dart';
import 'package:flutter_backend/models/md_respone.dart';
import 'package:flutter_backend/service/api_service.dart';

class RegisterController extends ChangeNotifier {
  bool _showPassword = false;
  bool get showPassword => _showPassword;

  late BuildContext _context;

  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  TextEditingController walletController = TextEditingController(text: "");
  TextEditingController nameContrller = TextEditingController(text: "");

  ApiService apiService = ApiService();

  void eyePassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void setContext(inContext) {
    _context = inContext;
  }

  Future<void> register() async {
    print("register");
    try {
      double wallet = 0.0;
      if (walletController.text.isNotEmpty) {
        wallet = double.tryParse(walletController.text) ?? 0.0;
      }
      final data = {
        "name": nameContrller.text,
        "email": emailController.text,
        "password": passwordController.text,
        "wallet": wallet,
      };

      final response = await apiService.postRequest("/user/register", data, token: '');
      MdRespone dataRespont = MdRespone.fromJson(response);
      if (dataRespont.status == "success") {
        showDialog(
          context: _context,
          builder: (BuildContext context) => StatefulBuilder(
            builder: (context, setState) => LayoutBuilder(
              builder: (context, constraints) {
                return AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.info, color: Colors.green),
                      SizedBox(
                        width: 8,
                      ), // เพิ่มช่องว่างเล็ก ๆ ระหว่าง icon กับ text
                      Text(
                        "Success",
                        style: TextStyle(
                          fontFamily: "Sriracha",
                          color: Colors.green,
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
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      } else {
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
                      SizedBox(
                        width: 8,
                      ), // เพิ่มช่องว่างเล็ก ๆ ระหว่าง icon กับ text
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
      print(e);
    }
  }
}
