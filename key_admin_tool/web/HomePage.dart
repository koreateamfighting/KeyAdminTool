import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:editable/editable.dart';
import 'package:fatos_key_gen/dashboard.dart';
import 'package:fatos_key_gen/settings.dart';
import 'package:flutterfire_ui/auth.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePage createState() => _HomePage();
}
class _HomePage extends State<HomePage> with SingleTickerProviderStateMixin{
  late TabController tabController;
  int active = 0;

  void initState(){
    super.initState();
    tabController = new TabController(length: 2, vsync: this, initialIndex: 0)
    ..addListener(() {
      setState((){
        active = tabController.index;
      });
    });
  }

  void dispose(){
    tabController.dispose();
    super.dispose();
  }


  List rows = [
    {"site": 'SiteA.co.kr', "expire_date":'2022-12-31'},
    {"site": 'SiteB.co.kr', "expire_date":'2023-06-31'},
    {"site": 'SiteC.co.kr', "expire_date":'2022-06-31'},
    {"site": 'SiteD.co.kr', "expire_date":'2023-12-31'},
    {"site": 'SiteE.co.kr', "expire_date":'2023-12-31'},
  ];
//Headers or Columns
  List headers = [
    {"title":'Site', 'index': 1, 'key':'site'},
    {"title":'Expire Date', 'index': 2, 'key':'expire_date'},

  ];




  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
        MediaQuery.of(context).size.width < 1300? true : false,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left:32),
                child:Text(
                  "KeyAdmin",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]),
          ),
      body: Row(
        children: <Widget>[
          MediaQuery.of(context).size.width < 1300
          ? Container()
              :Card(
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
                Settings(),

                //로그인 완벽 구현시에는 단순네비게이터가 아닌 Login-out 다트 파일 구현 필요
              ],
          ),
          )
        ],
      ),
      drawer: Padding(
        padding: EdgeInsets.only(top:56),
        child: Drawer(child:listDrawerItems(true))),
    );
  }
  Widget listDrawerItems(bool drawerStatus){
    return ListView(
      children: <Widget>[
        TextButton(

          onPressed: (){
              tabController.animateTo(0);
              drawerStatus ? Navigator.pop(context) : print("");
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(top:22,bottom:22,right:22),
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
            print(tabController.index);
            tabController.animateTo(1);
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
            FirebaseAuth.instance.signOut();
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


