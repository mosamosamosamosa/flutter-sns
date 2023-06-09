import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_sns/utils/authentication.dart';
import 'package:flutter_sns/utils/firestore/users.dart';
import 'package:flutter_sns/utils/widget_utils.dart';
import 'package:flutter_sns/view/screen.dart';
import 'package:flutter_sns/view/start_up/create_account_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: visible
          ? WidgetUtils().createProgressIndicator()
          : Container(
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'もさもさ SNS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Container(
                      width: 300,
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(hintText: 'メールアドレス'),
                      ),
                    ),
                  ),
                  Container(
                    width: 300,
                    child: TextField(
                      controller: passController,
                      decoration: const InputDecoration(hintText: 'パスワード'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                        const TextSpan(text: 'アカウントを作成していない方は'),
                        TextSpan(
                            text: 'こちら',
                            style: const TextStyle(color: Colors.blue),
                            //タップした時の処理を書くことができる
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateAccountPage()));
                              }),
                      ])),
                  const SizedBox(height: 70),
                  ElevatedButton(
                      onPressed: () async {
                        print('ログインボタンがタップされました');
                        var result = await Authentication.emailSignIn(
                            email: emailController.text,
                            pass: passController.text);
                        if (result is UserCredential) {
                          if (result.user!.emailVerified) {
                            var _result =
                                await UserFirestore.getUser(result.user!.uid);
                            if (_result) {
                              print('_result帰ってきました');
                              print('ログインの全てが完了');
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Screen()));
                            }
                          } else {
                            print('メールアドレス認証が完了していません');
                            setState(() {
                              visible = true;
                            });
                            // Container(
                            //     decoration: new BoxDecoration(
                            //       color: Color.fromRGBO(0, 0, 0, 0.6),
                            //     ),
                            //     child: Column(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: <Widget>[
                            //         CircularProgressIndicator(
                            //             valueColor: new AlwaysStoppedAnimation<Color>(
                            //                 Colors.white))
                            //       ],
                            //     ));
                          }
                        }
                      },
                      child: const Text('emailでログイン')),
                  SignInButton(Buttons.Google, onPressed: () async {
                    var result = await Authentication.signInWithGoogle();
                    if (result is UserCredential) {
                      var result = await UserFirestore.getUser(
                          Authentication.currentFirebaseUser!.uid);
                      if (result) {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Screen()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateAccountPage()));
                      }
                    }
                  })
                ],
              ),
            ),
    ));
  }
}
