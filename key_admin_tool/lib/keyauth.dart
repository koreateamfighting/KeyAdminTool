//
//  <Key Admin Tool>
//  main.dart
//
//  Created by Jinwoo.Choi on 2022. 11. 01..
//  Copyright © 2022년 MOGOS Co. All rights reserved.
//
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:json_table/json_table.dart';

class Auth extends StatefulWidget {
  @override
  _Auth createState() => _Auth();
}

class _Auth extends State<Auth> {
  List<String> list1 = List.empty(growable: true);//list1~8까지 특정 검증에 대한 결과를 생성 하기 위한 중간 데이터 리스트 (아래 api함수들 참조)
  List<String> list2 = List.empty(growable: true);
  List<String> list3 = List.empty(growable: true);
  List<String> list4 = List.empty(growable: true);
  List<String> list5 = List.empty(growable: true);
  List<String> list6 = List.empty(growable: true);
  List<String> list7 = List.empty(growable: true);
  List<String> list8 = List.empty(growable: true);

  List<String> total_list1 = List.empty(growable: true);//verify1에 대한 검증결과 리스트
  List<String> total_list2 = List.empty(growable: true);//verify2에 대한 검증결과 리스트
  List<String> total_list3 = List.empty(growable: true);//verify3에 대한 검증결과 리스트

  List? temp1;
  List? temp2;
  List? temp3;

  String? verify1_result;//리스트결과물을 문자열 처리
  String? verify2_result;//리스트결과물을 문자열 처리
  String? verify3_result;//리스트결과물을 문자열 처리

  var sum1;
  var sum2;
  var sum3;

  void verify1() async { //유효기간 지난 것 출력 api
    temp1 = null;
    total_list1.clear();
    sum1 = null;
    var response = await http.get(
        //Uri.parse('http://localhost:3300/verify1'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/verify1'),
        headers: {"Accept": "application/json"});
    temp1 = jsonDecode(response.body);
    for (var i = 0; i <= temp1!.length - 1; i++) {
      list1.add(temp1![i]['site_name'].toString());
      list2.add(temp1![i]['expiredate'].toString());
      total_list1.add(list1[i].toString());
      total_list1.add(list2[i].toString().substring(0, 10));
      total_list1.add('\n');
      sum1 = total_list1.length / 3;
    };

    verify1_result = total_list1.join(" ");
  }

  void verify2() async { //키 없음 검증 api
    temp2 = null;
    total_list2.clear();
    sum2 = null;
    var response = await http.get(
        //Uri.parse('http://localhost:3300/verify2'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/verify2'),
        headers: {"Accept": "application/json"});
    temp2 = jsonDecode(response.body);

    for (var i = 0; i <= temp2!.length - 1; i++) {
      list3.add(temp2![i]['site'].toString());
      list4.add(temp2![i]['site_sub'].toString());
      list5.add(temp2![i]['site_name'].toString());
      total_list2.add(list3[i].toString());
      total_list2.add(list4[i].toString());
      total_list2.add(list5[i].toString());
      total_list2.add('\n');
      sum2 = total_list2.length / 4;
    }
    ;
    verify2_result = total_list2.join(" ");
  }
  void verify3() async { //사이트 검증(키는 존재하나 해당 된 사이트 없음) api
    temp3 = null;
    total_list3.clear();
    sum3 = null;
    var response = await http.get(
        //Uri.parse('http://localhost:3300/verify3'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/verify3'),
        headers: {"Accept": "application/json"});
    temp3 = jsonDecode(response.body);

    for (var i = 0; i <= temp3!.length - 1; i++) {
      list6.add(temp3![i]['site'].toString());
      list7.add(temp3![i]['site_sub'].toString());
      list8.add(temp3![i]['ukey'].toString());
      total_list3.add(list6[i].toString());
      total_list3.add(list7[i].toString());
      total_list3.add(list8[i].toString());
      total_list3.add('\n');
      sum3 = total_list3.length / 4;
    }
    ;
    verify3_result = total_list3.join(" ");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(children: [
          ListTile(
            onTap: () async {
              verify3();
              verify2();
              verify1();


              final snackbar = SnackBar(
                  content: const Text(
                      '키 검증 결과를 생성중입니다. 잠시만 기다려주십시오'));
              ScaffoldMessenger.of(
                  context)
                  .showSnackBar(snackbar);
              Future.delayed(const Duration(milliseconds: 2000), () {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text('<키 검증 결과>',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30)),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          scrollable: true,
                          content: Container(


                            child: Column(
                              children: [
                                Text('검증 이상 : ${sum3 + sum2+ sum1} 건 \n',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: Colors.redAccent)),


                                JsonTable(

                                  temp3!,
                                  showColumnToggle: true,
                                  allowRowHighlight: true,
                                ),
                                Text(
                                  '위와 같이 총 $sum3 건은 키는 존재하지만 사이트가 없는 상태 입니다. \n',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.blue),
                                ),
                                JsonTable(
                                  temp2!,
                                  showColumnToggle: true,
                                  allowRowHighlight: true,
                                ),
                                Text(
                                  '위와 같이 총 $sum2 건은 등록된 키가 없습니다. 키 등록이 필요합니다. \n',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.blue),
                                ),
                                JsonTable(

                                  temp1!,
                                  showColumnToggle: true,
                                  allowRowHighlight: true,
                                ),
                                Text(
                                  '위와 같이 총 $sum1 건이 기간 만료 상태 입니다. 갱신이 필요합니다. \n',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK'))
                          ]);
                    });
              });

//FilePickerResult? result = await FilePicker.platform.pickFiles();
            },
            leading: Icon(Icons.verified),
            title: Text('검증해보기'),
          ),
        ]),
      ),
    );
  }
}
