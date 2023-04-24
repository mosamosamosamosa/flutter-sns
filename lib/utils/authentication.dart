import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sns/model/account.dart';
import 'package:flutter_sns/utils/firestore/posts.dart';
import 'package:google_sign_in/google_sign_in.dart';

//ログインなどの処理
class Authentication {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static User? currentFirebaseUser;
  static Account? myAccount;

//新規登録
  static Future<dynamic> signUp(
      {required String email, required String pass}) async {
    print('signUp関数が呼び出されました');

    //tryキャッチで何でうまくいかなかったかわかるようにする
    try {
      UserCredential newAccount = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: pass);
      return newAccount;
      print('新規登録完了');
    } on FirebaseAuthException catch (e) {
      print('新規登録エラー: $e');
      return '登録エラーが発生しました';
    }
  }

  static Future<dynamic> emailSignIn(
      {required String email, required String pass}) async {
    try {
      final UserCredential _result = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: pass);
      currentFirebaseUser = _result.user;
      return _result;
      print("ログインできました");
    } on FirebaseAuthException catch (e) {
      print('ログイン失敗: $e');
      return false;
    }
  }

  //ログアウト処理
  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  //アカウント削除
  static Future<void> deleteAuth() async {
    await currentFirebaseUser!.delete();
  }

  static Future<dynamic> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        final UserCredential _result =
            await _firebaseAuth.signInWithCredential(credential);
        currentFirebaseUser = _result.user;
        print('Googleログイン完了');
        return _result;
      }
    } on FirebaseAuthException catch (e) {
      print('Googleログイン失敗');
      return false;
    }
  }
}
