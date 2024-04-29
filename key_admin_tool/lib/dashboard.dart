//
//  <Key Admin Tool>
//  main.dart
//
//  Created by Jinwoo.Choi on 2022. 11. 01..
//  Copyright © 2022년 MOGOS Co. All rights reserved.
//
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class DashBoard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashBoard> {
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: JSONListView()),
        ));
  }
}

//대시보드 최초 리스트뷰를 위한 선언
class GetUsers {
  int? site;
  int? site_sub;
  String? site_name;
  String? regdate;
  String? expiredate;

  GetUsers({
    this.site,
    this.site_sub,
    this.site_name,
    this.regdate,
    this.expiredate,
  });

  factory GetUsers.fromJson(Map<String, dynamic> json) {
    return GetUsers(
        site: json['site'],
        site_sub: json['site_sub'],
        site_name: json['site_name'],
        regdate: json['regdate'],
        expiredate: json['expiredate']);
  }
}

class JSONListView extends StatefulWidget {
  CustomJSONListView createState() => CustomJSONListView();
}

//getuser에 대한 api주소,json 구성
class CustomJSONListView extends State {
  //final String apiURL = 'http://localhost:3300/sitekey';
  final String apiURL = 'https://mogoskeyadmin2.loca.lt/sitekey';

  Future<List<GetUsers>> fetchJSONData() async {
    var jsonResponse = await http.get(Uri.parse(apiURL));
    if (jsonResponse.statusCode == 200) {
      final jsonItems =
          json.decode(jsonResponse.body).cast<Map<String, dynamic>>();
      List<GetUsers> usersList = jsonItems.map<GetUsers>((json) {
        return GetUsers.fromJson(json);
      }).toList();
      return usersList;
    } else {
      throw Exception('Failed to load data from internet');
    }
  }

//사이트 추가 api
  Future<dynamic> createsite(int site, int site_sub, String site_name,
      String regdate, String expiredate) async {
    return await http.post(
      //Uri.parse('http://localhost:3300/sitekey'),
      Uri.parse('https://mogoskeyadmin2.loca.lt/sitekey'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        "site": site,
        "site_sub": site_sub,
        "site_name": site_name,
        "regdate": regdate,
        "expiredate": expiredate,
      }),
    );
  }

//사이트 편집 api
  Future<http.Response> editsite(
      int site, int site_sub, String site_name, String expiredate) async {
    return await http.put(
      //Uri.parse('http://localhost:3300/sitekey/update/${site}/${site_sub}'),
      Uri.parse('https://mogoskeyadmin2.loca.lt/sitekey/update/${site}/${site_sub}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        "site": site,
        "site_sub": site_sub,
        "site_name": site_name,
        "expiredate": expiredate,
      }),
    );
  }

  //사이트 제거 api
  Future<http.Response> deletesite(int site, int site_sub) async {
    return http.delete(
        //Uri.parse('http://localhost:3300/sitekey/delete/${site}/${site_sub}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/sitekey/delete/${site}/${site_sub}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          "site": site,
          "site_sub": site_sub,
        }));
  }


  //특정 사이트에 있는 키들을 지우기 위한 api
  Future<http.Response> deletekey(int site, int site_sub) async {
    return http.delete(
        //Uri.parse('http://localhost:3300/authex/delete/${site}/${site_sub}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/authex/delete/${site}/${site_sub}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          "site": site,
          "site_sub": site_sub,
        }));
  }

  DateTime? temp;
  TextEditingController value1 = TextEditingController();//site 입력컨트롤러
  TextEditingController value2 = TextEditingController();//site_sub 입력컨트롤러
  TextEditingController value3 = TextEditingController();//site_name 입력컨트롤러
  String value4 = DateFormat('yyyy-MM-dd').format(DateTime.now());//오늘의 날짜를 받는 변수
  TextEditingController value5 = TextEditingController();//만기일 입력컨트롤러(datepicker)
  TextEditingController editvalue1 = TextEditingController();//site_name 수정 컨트롤러
  TextEditingController editvalue2 = TextEditingController();//만기일 수정 컨트롤러
  bool isDisabled = false;
  List? site_number; //사이트 번호 리스트
  List? site_sub_number; // 사이트서브 번호 리스트
  List<int> list1 = List.empty(growable: true); //사이트 중복체크 검증하기 위한 리스트
  bool isChecked = false; // 키 삭제 유무 라디오버튼 활성/비활성
  List? duplicate_check; // 사이트 중복 비교대상 리스트
  bool? duplicate_result; // 중복 판단 T/F

  void duplicatecheck(int site) async { //중복체크 api
    var response = await http.get(
        //Uri.parse('http://localhost:3300/sitekey/${site}/distinct_sub'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/sitekey/${site}/distinct_sub'),
        headers: {"Accept": "application/json"});
    duplicate_check = jsonDecode(response.body);
    list1 = [];
    for (var i = 0; i <= duplicate_check!.length - 1; i++) {
      list1.add(duplicate_check![i]['site_sub']);
    };
  }
  

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<GetUsers>>(
        future: fetchJSONData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return ListView(
            padding: const EdgeInsets.only(right: 80),
            children: snapshot.data!
                .map(
                  (user) => ListTile(
                    title: Text(user.site_name!),
                    onTap: () {},
                    subtitle: Text.rich(TextSpan(children: [
                      TextSpan(text: '만료일 : '),
                      TextSpan(
                          text: user.expiredate.toString().substring(0, 10)),
                    ])),
                    trailing: ElevatedButton(
                      child: Icon(Icons.edit_note),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                              insetPadding: EdgeInsets.all(60),
                              content: (Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.clear)),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("site_name",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  TextField(
                                      controller: editvalue1,
                                      decoration: InputDecoration(
                                        hintText: '${user.site_name}',
                                      )),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("expire_date",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  TextField(
                                      controller: editvalue2,
                                      showCursor: false,
                                      decoration: InputDecoration(
                                        hintText: '${user.expiredate}',
                                      ),
                                      onTap: () async {
                                        DateTime? date2 = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2100));
                                        setState(() {
                                          editvalue2.text =
                                              date2.toString().substring(0, 10);
                                        });
                                      }),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("regit_date",
                                        style: TextStyle(color: Colors.blue)),
                                  ),
                                  TextField(
                                      decoration: InputDecoration(
                                    labelText:
                                        '${user.regdate.toString().substring(0, 10)}',
                                    enabled: false,
                                  )),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("site",
                                        style: TextStyle(color: Colors.blue)),
                                  ),
                                  TextField(
                                      decoration: InputDecoration(
                                    hintText: '${user.site}',
                                    enabled: false,
                                  )),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("site_sub",
                                        style: TextStyle(color: Colors.blue)),
                                  ),
                                  TextField(
                                      decoration: InputDecoration(
                                    hintText: '${user.site_sub}',
                                    enabled: false,
                                  )),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          primary: Colors.black,
                                        ),
                                        child: new Text("Edit"),
                                        onPressed: () {
                                          AlertDialog alert = AlertDialog(
                                            content: Text(
                                                "Are you sure you want to Edit?"),
                                            actions: [
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  if (editvalue1.text.isEmpty ==
                                                          true ||
                                                      editvalue2.text.isEmpty ==
                                                          true) {
                                                    AlertDialog alert =
                                                        AlertDialog(
                                                      content:
                                                          Text("양식을 다 채워주세요."),
                                                      actions: [
                                                        TextButton(
                                                            child: Text('OK'),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                      ],
                                                    );
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return alert;
                                                      },
                                                    );
                                                  } else {
                                                    if (editvalue1.value.text ==
                                                            '' ||
                                                        editvalue2.value.text ==
                                                            '') {
                                                      Navigator.pop(context);
                                                      if (editvalue1
                                                              .value.text ==
                                                          '') {
                                                        editvalue1.text =
                                                            '${user.site_name}';
                                                      }
                                                      if (editvalue2
                                                              .value.text ==
                                                          '') {
                                                        editvalue2.text =
                                                            '${user.expiredate}';
                                                      }
                                                      var site_name_value =
                                                          editvalue1.value.text;
                                                      var expiredate_value =
                                                          editvalue2.text
                                                              .toString()
                                                              .substring(0, 10);

                                                      editsite(
                                                          user.site!,
                                                          user.site_sub!,
                                                          "$site_name_value",
                                                          "$expiredate_value");

                                                      setState(() {});
                                                      editvalue1.text = '';
                                                      editvalue2.text = '';

                                                      Navigator.pop(context);
                                                    } else {
                                                      setState(() {
                                                        Navigator.pop(context);
                                                        var site_name_value =
                                                            editvalue1
                                                                .value.text;
                                                        var expiredate_value =
                                                            editvalue2.text
                                                                .toString()
                                                                .substring(
                                                                    0, 10);

                                                        editsite(
                                                            user.site!,
                                                            user.site_sub!,
                                                            "$site_name_value",
                                                            "$expiredate_value");

                                                        setState(() {});
                                                        editvalue1.text = '';
                                                        editvalue2.text = '';

                                                        Navigator.pop(context);
                                                      });
                                                    }
                                                  }
                                                },
                                              ),
                                              TextButton(
                                                child: Text('cancel'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return alert;
                                            },
                                          );
                                        },
                                      ),
                                      TextButton(
                                        child: new Text("Delete"),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          primary: Colors.black,
                                        ),
                                        onPressed: () {
                                          AlertDialog alert = AlertDialog(
                                            content: Text(
                                                "Are you sure you want to delete?"),
                                            actions: [
                                              Checkbox(
                                                value: isChecked,
                                                onChanged: (bool? val) {
                                                  setState(() {
                                                    isChecked = val!;
                                                  });
                                                },
                                              ),
                                              Text("해당 키 값도 함께 지우기"),
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  if (isChecked == true) {
                                                    print("함께 지우는 중");
                                                    deletesite(user.site!,
                                                        user.site_sub!);
                                                    deletekey(user.site!,
                                                        user.site_sub!);
                                                  } else {
                                                    print("사이트만 지우는 중");
                                                    deletesite(user.site!,
                                                        user.site_sub!);
                                                  }

                                                  Navigator.pop(context);
                                                  setState(() {
                                                    fetchJSONData();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              TextButton(
                                                child: Text('cancel'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          );
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return alert;
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ))),
                        );
                      },
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(user.site_name![0],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          )),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    insetPadding: EdgeInsets.all(80),
                    content: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(30),
                            color: Colors.blue,
                            child: Column(children: [
                              Text(
                                '<Add Site>',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic, fontSize: 20),
                              ),
                              Text('Please fill out this form.'),
                            ])),
                        TextField(
                            controller: value1,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                            ],
                            decoration: InputDecoration(
                              labelText: ' site number',
                              hintText: 'integer',
                            )),
                        TextField(
                            controller: value2,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                            ],
                            decoration: InputDecoration(
                              labelText: ' site sub number',
                              hintText: 'integer',
                            )),
                        TextField(
                            controller: value3,
                            decoration: InputDecoration(
                              labelText: ' site name',
                            )),
                        TextField(
                            controller: value5,
                            showCursor: false,
                            decoration: InputDecoration(
                              labelText: ' expiry date',
                            ),
                            onTap: () async {
                              var date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100));
                              setState(() {
                                value5.text = date.toString().substring(0, 10);
                              });
                            }),
                        Text.rich(TextSpan(children: [
                          TextSpan(
                            text: 'Register Date : ',
                          ),
                          TextSpan(
                              text: DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ])),
                      ],
                    ),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new TextButton(
                            child: new Text("OK"),
                            onPressed: () {
                              if (value1.text.isEmpty == true ||
                                  value2.text.isEmpty == true ||
                                  value3.value.text == '' ||
                                  value5.text == '') {
                                AlertDialog alert = AlertDialog(
                                  content: Text("양식을 다 채워주세요."),
                                  actions: [
                                    TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        }),
                                  ],
                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  },
                                );
                              } else {
                                var sitevalue = int.parse(value1.value.text);
                                var sitesubvalue = int.parse(value2.value.text);
                                var sitenamevalue = value3.value.text;
                                var regdatevalue = value4;
                                var expiredatevalue =
                                    value5.text.toString().substring(0, 10);
                                Future.delayed(Duration(milliseconds: 3000),
                                    () {
                                  duplicatecheck(sitevalue);
                                  print('${list1}');
                                  duplicate_result =
                                      list1.contains(sitesubvalue);
                                  print(duplicate_result);
                                });

                                if (duplicate_result == true) {
                                  AlertDialog alert = AlertDialog(
                                    content:
                                        Text("입력하신 site와 site_sub가 이미 있습니다."),
                                    actions: [
                                      TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  );
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                  value1.text = '';
                                  value2.text = '';
                                } else {
                                  //fetchJSONData();
                                  createsite(
                                      sitevalue,
                                      sitesubvalue,
                                      "$sitenamevalue",
                                      "$regdatevalue",
                                      "$expiredatevalue");

                                  setState(() {
                                    value1 = TextEditingController();
                                    value2 = TextEditingController();
                                    value3 = TextEditingController();





                                     value4 = DateFormat('yyyy-MM-dd')
                                        .format(DateTime.now());
                                    value5 = TextEditingController();
                                    Navigator.pop(context);
                                  });
                                }
                                //});
                              }
                            },
                          ),
                          new TextButton(
                            child: new Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                value1 = TextEditingController();
                                value2 = TextEditingController();
                                value3 = TextEditingController();
                                value4 = DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now());
                                value5 = TextEditingController();
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ));
        },
        child: const Icon(Icons.add, color: Colors.black),
        tooltip: 'Add',
      ),
    );
  }
}
