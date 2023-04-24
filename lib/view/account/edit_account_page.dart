import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_sns/model/account.dart';
import 'package:flutter_sns/utils/authentication.dart';
import 'package:flutter_sns/utils/firestore/users.dart';
import 'package:flutter_sns/utils/function_utils.dart';
import 'package:flutter_sns/utils/widget_utils.dart';
import 'package:flutter_sns/view/start_up/login_page.dart';
import 'package:image_picker/image_picker.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  Account myAccount = Authentication.myAccount!;
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfintoController = TextEditingController();

  //取得した画像を管理するための変数
  File? image;
  ImageProvider getImage() {
    if (image == null) {
      return NetworkImage(myAccount.imagePath);
    } else {
      return FileImage(image!);
    }
  }

  @override
  void initState() {
    //各Controller に初期値を入れていく
    nameController = TextEditingController(text: myAccount.name);
    userIdController = TextEditingController(text: myAccount.userId);
    selfintoController =
        TextEditingController(text: myAccount.selfIntroduction);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('プロフィール編集'),
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
                      foregroundImage: getImage(),
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
              const SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () async {
                    print('プッシュが確認されました');
                    if (nameController.text.isNotEmpty &&
                        userIdController.text.isNotEmpty &&
                        selfintoController.text.isNotEmpty) {
                      String imagePath = '';
                      if (image == null) {
                        //画像はそのまま
                        imagePath = myAccount.imagePath;
                      } else {
                        //新しい画像をあぷっロードする
                        var result = await FunctionUtils.uploadImage(
                            myAccount.id, image!);
                        imagePath = result;
                      }
                      Account updateAccount = Account(
                          id: myAccount.id,
                          name: nameController.text,
                          userId: userIdController.text,
                          selfIntroduction: selfintoController.text,
                          imagePath: imagePath);

                      Authentication.myAccount = updateAccount;
                      var result =
                          await UserFirestore.updateUser(updateAccount);
                      if (result) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  child: const Text('更新')),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {
                    Authentication.signOut();
                    //戻れなくなるまで戻る
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    //最後まで行ったら今までの遷移を消してログイン画面にいく
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('ログアウト')),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    UserFirestore.deleteUser(myAccount.id);
                    Authentication.deleteAuth();
                    //戻れなくなるまで戻る
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    //最後まで行ったら今までの遷移を消してログイン画面にいく
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('アカウント削除'))
            ],
          ),
        ),
      ),
    );
  }
}
