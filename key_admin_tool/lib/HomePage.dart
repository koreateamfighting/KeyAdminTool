//
//  <Key Admin Tool>
//  main.dart
//
//  Created by Jinwoo.Choi on 2022. 11. 01..
//  Copyright © 2022년 MOGOS Co. All rights reserved.
//


//해당 홈페이지의 여러 페이지를 관리 로직이 있는 코드.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fatos_key_gen/dashboard.dart';//최초 사이트 정보 확인 사이트
import 'package:fatos_key_gen/settings.dart'; // 설정 화면 사이트
import 'package:fatos_key_gen/keygen.dart'; // 키 생성 하는 사이트
import 'package:fatos_key_gen/keyauth.dart'; // 키 검증 하는 사이트




class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController tabController;
  int active = 0;
  int cnt = 0;


  void initState() {
    super.initState();

    tabController = new TabController(
        length: 4, vsync: this, initialIndex: cnt == 0 ? 0 : 1)
      ..addListener(() {
        setState(() {
          active = tabController.index;
          cnt++;
        });
      });
  }

  void dispose() {
    tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
        MediaQuery.of(context).size.width < 1300 ? true : false,
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 32),
                child: new InkWell(
                  child: TextButton(
                    child: Text("KeyAdmin",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),),
                    onPressed: ()=>  tabController.animateTo(0),

                  ),

                ),
              ),
            ]),
      ),
      body: Row(
        children: <Widget>[
          MediaQuery.of(context).size.width < 1300
              ? Container()
              : Card(
            elevation: 2.0,
            child: Container(
              margin: EdgeInsets.all(0),
              height: MediaQuery.of(context).size.height,
              width: 300,
              color: Colors.white,
              child: listDrawerItems(false),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width < 1300
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width - 310,
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                DashBoard(),
                KeyGen(),
                Auth(),
                Settings(),

              ],
            ),
          )
        ],
      ),
      drawer: Padding(
          padding: EdgeInsets.only(top: 56),
          child: Drawer(child: listDrawerItems(true))),
    );
  }

  Widget listDrawerItems(bool drawerStatus) {
    return ListView(
      children: <Widget>[
        TextButton(
          onPressed: () {
            tabController.animateTo(0);
            drawerStatus ? Navigator.pop(context) : print("");
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
              child: Row(children: [
                Icon(Icons.dashboard),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ]),
            ),
          ),
        ),
        TextButton(
          onPressed: () {

      tabController.animateTo(1);
      drawerStatus ? Navigator.pop(context) : print("");

          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
              child: Row(children: [
                Icon(Icons.vpn_key),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Key Generate",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ]),
            ),
          ),
        ),
        TextButton(
          onPressed: () {


            print(tabController.index);
            tabController.animateTo(2);
            drawerStatus ? Navigator.pop(context) : print("keygen");

          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
              child: Row(children: [
                Icon(Icons.verified),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Key Auth",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ]),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            print(tabController.index);
            tabController.animateTo(3);
            drawerStatus ? Navigator.pop(context) : print("");
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
              child: Row(children: [
                Icon(Icons.settings),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ]),
            ),
          ),
        ),

        TextButton(
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) =>
                    AlertDialog(
                        content: Container(
                          child: Text("로그아웃 하시겠습니까?"),
                        ),
                        actions: [

                          TextButton(onPressed: (){Navigator.pop(context, 'OK');FirebaseAuth.instance.signOut();}, child: const Text('OK')),
                          TextButton(onPressed: (){Navigator.pop(context, 'Cancel');}, child: const Text('Cancel'))
                        ])

            );


          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
              child: Row(children: [
                Icon(Icons.exit_to_app_sharp),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Exit",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}


