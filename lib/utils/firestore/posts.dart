import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sns/model/post.dart';

class PostFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  //postsコレクションの値を撮ってくる
  static final CollectionReference posts =
      _firestoreInstance.collection('posts');

  //投稿を追加するメソッド
  static Future<dynamic> addPost(Post newPost) async {
    try {
      //みんなのpostたちに追加
      final CollectionReference _userPosts = _firestoreInstance
          .collection('users')
          .doc(newPost.postAccountId)
          .collection('my_posts');
      var result = await posts.add({
        'content': newPost.content,
        'post_account_id': newPost.postAccountId,
        'created_time': Timestamp.now()
      });
      //みんなのpostたちに追加し生成されたidを用いて自分のpostたちに追加する
      _userPosts
          .doc(result.id)
          .set({'post_id': result.id, 'created_time': Timestamp.now()});
      print('投稿完了');
      return true;
    } on FirebaseException catch (e) {
      print('投稿失敗: $e');
      return false;
    }
  }

  //users>postのidからpostを拾ってくるメソッド
  static Future<List<Post>?> getPostsFromIds(List<String> ids) async {
    List<Post> postList = [];
    try {
      await Future.forEach(ids, (String id) async {
        var doc = await posts.doc(id).get();
        //オブジェクト型をMap型に変換
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Post post = Post(
            id: doc.id,
            content: data['content'],
            postAccountId: data['post_account_id'],
            createdTime: data['created_time']);
        postList.add(post);
      });
      return postList;
      print('自分の投稿取得完了');
    } on FirebaseException catch (e) {
      return null;
      print('自分の投稿取得エラー :$e');
    }
  }

  //ユーザが削除された際のそのユーザの投稿削除処理
  static Future<dynamic> deletePosts(String accountId) async {
    final CollectionReference _userPosts = _firestoreInstance
        .collection('users')
        .doc(accountId)
        .collection('my_posts');
    var snapshot = await _userPosts.get();
    snapshot.docs.forEach((doc) async {
      //post、　mypostどちらからも消す
      await posts.doc(doc.id).delete();
      _userPosts.doc(doc.id).delete();
    });
  }
}
