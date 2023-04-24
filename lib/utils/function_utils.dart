import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FunctionUtils {
  //共通して使うメソッドをまとめる

  //IOSのみ許可の記述がいる
  //フォルダから選んだ画像を読みとる
  static Future<dynamic> getImageFromGallery() async {
    ImagePicker picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    return pickedFile;
    // if (pickedFile != null) {
    //   setState(() {
    //     image = File(pickedFile.path);
    //   });
    // }
  }

  //firebase storage に画像を保存する
  static Future<String> uploadImage(String uid, File image) async {
    final FirebaseStorage storageInstance = FirebaseStorage.instance;
    final Reference ref = storageInstance.ref();
    await ref.child(uid).putFile(image);
    //保存されたURL
    String downloadUrl = await storageInstance.ref(uid).getDownloadURL();
    print('image_path: $downloadUrl');
    return downloadUrl;
  }
}
