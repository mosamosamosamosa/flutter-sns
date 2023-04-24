import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sns/model/account.dart';
import 'package:flutter_sns/utils/authentication.dart';
import 'package:flutter_sns/utils/firestore/posts.dart';

class UserFirestore {
  static final _firebaseInstance = FirebaseFirestore.instance;
  //ユーザコレクションの値を撮ってくる
  static final CollectionReference users =
      _firebaseInstance.collection('users');

  //ユーザをデータベースに保存する
  static Future<dynamic> setUser(Account newAccount) async {
    try {
      //新く作るユーザーのID というアカウントをつくる
      await users.doc(newAccount.id).set({
        'name': newAccount.name,
        'user_od': newAccount.userId,
        'self_intriduction': newAccount.selfIntroduction,
        'image_path': newAccount.imagePath,
        'created_time': Timestamp.now(),
        'updated_time': Timestamp.now()
      });
      print('新規ユーザ作成完了');
      return true;
    } on FirebaseException catch (e) {
      print('新規ユーザエラー : $e');
      return false;
    }
  }

  //アカウントを取得するメソッド
  static Future<dynamic> getUser(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(uid).get();
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      Account myAccount = Account(
          id: uid,
          name: data['name'],
          userId: data['user_od'],
          selfIntroduction: data['self_intriduction'],
          imagePath: data['image_path'],
          createdTime: data['created_time'],
          updatedTime: data['updated_time']);

      //今作ったmyAcount を入れてあげる
      Authentication.myAccount = myAccount;
      print('取得完了');
      return true;
    } on FirebaseException catch (e) {
      print('取得失敗：$e');
      return false;
    }
  }

  //ユーザ更新メソッド
  static Future<dynamic> updateUser(Account updateAccount) async {
    try {
      await users.doc(updateAccount.id).update({
        'name': updateAccount.name,
        'image_path': updateAccount.imagePath,
        'user_od': updateAccount.userId,
        'self_intriduction': updateAccount.selfIntroduction,
        'updated_time': Timestamp.now()
      });
      print('更新完了');
      return true;
    } on FirebaseException catch (e) {
      print('更新失敗 : $e');
      return false;
    }
  }

  //投稿主を取得
  static Future<Map<String, Account>?> getPostUserMap(
      List<String> accountIds) async {
    Map<String, Account> map = {};
    try {
      await Future.forEach(accountIds, (String accountId) async {
        var doc = await users.doc(accountId).get();
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Account postAccount = Account(
            id: accountId,
            name: data['name'],
            userId: data['user_od'],
            imagePath: data['image_path'],
            selfIntroduction: data['self_intriduction'],
            createdTime: data['created_time'],
            updatedTime: data['updated_time']);
        map[accountId] = postAccount;
      });
      print('投稿ユーザの情報取得完了');
      return map;
    } on FirebaseException catch (e) {
      print('投稿ユーザ情報の取得失敗 : $e');
      return null;
    }
  }

  //ユーザ削除処理
  static Future<dynamic> deleteUser(String accountId) async {
    await users.doc(accountId).delete();
    PostFirestore.deletePosts(accountId);
  }
}
