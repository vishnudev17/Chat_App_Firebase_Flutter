import 'package:chat_app_firebase/pages/login_page.dart';
import 'package:chat_app_firebase/pages/registration_page.dart';
import 'package:flutter/cupertino.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});
  @override
  State<StatefulWidget> createState() {
    return _LoginOrRegister();
  }
}

class _LoginOrRegister extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegistrationPage(onTap: togglePages);
    }
  }
}
