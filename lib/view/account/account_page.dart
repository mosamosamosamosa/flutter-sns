import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sns/model/account.dart';
import 'package:flutter_sns/model/post.dart';
import 'package:flutter_sns/utils/authentication.dart';
import 'package:flutter_sns/utils/firestore/posts.dart';
import 'package:flutter_sns/utils/firestore/users.dart';
import 'package:flutter_sns/utils/widget_utils.dart';
import 'package:flutter_sns/view/account/edit_account_page.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Account? myAccount = Authentication.myAccount;

  //以前はdatabase.dartに入れていた仮のデータ
  List<Post> postList = [
    Post(
        id: '1',
        content: 'SNS始めました！\nよろしくお願いします><',
        postAccountId: '1',
        createdTime: Timestamp.now()),
    Post(
        id: '2',
        content: '授業嫌だなあ',
        postAccountId: '1',
        createdTime: Timestamp.now())
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //上の時計の部分を開けてくれる
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(right: 15, left: 15, top: 20),
                height: 200,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            CircleAvatar(
                                radius: 32,
                                foregroundImage:
                                    NetworkImage(myAccount!.imagePath)),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  myAccount!.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '@${myAccount!.userId}',
                                  style: const TextStyle(color: Colors.grey),
                                )
                              ],
                            )
                          ]),
                          OutlinedButton(
                              onPressed: () async {
                                var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditAccountPage()));
                                if (result) {
                                  setState(() {
                                    myAccount = Authentication.myAccount;
                                  });
                                }
                              },
                              child: const Text('編集'))
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(myAccount!.selfIntroduction)
                    ]),
              ),
              Container(
                  alignment: Alignment.center,
                  //表示できる幅の限界
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 3)),
                  ),
                  child: const Text('投稿',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold))),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: UserFirestore.users
                          .doc(myAccount!.id)
                          .collection('my_posts')
                          .orderBy('created_time', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          //自分の投稿の全てのID
                          List<String> myPostIds = List.generate(
                              snapshot.data!.docs.length, (index) {
                            return snapshot.data!.docs[index].id;
                          });
                          return FutureBuilder<List<Post>?>(
                              future: PostFirestore.getPostsFromIds(myPostIds),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                    //スクロールできないようにする
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Post post = snapshot.data![index];
                                      return Container(
                                        //投稿ごとを分ける線
                                        decoration: BoxDecoration(
                                            border: index == 0
                                                ? const Border(
                                                    top: BorderSide(
                                                        color: Colors.grey,
                                                        width: 0),
                                                    bottom: BorderSide(
                                                        color: Colors.grey,
                                                        width: 0))
                                                : Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey,
                                                        width: 0))),
                                        //投稿ごとの余白
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 15),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 22,
                                              foregroundImage: NetworkImage(
                                                  myAccount!.imagePath),
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                                myAccount!.name,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            Text(
                                                                '@${myAccount!.userId}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                          ],
                                                        ),
                                                        Text(DateFormat(
                                                                'M/d/yy')
                                                            .format(post
                                                                .createdTime!
                                                                .toDate()))
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
                                    },
                                  );
                                } else {
                                  return WidgetUtils()
                                      .createProgressIndicator();
                                }
                              });
                        } else {
                          return Container();
                        }
                      }))
            ],
          ),
        ),
      ),
    ));
  }
}

// Widget createProgressIndicator() {
//   return Container(
//       alignment: Alignment.center,
//       child: const CircularProgressIndicator(
//         color: Colors.green,
//       ));
// }
