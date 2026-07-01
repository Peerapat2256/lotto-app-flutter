import 'package:flutter/material.dart';
import 'package:flutter_backend/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_backend/controllers/login_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LoginController())],
      // ignore: sort_child_properties_last
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: const LoginPage(),
      ),
    );
  }
}
