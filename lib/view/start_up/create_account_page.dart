import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_sns/model/account.dart';
import 'package:flutter_sns/utils/authentication.dart';
import 'package:flutter_sns/utils/firestore/users.dart';
import 'package:flutter_sns/utils/function_utils.dart';
import 'package:flutter_sns/utils/widget_utils.dart';
import 'package:flutter_sns/view/screen.dart';
import 'package:flutter_sns/view/start_up/check_email_page.dart';
import 'package:image_picker/image_picker.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key, this.isSignInWithGoogle = false});

  final bool isSignInWithGoogle;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfintoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  //取得した画像を管理するための変数
  File? image;
  // ImagePicker picker = ImagePicker();

  //IOSのみ許可の記述がいる
  //フォルダから選んだ画像を読みとる
  // Future<void> getImageFromGallery() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       image = File(pickedFile.path);
  //     });
  //   }
  // }

  //firebase storage に画像を保存する
  // Future<String> uploadImage(String uid) async {
  //   final FirebaseStorage storageInstance = FirebaseStorage.instance;
  //   final Reference ref = storageInstance.ref();
  //   await ref.child(uid).putFile(image!);
  //   //保存されたURL
  //   String downloadUrl = await storageInstance.ref(uid).getDownloadURL();
  //   print('image_path: $downloadUrl');
  //   return downloadUrl;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('新規登録'),
      //キーボードが出てきてもエラーが出ない
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 30),
              GestureDetector(
                  onTap: () async {
                    var result = await FunctionUtils.getImageFromGallery();
                    if (result != null) {
                      setState(() {
                        image = File(result.path);
                      });
                    }
                  },
                  child: CircleAvatar(
                      foregroundImage: image == null ? null : FileImage(image!),
                      radius: 40,
                      child: Icon(Icons.add))),
              Container(
                width: 300,
                child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: '名前')),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                width: 300,
                child: TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(hintText: 'ユーザーID')),
              ),
              Container(
                width: 300,
                child: TextField(
                    controller: selfintoController,
                    decoration: const InputDecoration(hintText: '自己紹介')),
              ),
              widget.isSignInWithGoogle
                  ? Container()
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          width: 300,
                          child: TextField(
                              controller: emailController,
                              decoration:
                                  const InputDecoration(hintText: 'メールアドレス')),
                        ),
                        Container(
                          width: 300,
                          child: TextField(
                              controller: passController,
                              decoration:
                                  const InputDecoration(hintText: 'パスワード')),
                        ),
                      ],
                    ),
              const SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () async {
                    print('プッシュが確認されました');
                    if (nameController.text.isNotEmpty &&
                        userIdController.text.isNotEmpty &&
                        selfintoController.text.isNotEmpty &&
                        image != null) {
                      if (widget.isSignInWithGoogle) {
                        var _result = await createdAccount(
                            Authentication.currentFirebaseUser!.uid);
                        if (_result) {
                          await UserFirestore.getUser(
                              Authentication.currentFirebaseUser!.uid);
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => Screen())));
                        }
                      }
                      var result = await Authentication.signUp(
                          email: emailController.text,
                          pass: passController.text);
                      if (result is UserCredential) {
                        var _result = await createdAccount(result.user!.uid);
                        if (_result) {
                          //登録したメールアドレスが本当に使えるかどうか認証する
                          result.user!.sendEmailVerification();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CheckEmailPage(
                                      email: emailController.text,
                                      pass: passController.text)));
                        }
                      }
                    }
                  },
                  child: const Text('アカウント作成'))
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> createdAccount(String uid) async {
    String imagePath = await FunctionUtils.uploadImage(uid, image!);
    Account newAccount = Account(
        id: uid,
        name: nameController.text,
        userId: userIdController.text,
        selfIntroduction: selfintoController.text,
        imagePath: imagePath);
    //値を送る
    var _result = await UserFirestore.setUser(newAccount);
    return _result;
  }
}
