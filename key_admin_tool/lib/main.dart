//
//  <Key Admin Tool>
//  main.dart
//
//  Created by Jinwoo.Choi on 2022. 11. 01..
//  Copyright © 2022년 MOGOS Co. All rights reserved.
//
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setPathUrlStrategy(); //주소에 #을 없애주는 function.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //debug 마크 감추기
      home: MyPage(),
    );
  }
}



class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(body: Authentication());
  }
}

class Authentication extends StatelessWidget {
  const Authentication({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(), //firebase에서 제공하는 계정 관리 시스템
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            headerBuilder: (context, constraints, double) {
              return Padding(
                padding: EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 0.0000001,
                  child: Image(
                    image: AssetImage('assets/images/fatosimage.png'),//회사 이미지, 앱 사이즈 x2 x3에 대한 이미지도 필요하지만 , 현재는 최소사이즈만 구현

                  ),
                ),
              );
            },
            providerConfigs: [EmailProviderConfiguration()],
          );
        }
        return HomePage();
      },
    );
  }
}


