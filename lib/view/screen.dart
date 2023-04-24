import 'package:flutter/material.dart';
import 'package:flutter_sns/view/account/account_page.dart';
import 'package:flutter_sns/view/timeline/post_page.dart';
import 'package:flutter_sns/view/timeline/timeline_page.dart';

//SNSによくあるButtomNavigation
//全画面に共通しているアイテムをおく
class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  //どのページを選択しているか
  int selectedIndex = 0;
  //選択する可能性のあるページ
  List<Widget> pageList = [TimelinePage(), AccountPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageList[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity_outlined), label: '')
        ],
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PostPage()));
          },
          child: const Icon(Icons.chat_bubble_outline)),
    );
  }
}
