import 'package:flutter/material.dart';
import 'package:flutter_whatson/constants/Constants.dart';
import 'package:flutter_whatson/events/LoginEvent.dart';
import 'package:flutter_whatson/events/LogoutEvent.dart';
import 'package:flutter_whatson/pages/NewLoginPage.dart';
import 'package:flutter_whatson/util/Utf8Utils.dart';
import '../util/BlackListUtils.dart';
import '../api/Api.dart';
import '../util/NetUtils.dart';
import 'dart:convert';
import 'dart:async';
import '../util/DataUtils.dart';

class TweetsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new TweetsListPageState();
  }
}

class TweetsListPageState extends State<TweetsListPage> {
  List hotTweetsList;
  List normalTweetsList;
  TextStyle authorTextStyle;
  TextStyle subtitleStyle;
  RegExp regExp1 = new RegExp("</.*>");
  RegExp regExp2 = new RegExp("<.*>");
  num curPage = 1;
  bool loading = false;
  ScrollController _controller;
  bool isUserLogin = false;

  @override
  void initState() {
    super.initState();
    DataUtils.isLogin().then((isLogin) {
      setState(() {
        this.isUserLogin = isLogin;
      });
    });
    Constants.eventBus.on<LoginEvent>().listen((event) {
      setState(() {
        this.isUserLogin = true;
      });
    });
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      setState(() {
        this.isUserLogin = false;
      });
    });
  }

  TweetsListPageState() {
    authorTextStyle =
        new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold);
    subtitleStyle =
        new TextStyle(fontSize: 12.0, color: const Color(0xFFB5BDC0));
    _controller = new ScrollController();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        // load next page
        curPage++;
        getTweetsList(true, false);
      }
    });
  }

  getTweetsList(bool isLoadMore, bool isHot) {
    DataUtils.isLogin().then((isLogin) {
      if (isLogin) {
        DataUtils.getAccessToken().then((token) {
          if (token == null || token.length == 0) {
            return;
          }
          loading = true;
          Map<String, String> params = new Map();
          params['access_token'] = token;
          params['page'] = "$curPage";
          if (isHot) {
            params['user'] = "-1";
          } else {
            params['user'] = "0";
          }
          params['pageSize'] = "20";
          params['dataType'] = "json";
          NetUtils.get(Api.TWEETS_LIST, params: params).then((data) {
            Map<String, dynamic> obj = json.decode(data);
            if (!isLoadMore) {
              // first load
              if (isHot) {
                hotTweetsList = obj['tweetlist'];
              } else {
                normalTweetsList = obj['tweetlist'];
              }
            } else {
              // load more
              List list = new List();
              list.addAll(normalTweetsList);
              list.addAll(obj['tweetlist']);
              normalTweetsList = list;
            }
            filterList(hotTweetsList, true);
            filterList(normalTweetsList, false);
          });
        });
      }
    });
  }

  // ????????????????????????????????????
  filterList(List<dynamic> objList, bool isHot) {
    BlackListUtils.getBlackListIds().then((intList) {
      if (intList != null && intList.isNotEmpty && objList != null) {
        List newList = new List();
        for (dynamic item in objList) {
          int authorId = item['authorid'];
          if (!intList.contains(authorId)) {
            newList.add(item);
          }
        }
        setState(() {
          if (isHot) {
            hotTweetsList = newList;
          } else {
            normalTweetsList = newList;
          }
          loading = false;
        });
      } else {
        // ??????????????????????????????????????????
        setState(() {
          if (isHot) {
            hotTweetsList = objList;
          } else {
            normalTweetsList = objList;
          }
          loading = false;
        });
      }
    });
  }

  // ??????????????????html??????
  String clearHtmlContent(String str) {
    if (str.startsWith("<emoji")) {
      return "[emoji]";
    }
    var s = str.replaceAll(regExp1, "");
    s = s.replaceAll(regExp2, "");
    s = s.replaceAll("\n", "");
    return s;
  }

  Widget getRowWidget(Map<String, dynamic> listItem) {
    var authorRow = new Row(
      children: <Widget>[
        new Container(
          width: 35.0,
          height: 35.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            image: new DecorationImage(
                image: new NetworkImage(listItem['portrait']),
                fit: BoxFit.cover),
            border: new Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
          child: new Text(
            listItem['author'],
            style: new TextStyle(fontSize: 16.0)
          )
        ),
        new Expanded(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Text(
                '${listItem['commentCount']}',
                style: subtitleStyle,
              ),
              new Image.asset(
                './images/ic_comment.png',
                width: 16.0,
                height: 16.0,
              )
            ],
          ),
        )
      ],
    );
    var _body = listItem['body'];
    _body = clearHtmlContent(_body);
    var contentRow = new Row(
      children: <Widget>[
        new Expanded(child: new Text(_body))
      ],
    );
    var timeRow = new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new Text(
          listItem['pubDate'],
          style: subtitleStyle,
        )
      ],
    );
    var columns = <Widget>[
      new Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
        child: authorRow,
      ),
      new Padding(
        padding: const EdgeInsets.fromLTRB(52.0, 0.0, 10.0, 0.0),
        child: contentRow,
      ),
    ];
    String imgSmall = listItem['imgSmall'];
    if (imgSmall != null && imgSmall.length > 0) {
      // ??????????????????
      List<String> list = imgSmall.split(",");
      List<String> imgUrlList = new List<String>();
      for (String s in list) {
        if (s.startsWith("http")) {
          imgUrlList.add(s);
        } else {
          imgUrlList.add("https://static.oschina.net/uploads/space/" + s);
        }
      }
      List<Widget> imgList = [];
      List<List<Widget>> rows = [];
      num len = imgUrlList.length;
      for (var row = 0; row < getRow(len); row++) {
        List<Widget> rowArr = [];
        for (var col = 0; col < 3; col++) {
          num index = row * 3 + col;
          num screenWidth = MediaQuery.of(context).size.width;
          double cellWidth = (screenWidth - 100) / 3;
          if (index < len) {
            rowArr.add(new Padding(
              padding: const EdgeInsets.all(2.0),
              child: new Image.network(imgUrlList[index],
                  width: cellWidth, height: cellWidth),
            ));
          }
        }
        rows.add(rowArr);
      }
      for (var row in rows) {
        imgList.add(new Row(
          children: row,
        ));
      }
      columns.add(new Padding(
        padding: const EdgeInsets.fromLTRB(52.0, 5.0, 10.0, 0.0),
        child: new Column(
          children: imgList,
        ),
      ));
    }
    columns.add(new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 6.0),
      child: timeRow,
    ));
    return new InkWell(
      child: new Column(
        children: columns,
      ),
      onTap: () {
        // ?????????????????????
        /*Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) {
          return new TweetDetailPage(
            tweetData: listItem,
          );
        }));*/
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return new AlertDialog(
              title: new Text('??????'),
              content: new Text('??????\"${listItem['author']}\"?????????????????????'),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    '??????',
                    style: new TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text(
                    '??????',
                    style: new TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    putIntoBlackHouse(listItem);
                  },
                )
              ],
            );
          });
      },
    );
  }

  // ???????????????
  putIntoBlackHouse(item) {
    int authorId = item['authorid'];
    String portrait = "${item['portrait']}";
    String nickname = "${item['author']}";
    DataUtils.getUserInfo().then((info) {
      if (info != null) {
        int loginUserId = info.id;
        Map<String, String> params = new Map();
        params['userid'] = '$loginUserId';
        params['authorid'] = '$authorId';
        params['authoravatar'] = portrait;
        params['authorname'] = Utf8Utils.encode(nickname);
        NetUtils.post(Api.ADD_TO_BLACK, params: params).then((data) {
          Navigator.of(context).pop();
          if (data != null) {
            var obj = json.decode(data);
            if (obj['code'] == 0) {
              // ????????????????????????
              showAddBlackHouseResultDialog("???????????????????????????");
              BlackListUtils.addBlackId(authorId).then((arg) {
                // ?????????????????????????????????
                filterList(normalTweetsList, false);
                filterList(hotTweetsList, true);
              });
            } else {
              // ????????????
              var msg = obj['msg'];
              showAddBlackHouseResultDialog("???????????????????????????$msg");
            }
          }
        }).catchError((e) {
          Navigator.of(context).pop();
          showAddBlackHouseResultDialog("?????????????????????$e");
        });
      }
    });
  }

  showAddBlackHouseResultDialog(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
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
      });
  }

  renderHotRow(i) {
    if (i.isOdd) {
      return new Divider(
        height: 1.0,
      );
    } else {
      i = i ~/ 2;
      return getRowWidget(hotTweetsList[i]);
    }
  }

  renderNormalRow(i) {
    if (i.isOdd) {
      return new Divider(
        height: 1.0,
      );
    } else {
      i = i ~/ 2;
      return getRowWidget(normalTweetsList[i]);
    }
  }

  int getRow(int n) {
    int a = n % 3;
    int b = n ~/ 3;
    if (a != 0) {
      return b + 1;
    }
    return b;
  }

  Future<Null> _pullToRefresh() async {
    curPage = 1;
    getTweetsList(false, false);
    return null;
  }

  Widget getHotListView() {
    if (hotTweetsList == null) {
      getTweetsList(false, true);
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      // ??????????????????
      return new ListView.builder(
        itemCount: hotTweetsList.length * 2 - 1,
        itemBuilder: (context, i) => renderHotRow(i),
      );
    }
  }

  Widget getNormalListView() {
    if (normalTweetsList == null) {
      getTweetsList(false, false);
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      // ??????????????????
      return new RefreshIndicator(
        child: new ListView.builder(
          itemCount: normalTweetsList.length * 2 - 1,
          itemBuilder: (context, i) => renderNormalRow(i),
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _controller,
        ),
        onRefresh: _pullToRefresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isUserLogin) {
      return new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Center(
                child: new Column(
                  children: <Widget>[
                    new Text("??????OSC???openapi??????"),
                    new Text("???????????????????????????????????????")
                  ],
                ),
              )
            ),
            new InkWell(
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
                }
              },
            ),
          ],
        ),
      );
    }
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new TabBar(
          labelColor: Colors.black,
          tabs: <Widget>[
            new Tab(text: "????????????"),
            new Tab(text: "????????????")
          ],
        ),
        body: new TabBarView(
          children: <Widget>[getNormalListView(), getHotListView()],
        )),
    );
  }
}
