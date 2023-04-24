import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sns/utils/authentication.dart';
import 'package:flutter_sns/utils/firestore/users.dart';
import 'package:flutter_sns/utils/widget_utils.dart';
import 'package:flutter_sns/view/screen.dart';

class CheckEmailPage extends StatefulWidget {
  const CheckEmailPage({super.key, required this.email, required this.pass});

  final String email;
  final String pass;

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('メールアドレスを確認'),
      body: Column(
        children: [
          Text('登録いただいたメールアドレス宛に確認のメールを送信しました。\n確認してください'),
          ElevatedButton(
              onPressed: () async {
                //ログイn処理
                var result = await Authentication.emailSignIn(
                    email: widget.email, pass: widget.pass);
                if (result is UserCredential) {
                  if (result.user!.emailVerified) {
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    await UserFirestore.getUser(result.user!.uid);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Screen()));
                  } else {
                    print('メール認証が終わってません');
                  }
                }
              },
              child: Text('認証完了'))
        ],
      ),
    );
  }
}
