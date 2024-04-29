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
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:json_table/json_table.dart';
import 'package:file_picker/file_picker.dart';

class KeyGen extends StatefulWidget {
  _KeyGen createState() => _KeyGen();
}

class _KeyGen extends State<KeyGen> {
  List? site_number;
  List? site_sub_number;
  List? serial_list; //시리얼 키 리스트(db파일에 들어가는 리스트임)
  List? dogong_MacandSerials; //(도로공사버전은 다르다.) 도공용 mac키와 serial키 담은 리스트
  List? temp;
  String? authexlist;
  List? authexlist4;
  List<String> ukey_list = List.empty(growable: true);
  List<String> device_list = List.empty(growable: true);

  String? site_name;
  List? site_name2;
  String? dropdownvalue;
  String? dropdownvalue2;
  String? edited_ukey;
  String? Serials;
  String? Macs;
  List<String> list1 = List.empty(growable: true);
  List<String> list4 = List.empty(growable: true);
  List<String> list2 = List.empty(growable: true);
  List<String> list3 = List.empty(growable: true);

  TextEditingController getUkeyController = TextEditingController();
  TextEditingController getDeviceinfoController = TextEditingController();
  List<String> Ukeys = [];
  List<String> Devices = [];
  String output_Ukeys = '';
  bool _visibility = false;
  bool _visibility2 = false;
  int? int_site;
  int? int_site_sub;
  var listmapingdata;
  var str_dropdownvalue;
  var split_site_number;
  TextEditingController editvalue1 = TextEditingController();
  TextEditingController editvalue2 = TextEditingController();

  void _getsitenumber() async { //dropvalue구현에 쓰임. 사이트 번호를 나열하는 api
    var response = await http.get(
        //Uri.parse('http://localhost:3300/sitekey/distinct_site'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/sitekey/distinct_site'),
        headers: {"Accept": "application/json"});
    site_number = jsonDecode(response.body);
    for (var i = 0; i <= site_number!.length - 1; i++) {
      list1.add(site_number![i]['site'].toString());
      list2.add(site_number![i]['site_name'].toString());
    }
    ;

    list2[13] = '소방청'; // 35사이트에는 소방,인천mod 등의 여러 사이트가 있어 주로 쓰이는 소방청을 대표로 별도 선언

    for (var i = 0; i <= list1.length - 1; i++) {
      list3.add('${list1[i]}' '  (' '${list2[i]}' ')');
    }
  }

  void _getsitesubnumber(String value) async { //dropvalue구현에 쓰임. 사이트서브 번호를 나열하는 api
    var response2 = await http.get(
      //Uri.parse('http://localhost:3300/sitekey/${value}/distinct_sub'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/sitekey/${value}/distinct_sub'),
        headers: {"Accept": "application/json"});
    site_sub_number = jsonDecode(response2.body);
    list4 = [];
    for (var i = 0; i <= site_sub_number!.length - 1; i++) {
      list4.add(site_sub_number![i]['site_sub'].toString());
    }

    ;
  }

  void _getAuthex(int site, int site_sub) async { //해당 사이트,사이트서브에 모든 키 조회, 모든 칼럼 출력 (임시, 인코딩 문제가 있어 지금은 아래 api 쓰는중)
    var response4 = await http.get(
        //Uri.parse('http://localhost:3300/getauthex/${site}/${site_sub}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/getauthex/${site}/${site_sub}'),
        headers: {"Accept": "application/json"});
    authexlist = response4.body;
  }

  void _getAuthex2(int site, int site_sub) async { //해당 사이트,사이트서브에 모든 키 조회, select결과에 ukey와,생성일,만료일만 출력
    var response5 = await http.get(
        //Uri.parse('http://localhost:3300/getauthex2/${site}/${site_sub}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/getauthex2/${site}/${site_sub}'),
        headers: {"Accept": "application/json"});
    ukey_list = [];
    device_list = [];

    authexlist4 = jsonDecode(utf8.decode(response5.bodyBytes));
    for (var i = 0; i <= authexlist4!.length - 1; i++) {
      ukey_list.add(authexlist4![i]['ukey'].toString());
      device_list.add(authexlist4![i]['device'].toString());
    }
    //print(authexlist4);
  }

  void _getserialkey(int site, int site_sub) async { //db 생성 쿼리(소방청 전용)
    Serials = '';
    var response4 = await http.get(
        //Uri.parse('http://localhost:3300/getauthex2/makedb/${site}/${site_sub}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/getauthex2/makedb/${site}/${site_sub}'),
        headers: {"Accept": "application/json"});
    serial_list = jsonDecode(response4.body);

    Serials = serial_list![0]['serialkey'];
    for (var i = 1; i <= serial_list!.length - 1; i++) {
      Serials = '${Serials}' '${serial_list![i]['serialkey']}';
    }
  }

  void _getserialkey2(int site, int site_sub) async {//db 생성 쿼리(소방,도공 제외한 모든 사이트들)
    Serials = '';
    var response5 = await http.get(
        //Uri.parse('http://localhost:3300/getauthex2/makedb2/${site}/${site_sub}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/getauthex2/makedb2/${site}/${site_sub}'),
        headers: {"Accept": "application/json"});
    serial_list = jsonDecode(response5.body);

    Serials = serial_list![0]['serialkey'];
    for (var i = 1; i <= serial_list!.length - 1; i++) {
      Serials = '${Serials}' '${serial_list![i]['serialkey']}';
    }
  }

  void _getserialkey3(int site, int site_sub) async { //db 생성 쿼리(도공 전용)
    Serials = '';
    var response5 = await http.get(
        //Uri.parse('http://localhost:3300/getauthex2/makedb3/${site}/${site_sub}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/getauthex2/makedb3/${site}/${site_sub}'),
        headers: {"Accept": "application/json"});
    dogong_MacandSerials = jsonDecode(response5.body);

    Serials = '"${dogong_MacandSerials![0]['serialkey']}"';
    Macs = '"${dogong_MacandSerials![0]['mac']}"';

    for (var i = 1; i <= dogong_MacandSerials!.length - 1; i++) {
      Serials = '${Serials}' ',\n' '"${dogong_MacandSerials![i]['serialkey']}"';
    }
    for (var i = 1; i <= dogong_MacandSerials!.length - 1; i++) {
      Macs = '${Macs}' ',\n' '"${dogong_MacandSerials![i]['mac']}"';
    }
    print(dogong_MacandSerials!.length);
  }


  Future<String> _getsitename(int site, int site_sub) async { //db파일명에 사이트 이름을 불러 기재하기 위한 api
    var response3 = await http.get(
        //Uri.parse('http://localhost:3300/sitekey/${site}/${site_sub}/getsitename'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/sitekey/${site}/${site_sub}/getsitename'),
        headers: {"Accept": "application/json"});
    temp = jsonDecode(response3.body);
    site_name = temp![0]['site_name'];

    return site_name!;
  }

  Future<http.Response> createauthenKey(
      int site, int site_sub, String ukey, String device) async {
    return http.post(
        //Uri.parse('http://localhost:3300/authex/${site}/${site_sub}/${ukey}/${device}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/authex/${site}/${site_sub}/${ukey}/${device}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          "site": site,
          "site_sub": site_sub,
          "ukey": ukey,
          "device": device,
        }));
  }

  Future<http.Response> createauthenKey_dogong(
      int site, int site_sub, String ukey, String device) async {
    return http.post(
        //Uri.parse('http://localhost:3300/authex2/${site}/${site_sub}/${ukey}/${device}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/authex2/${site}/${site_sub}/${ukey}/${device}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          "site": site,
          "site_sub": site_sub,
          "ukey": ukey,
          "device": device,
        }));
  }

  Future<http.Response> editauthenkey(int site, int site_sub, String ukey,
      String newukey, String expire) async {
    return http.put(
      //Uri.parse('http://localhost:3300/authex/update/${site}/${site_sub}/${ukey}/${newukey}/${expire}'),
      Uri.parse('https://mogoskeyadmin2.loca.lt/authex/update/${site}/${site_sub}/${ukey}/${newukey}/${expire}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        "site": site,
        "site_sub": site_sub,
        "ukey": ukey,
        "newukey": newukey,
        "expire": expire,
      }),
    );
  }

  Future<http.Response> deleteauthenkey(
      int site, int site_sub, String ukey) async {
    return http.delete(
        //Uri.parse('http://localhost:3300/authex/delete/${site}/${site_sub}/${ukey}'),
        Uri.parse('https://mogoskeyadmin2.loca.lt/authex/delete/${site}/${site_sub}/${ukey}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          "site": site,
          "site_sub": site_sub,
          "ukey": ukey
        }));
  }

  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyyMMdd');
    String strToday = formatter.format(now);
    return strToday;
  }

  void _show() async {
    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        _visibility = true;
      });
    });
  }

  void _hide() {
    setState(() {
      _visibility = false;
    });
  }

  void _show2() async {
    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        _visibility2 = true;
      });
    });
  }

  void _hide2() async {
    setState(() {
      _visibility2 = false;
    });
  }

  void initState() {
    super.initState();

    _getsitenumber();
  }

  void dispose() {}

  void clearText() {
    getUkeyController.clear();
    getDeviceinfoController.clear();
  }

  void addItemToList() {
    setState(() {
      //컨트롤러에 의해 값 가져오는 경우
      Ukeys.insert(0, getUkeyController.text);
      Devices.insert(0, getDeviceinfoController.text);
    });
  }

  void addItemTolist2() {
    setState(() {
      //파일에 의해 값 가져오는 경우
      Ukeys;
      Devices;
    });
  }

  /*void showSnackBar(BuildContext context, int index) {
    var deletedRecord = authexlist4![index];
    setState(() {
      ukey_list!.removeAt(index);
    });
    SnackBar snackBar = SnackBar(
      content: Text('Deleted $deletedRecord'),
      action: SnackBarAction(
        label: "UNDO",
        onPressed: () {
          setState(() {
            ukey_list!.insert(index, deletedRecord);
          });
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }*/

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 800.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('<  S  I  T  E  >'),
              Container(
                width: 300,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(30)),
                child: DropdownButton<String>(
                  onChanged: (value) async {
                    setState(() {
                      dropdownvalue = value;
                      str_dropdownvalue = dropdownvalue.toString();
                      //print(str_dropdownvalue);
                      split_site_number = str_dropdownvalue.split('(');
                      //print(str_dropdownvalue);
                      _getsitesubnumber(split_site_number[0].toString());
                      dropdownvalue2 = null;
                      //print(split_site_number);

                      _hide();
                      _hide2();
                      _show2();
                      //print("서브 전달 완료");
                    });
                  },
                  value: dropdownvalue,
                  underline: Container(
                    height: 2,
                    color: Colors.black,
                  ),
                  hint: Center(
                      child: Text(
                    'Select the site',
                    style: TextStyle(color: Colors.red),
                  )),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  isExpanded: true,
                  items: list3
                      .map((e) => DropdownMenuItem(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                e,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            value: e,
                          ))
                      .toList(),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Visibility(
                visible: _visibility2,
                child: Text('< SITE_SUB >'),
              ),
              Visibility(
                visible: _visibility2,
                child: Container(
                  width: 300,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(30)),
                  child: DropdownButton<String>(
                    onChanged: (value) {
                      setState(() {
                        dropdownvalue2 = value;
                        String? val2 = dropdownvalue2;
                        _getsitename(int.parse(split_site_number[0].toString()),
                            int.parse(dropdownvalue2.toString()));

                        _show();
                      });
                    },
                    value: dropdownvalue2,
                    underline: Container(
                      height: 2,
                      color: Colors.black,
                    ),
                    hint: Center(
                        child: Text(
                      'Select the site_sub',
                      style: TextStyle(color: Colors.red),
                    )),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                    isExpanded: true,
                    items: list4
                        .map((e) => DropdownMenuItem(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  e,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              value: e,
                            ))
                        .toList(),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Visibility(
                visible: _visibility,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Visibility(
                        visible: _visibility2,
                        child: Text('${site_name} : ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                      Flexible(
                          child: SizedBox(
                        width: 800,
                        child: TextField(
                          controller: getUkeyController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Ukey 입력(필수항목)'),
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) async {
                            if (getUkeyController.value.text == '') {
                              final snackbar = SnackBar(
                                  content: const Text(
                                      'null값을 허용하지 않습니다. 다시 입력해주세요.'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackbar);
                            } else {
                              addItemToList();
                              clearText();
                              //print(Ukeys);
                            }
                          },
                        ),
                      )),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                          child: SizedBox(
                        width: 400,
                        child: TextField(
                          controller: getDeviceinfoController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '디바이스명 입력 (생략가능,default=0)'),
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) async {
                            if (getDeviceinfoController.value.text == '') {
                              getDeviceinfoController.text = '0';
                            }
                          },
                        ),
                      )),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
                            onPressed: () {
                              if (getDeviceinfoController.value.text == '') {
                                getDeviceinfoController.text = '0';
                              }

                              if (getUkeyController.value.text == '') {
                                final snackbar = SnackBar(
                                    content: const Text(
                                        'null값을 허용하지 않습니다. 다시 입력해주세요.'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackbar);
                              } else {
                                addItemToList();
                                clearText();
                                //print(Devices);
                              }
                            },
                            icon: Icon(Icons.add, color: Colors.blue)),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Visibility(
                visible: _visibility,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                        child: Text(
                          '파일로넣기',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () async {
                          setState(() {
                            Ukeys.clear();
                            Devices.clear();
                            clearText();
                            //print(Ukeys);
                            //print(Devices);
                          });

                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['txt'],
                          );
                          if (result == null) {
                            //print("No file selected");
                          } else { //*주의사항 : 아직 한글은 입력 불가 (아스키로 읽어내기 떄문)
                            PlatformFile file = result.files.first;

                            var ascii_value = result?.files.first.bytes;

                            print(ascii_value);
                            const AsciiCodec ascii = AsciiCodec();

                            String String_Value = ascii.decode(ascii_value!);
                            print(String_Value);
                            if (String_Value.contains("|") == false) {
                              // Ukey만 있는 파일 유형
                              List<String> inputfile = String_Value.split('\n');
                              print(inputfile);
                              Ukeys = inputfile;
                              //print('길이는  ' '${Ukeys.length}');
                              for (var i = 0; i <= Ukeys!.length - 1; i++) {
                                Devices.add('0');
                              }
                              //print('디바이스의 길이는 ' '${Devices.length}');

                              addItemTolist2();
                            } else {
                              // Ukey와 더불어 디바이스명까지 기재되어 있는 파일 유형
                              List<String> inputfile2_temp =
                                  String_Value.split('\n');
                              //print(inputfile2_temp);
                              for (var i = 0;
                                  i <= inputfile2_temp!.length - 1;
                                  i++) {
                                String inputfile2_temp_str = inputfile2_temp[i];
                                List<String> split_str =
                                    inputfile2_temp_str.split('|');
                                Ukeys.add(split_str[0]);
                                Devices.add(split_str[1]);
                              }

                              //print(Ukeys);
                              //print(Devices);
                              addItemTolist2();
                            }
                          }
                        }),
                    TextButton(
                        child: Text(
                          '조회',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          listmapingdata = null;
                          _getAuthex2(
                              int.parse(split_site_number[0].toString()),
                              int.parse(dropdownvalue2.toString()));

                          Future.delayed(const Duration(milliseconds: 2000),
                              () {
                            if (authexlist4!.isEmpty) {
                              AlertDialog alert1 = AlertDialog(
                                  content: Container(
                                    child: Text("데이터가 없습니다."),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'OK'),
                                        child: const Text('OK'))
                                  ]);
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return alert1;
                                  });
                            } else {
                              AlertDialog alert2 = AlertDialog(
                                  title: Text('<조회 결과>',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  scrollable: true,
                                  content: Container(
                                      height: 800,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 5.5,
                                              color: Colors.grey
                                                  .withOpacity(0.5))),
                                      child: JsonTable(
                                        authexlist4!,

                                        showColumnToggle: false,
                                        allowRowHighlight: true,
                                        //rowHighlightColor: Colors.blueAccent[500]!.withOpacity(0.7),
                                        onRowSelect: (index, map) {
                                          listmapingdata = map;
                                        },
                                      )),
                                  actions: [
                                    TextButton(
                                        child: const Text('Edit'),
                                        onPressed: () {
                                          Future.delayed(
                                              const Duration(
                                                  milliseconds: 3000), () {
                                            if (listmapingdata == null) {
                                              AlertDialog alert = AlertDialog(
                                                content:
                                                    Text("편집 할 데이터가 없습니다."),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, 'OK'),
                                                      child: const Text('OK'))
                                                ],
                                              );
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return alert;
                                                },
                                              );
                                            } else {
                                              AlertDialog alert = AlertDialog(
                                                content: Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                          onPressed: () {
                                                            editvalue1.text =
                                                                listmapingdata[
                                                                    'ukey'];
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: Icon(
                                                              Icons.clear)),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text("Ukey 수정",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    TextField(
                                                        controller: editvalue1,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              '${listmapingdata['ukey']}',
                                                        )),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text("만료일 수정",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    TextField(
                                                        controller: editvalue2,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              '${listmapingdata['expire']}',
                                                        ),
                                                        onTap: () async {
                                                          DateTime? date2 =
                                                              await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  initialDate:
                                                                      DateTime
                                                                          .now(),
                                                                  firstDate:
                                                                      DateTime
                                                                          .now(),
                                                                  lastDate:
                                                                      DateTime(
                                                                          2100));
                                                          setState(() {
                                                            editvalue2.text =
                                                                date2
                                                                    .toString()
                                                                    .substring(
                                                                        0, 10);
                                                          });
                                                        }),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blue,
                                                                  primary: Colors
                                                                      .black),
                                                          child: new Text("OK"),
                                                          onPressed: () {
                                                            AlertDialog alert =
                                                                AlertDialog(
                                                              content: Text(
                                                                  "키 값 변경을 하시겠습니까?"),
                                                              actions: [
                                                                TextButton(
                                                                    child: Text(
                                                                        'ok'),
                                                                    onPressed:
                                                                        () {
                                                                      if (editvalue1
                                                                              .value
                                                                              .text ==
                                                                          "") {
                                                                        editvalue1.text =
                                                                            '${listmapingdata['ukey']}';

                                                                        Navigator.pop(
                                                                            context);
                                                                      } else if (editvalue2
                                                                              .value
                                                                              .text ==
                                                                          "") {
                                                                        editvalue2.text =
                                                                            '${listmapingdata['expire']}';
                                                                      } else {
                                                                        editauthenkey(
                                                                            int.parse(split_site_number[0].toString()),
                                                                            int.parse(dropdownvalue2.toString()),
                                                                            listmapingdata['ukey'],
                                                                            editvalue1.text.toString(),
                                                                            editvalue2.text.toString());

                                                                        Navigator.pop(
                                                                            context);
                                                                        final snackbar =
                                                                            SnackBar(content: const Text('성공적으로 편집 되었습니다.'));
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(snackbar);
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                        setState(
                                                                            () {});
                                                                      }
                                                                    }),
                                                                TextButton(
                                                                    child: Text(
                                                                        'cancel'),
                                                                    onPressed:
                                                                        () {
                                                                      editvalue1
                                                                              .text =
                                                                          listmapingdata[
                                                                              'ukey'];
                                                                      Navigator.pop(
                                                                          context);
                                                                    }),
                                                              ],
                                                            );
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return alert;
                                                              },
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                actions: [],
                                              );
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return alert;
                                                },
                                              );
                                            }
                                          });
                                        }),
                                    TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () {
                                          if (listmapingdata == null) {
                                            AlertDialog alert = AlertDialog(
                                              content: Text("삭제 할 데이터가 없습니다."),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, 'OK'),
                                                    child: const Text('OK'))
                                              ],
                                            );
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return alert;
                                              },
                                            );
                                          } else {
                                            AlertDialog alert = AlertDialog(
                                              content: Text(
                                                  "해당 값을 정말 삭제하시겠습니까? 삭제 시 복구 할 수 없습니다."),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      deleteauthenkey(
                                                          int.parse(
                                                              split_site_number[
                                                                      0]
                                                                  .toString()),
                                                          int.parse(
                                                              dropdownvalue2
                                                                  .toString()),
                                                          listmapingdata[
                                                              'ukey']);

                                                      Navigator.pop(
                                                          context, 'OK');
                                                      final snackbar = SnackBar(
                                                          content: const Text(
                                                              '성공적으로 삭제 되었습니다.'));
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              snackbar);

                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('OK')),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, 'Cancel'),
                                                    child: const Text('Cancel'))
                                              ],
                                            );
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return alert;
                                              },
                                            );
                                          }
                                        }),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'OK'),
                                        child: const Text('OK'))
                                  ]);
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return alert2;
                                  });
                            }
                          });
                        }),
                    TextButton(
                        child: Text(
                          '초기화',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          if (Ukeys.isEmpty) {
                            AlertDialog alert = AlertDialog(
                              content: Text("초기화 할 내용이 없습니다."),
                              actions: [
                                TextButton(
                                  child: Text('ok'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          } else {
                            AlertDialog alert = AlertDialog(
                              content: Text("Are you sure you want to Undo?"),
                              actions: [
                                TextButton(
                                    child: Text('ok'),
                                    onPressed: () {
                                      Ukeys.clear();
                                      Devices.clear();

                                      Navigator.pop(context);
                                      final snackbar = SnackBar(
                                          content: const Text('Undo Success!'));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackbar);
                                      setState(() {
                                        clearText();
                                      });
                                    }),
                                TextButton(
                                  child: Text('cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          }
                        }),
                    SizedBox(width: 10),
                    TextButton(
                      child: Text(
                        'DB에저장',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        Future.delayed(Duration(milliseconds: 1000), () {
                          if (Ukeys.isEmpty) {
                            AlertDialog alert = AlertDialog(
                              content: Text("생성 할 내용이 없습니다."),
                              actions: [
                                TextButton(
                                  child: Text('ok'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          } else {
                            AlertDialog alert = AlertDialog(
                              content:
                                  Text("Are you sure you want to Generate?"),
                              actions: [
                                TextButton(
                                  child: Text('ok'),
                                  onPressed: () async {
                                    if ((int.parse(split_site_number[0]
                                                    .toString()) ==
                                                23 &&
                                            int.parse(dropdownvalue2
                                                    .toString()) ==
                                                2) ||
                                        int.parse(split_site_number[0]
                                                .toString()) ==
                                            9999) {
                                      for (var i = 0; i < Ukeys.length; i++) {
                                        createauthenKey_dogong(
                                          int.parse(
                                              split_site_number[0].toString()),
                                          int.parse(dropdownvalue2.toString()),
                                          Ukeys[i],
                                          Devices[i],
                                        );
                                      }
                                    } else {
                                      for (var i = 0; i < Ukeys.length; i++) {
                                        createauthenKey(
                                          int.parse(
                                              split_site_number[0].toString()),
                                          int.parse(dropdownvalue2.toString()),
                                          Ukeys[i],
                                          Devices[i],
                                        );
                                      }
                                    }

                                    Navigator.pop(context);
                                    final snackbar = SnackBar(
                                        content:
                                            const Text('Generate Success!'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackbar);
                                    //print("생성 정보는 : ${Ukeys}");

                                    String site_name = await _getsitename(
                                        int.parse(
                                            split_site_number[0].toString()),
                                        int.parse(dropdownvalue2.toString()));

                                    for (var i = 0; i < Ukeys.length; i++) {
                                      output_Ukeys = output_Ukeys +
                                          Ukeys[i] +
                                          '|' +
                                          Devices[i] +
                                          '\n';
                                    }
                                    final text = '${output_Ukeys}';
                                    final bytes = utf8.encode(text);
                                    final blob = html.Blob([bytes]);
                                    final url =
                                        html.Url.createObjectUrlFromBlob(blob);
                                    if (int.parse(
                                            split_site_number[0].toString()) ==
                                        35) {
                                      site_name = 'fireagency';
                                    } else if ((int.parse(
                                                split_site_number[0] //도로공사
                                                    .toString()) ==
                                            23 &&
                                        int.parse(dropdownvalue2.toString()) ==
                                            2)) {
                                      site_name = 'dogong';
                                    }
                                    final anchor = html.document
                                            .createElement('a')
                                        as html.AnchorElement
                                      ..href = url
                                      ..style.display = 'none'
                                      ..download =
                                          '${split_site_number[0].toString().substring(0, split_site_number[0].length - 2)}.'
                                              '${site_name}_1_${getToday()}.txt';

                                    //print('${split_site_number[0].length}''이다.');

                                    html.document.body!.children.add(anchor);
                                    // download
                                    anchor.click();
                                    // cleanup
                                    html.document.body!.children.remove(anchor);
                                    html.Url.revokeObjectUrl(url);
                                    Ukeys.clear();
                                    Devices.clear();
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
                          }
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    TextButton(
                        child: Text(
                          'DB파일생성',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          AlertDialog alert2 = AlertDialog(
                            content: Text("갱신된 사이트의 db를 다운로드 하시겠습니까?"),
                            actions: [
                              TextButton(
                                child: Text('ok'),
                                onPressed: () async {
                                  //print(split_site_number[0]);

                                  /*_getAuthex(
                                      int.parse(
                                          split_site_number[0].toString()),
                                      int.parse(dropdownvalue2.toString()));*/
                                  _getAuthex2(
                                      int.parse(
                                          split_site_number[0].toString()),
                                      int.parse(dropdownvalue2.toString()));

                                  if (authexlist4 == null) {
                                    final snackbar = SnackBar(
                                        content: const Text(
                                            '데이터를 준비중입니다. 다시 실행해 주세요.'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackbar);
                                  } else {
                                    if (int.parse(
                                            split_site_number[0].toString()) ==
                                        35) {
                                      _getserialkey(
                                          int.parse(
                                              split_site_number[0].toString()),
                                          int.parse(dropdownvalue2.toString()));

                                      Future.delayed(
                                          Duration(milliseconds: 5000), () {
                                        final text = '${Serials}';
                                        final bytes = utf8.encode(text);
                                        final blob = html.Blob([bytes]);
                                        final url =
                                            html.Url.createObjectUrlFromBlob(
                                                blob);

                                        final anchor = html.document
                                                .createElement('a')
                                            as html.AnchorElement
                                          ..href = url
                                          ..style.display = 'none'
                                          ..download =
                                              'kor_fireagency_fatos-4_0_${getToday()}.db';

                                        html.document.body!.children
                                            .add(anchor);
                                        // download
                                        anchor.click();
                                        // cleanup
                                        html.document.body!.children
                                            .remove(anchor);
                                        html.Url.revokeObjectUrl(url);
                                        Navigator.pop(context);
                                        setState(() {});
                                      });
                                    } else if ((int.parse(
                                                    split_site_number[0] //도로공사
                                                        .toString()) ==
                                                23 &&
                                            int.parse(dropdownvalue2
                                                    .toString()) ==
                                                2) ||
                                        int.parse(split_site_number[0]
                                                .toString()) ==
                                            9999) {
                                      _getserialkey3(
                                          int.parse(
                                              split_site_number[0].toString()),
                                          int.parse(dropdownvalue2.toString()));

                                      Future.delayed(
                                          Duration(milliseconds: 5000), () {
                                        final text = '{\n'
                                            '"result" : "OK",\n'
                                            '"model" : "DOGONG",\n'
                                            '"count" : '
                                            '"${dogong_MacandSerials!.length}",\n'
                                            '"mac" : [\n'
                                            '${Macs}\n'
                                            '],\n'
                                            '"key" : [\n'
                                            '${Serials}\n'
                                            ']}';

                                        final bytes = utf8.encode(text);
                                        final blob = html.Blob([bytes]);
                                        final url =
                                            html.Url.createObjectUrlFromBlob(
                                                blob);

                                        final anchor = html.document
                                                .createElement('a')
                                            as html.AnchorElement
                                          ..href = url
                                          ..style.display = 'none'
                                          ..download =
                                              'key_DOGONG_${getToday()}.db';

                                        html.document.body!.children
                                            .add(anchor);
                                        // download
                                        anchor.click();
                                        // cleanup
                                        html.document.body!.children
                                            .remove(anchor);
                                        html.Url.revokeObjectUrl(url);
                                        Navigator.pop(context);
                                        setState(() {});
                                      });
                                    } else {
                                      _getserialkey2(
                                          int.parse(
                                              split_site_number[0].toString()),
                                          int.parse(dropdownvalue2.toString()));

                                      Future.delayed(
                                          Duration(milliseconds: 5000), () {
                                        final text = '${Serials}';
                                        final bytes = utf8.encode(text);
                                        final blob = html.Blob([bytes]);
                                        final url =
                                            html.Url.createObjectUrlFromBlob(
                                                blob);

                                        final anchor = html.document
                                                .createElement('a')
                                            as html.AnchorElement
                                          ..href = url
                                          ..style.display = 'none'
                                          ..download =
                                              'kor_${site_name}_fatos-5_3_${getToday()}.db';

                                        html.document.body!.children
                                            .add(anchor);
                                        // download
                                        anchor.click();
                                        // cleanup
                                        html.document.body!.children
                                            .remove(anchor);
                                        html.Url.revokeObjectUrl(url);
                                        Navigator.pop(context);
                                        setState(() {});
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
                              return alert2;
                            },
                          );
                        }

                        //},
                        ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Visibility(
                  visible: _visibility,
                  child: Expanded(
                      child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: Ukeys.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          height: 50,
                          margin: EdgeInsets.all(2),
                          child: Center(
                              child: Row(
                            children: [
                              Text(
                                'Ukey : ',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.lightBlue),
                              ),
                              Text('${Ukeys[index]}' ' , ',
                                  style: TextStyle(fontSize: 24)),
                              Text('Device :',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.lightBlue)),
                              Text('${Devices[index]}',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          )));
                    },
                  )))
            ],
          ),
        ),
      ),
    );
  }
}
