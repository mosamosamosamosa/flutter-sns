//投稿に関する情報を管理する

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  //投稿内容
  String content;
  //誰が投稿したのか
  String postAccountId;
  Timestamp? createdTime;

  Post(
      {this.id = '',
      this.content = '',
      this.postAccountId = '',
      this.createdTime});
}
