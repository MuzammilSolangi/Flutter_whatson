import 'package:flutter/material.dart';
import 'package:flutter_whatson/constants/Constants.dart';
import 'package:flutter_whatson/events/LoginEvent.dart';
import 'package:flutter_whatson/pages/NewLoginPage.dart';
import 'package:flutter_whatson/util/BlackListUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/NetUtils.dart';
import '../api/Api.dart';
import 'dart:convert';
import '../util/DataUtils.dart';
import '../util/Utf8Utils.dart';

class BlackHousePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new BlackHousePageState();
  }
}

class BlackHousePageState extends State<BlackHousePage> {
  bool isLogin = true;
  List blackDataList;
  TextStyle btnStyle = new TextStyle(color: Colors.white, fontSize: 12.0);

  BlackHousePageState() {
    queryBlackList();
  }

  queryBlackList() {
    DataUtils.getUserInfo().then((userInfo) {
      if (userInfo != null) {
        String url = Api.QUERY_BLACK;
        url += "/${userInfo.id}";
        NetUtils.get(url).then((data) {
          if (data != null) {
            var obj = json.decode(data);
            if (obj['code'] == 0) {
              setState(() {
                blackDataList = obj['msg'];
              });
            }
          }
        });
      } else {
        setState(() {
          isLogin = false;
        });
      }
    });
  }

  getUserInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String accessToken = sp.get(DataUtils.SP_AC_TOKEN);
    Map<String, String> params = new Map();
    params['access_token'] = accessToken;
    NetUtils.get(Api.USER_INFO, params: params).then((data) {
      if (data != null) {
        var map = json.decode(data);
        DataUtils.saveUserInfo(map).then((userInfo) {
          queryBlackList();
        });
      }
    });
  }

  deleteFromBlack(authorId) {
    DataUtils.getUserInfo().then((userInfo) {
      if (userInfo != null) {
        String userId = "${userInfo.id}";
        Map<String, String> params = new Map();
        params['userid'] = userId;
        params['authorid'] = "$authorId";
        NetUtils.get(Api.DELETE_BLACK, params: params).then((data) {
          Navigator.of(context).pop();
          if (data != null) {
            var obj = json.decode(data);
            if (obj['code'] == 0) {
              // ????????????
              BlackListUtils.removeBlackId(authorId);
              queryBlackList();
            } else {
              showResultDialog("???????????????${obj['msg']}");
            }
          }
        }).catchError((e) {
          Navigator.of(context).pop();
          showResultDialog("?????????????????????$e");
        });
      }
    });
  }

  showResultDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) {
        return new AlertDialog(
          title: new Text('??????'),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                '??????',
                style: new TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  showSetFreeDialog(item) {
    String name = Utf8Utils.decode(item['authorname']);
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return new AlertDialog(
          title: new Text('??????'),
          content: new Text('????????????\"$name\"?????????????????????'),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                '??????',
                style: new TextStyle(color: Colors.red),
              ),
              onPressed: () {
                deleteFromBlack(item['authorid']);
              },
            )
          ],
        );
      });
  }

  Widget getBody() {
    if (!isLogin) {
      return new Center(
        child: new InkWell(
          child: new Container(
            padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
            child: new Text("?????????"),
            decoration: new BoxDecoration(
                border: new Border.all(color: Colors.black),
                borderRadius: new BorderRadius.all(new Radius.circular(5.0))
            ),
          ),
          onTap: () async {
            final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) {
              return NewLoginPage();
            }));
            if (result != null && result == "refresh") {
              // ????????????????????????
              Constants.eventBus.fire(new LoginEvent());
              getUserInfo();
            }
          },
        ),
      );
    }
    if (blackDataList == null) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else if (blackDataList.length == 0) {
      return new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("??????????????????..."),
            new Text("?????????????????????????????????????????????")
          ],
        ),
      );
    }
    return new GridView.count(
      crossAxisCount: 3,
      children: new List.generate(blackDataList.length, (index) {
        String name = Utf8Utils.decode(blackDataList[index]['authorname']);
        return new Container(
          margin: const EdgeInsets.all(2.0),
          color: Colors.black,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                width: 45.0,
                height: 45.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  image: new DecorationImage(
                      image: new NetworkImage(
                          "${blackDataList[index]['authoravatar']}"),
                      fit: BoxFit.cover),
                  border: new Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
              new Container(
                margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                child:
                    new Text(name, style: new TextStyle(color: Colors.white)),
              ),
              new InkWell(
                child: new Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 5.0, 5.0, 8.0),
                  child: new Text(
                    "????????????",
                    style: btnStyle,
                  ),
                  decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.white),
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(5.0))),
                ),
                onTap: () {
                  showSetFreeDialog(blackDataList[index]);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("???????????????", style: new TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: new Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 0.0),
        child: getBody(),
      ),
    );
  }
}
