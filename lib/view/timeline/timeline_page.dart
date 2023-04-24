import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_sns/model/account.dart';
import 'package:flutter_sns/model/post.dart';
import 'package:flutter_sns/utils/firestore/posts.dart';
import 'package:flutter_sns/utils/firestore/users.dart';
import 'package:flutter_sns/view/timeline/post_page.dart';
import 'package:intl/intl.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  // Account myAccount = Account(
  //     id: '1',
  //     name: 'もさもさ',
  //     selfIntroduction: 'ECCコンピュータ専門学校の4年生のもさもさです！\nよろしくお願いします',
  //     userId: 'mosamosa1234',
  //     imagePath:
  //         'https://s3-ap-northeast-1.amazonaws.com/qiita-organization-image/108c90d24f6f2f4de278dc60682eb5b232a88a87/original.jpg?1591627628',
  //     createdTime: Timestamp.now(),
  //     updatedTime: Timestamp.now());

  //以前はdatabase.dartに入れていた仮のデータ
  // List<Post> postList = [
  //   Post(
  //       id: '1',
  //       content: 'SNS始めました！\nよろしくお願いします><',
  //       postAccountId: '1',
  //       createdTime: Timestamp.now()),
  //   Post(
  //       id: '2',
  //       content: '授業嫌だなあ',
  //       postAccountId: '1',
  //       createdTime: Timestamp.now())
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'タイムライン',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: PostFirestore.posts
              .orderBy('created_time', descending: true)
              .snapshots(),
          builder: (context, postsnapshot) {
            if (postsnapshot.hasData) {
              List<String> postAccountIds = [];
              postsnapshot.data!.docs.forEach((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                if (!postAccountIds.contains(data['post_account_id'])) {
                  postAccountIds.add(data['post_account_id']);
                }
              });
              return FutureBuilder<Map<String, Account>?>(
                  future: UserFirestore.getPostUserMap(postAccountIds),
                  builder: (context, usersnapshot) {
                    if (usersnapshot.hasData &&
                        usersnapshot.connectionState == ConnectionState.done) {
                      return ListView.builder(
                          itemCount: postsnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data =
                                postsnapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            Post post = Post(
                                id: postsnapshot.data!.docs[index].id,
                                content: data['content'],
                                postAccountId: data['post_account_id'],
                                createdTime: data['created_time']);
                            Account postAccount =
                                usersnapshot.data![post.postAccountId]!;
                            return Container(
                              //投稿ごとを分ける線
                              decoration: BoxDecoration(
                                  border: index == 0
                                      ? const Border(
                                          top: BorderSide(
                                              color: Colors.grey, width: 0),
                                          bottom: BorderSide(
                                              color: Colors.grey, width: 0))
                                      : Border(
                                          bottom: BorderSide(
                                              color: Colors.grey, width: 0))),
                              //投稿ごとの余白
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    foregroundImage:
                                        NetworkImage(postAccount.imagePath),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(postAccount.name,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text('@${postAccount.userId}',
                                                      style: const TextStyle(
                                                          color: Colors.grey)),
                                                ],
                                              ),
                                              Text(DateFormat('M/d/yy').format(
                                                  post.createdTime!.toDate()))
                                            ],
                                          ),
                                          Text(post.content)
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    } else {
                      return Container();
                    }
                  });
            } else {
              return Container();
            }
          }),
    );
  }
}
