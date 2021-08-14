import 'dart:async';
import 'package:flutter/material.dart';
import '../util/NetUtils.dart';
import '../api/Api.dart';
import 'dart:convert';
import '../constants/Constants.dart';
import '../widgets/SlideView.dart';
import '../pages/NewsDetailPage.dart';
import '../widgets/CommonEndLine.dart';
import '../widgets/SlideViewIndicator.dart';

class NewsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new NewsListPageState();
}

class NewsListPageState extends State<NewsListPage> {
  final ScrollController _controller = new ScrollController();
  final TextStyle titleTextStyle = new TextStyle(fontSize: 15.0);
  final TextStyle subtitleStyle = new TextStyle(color: const Color(0xFFB5BDC0), fontSize: 12.0);

  var listData;
  var slideData;
  var curPage = 1;
  var pos = 0;
  SlideView slideView;
  var listTotalSize = 0;
  SlideViewIndicator indicator;
  List<String> titles = ["The Technology Expo - Digital Innovation & Emerging Tech","Hustle Summit: The Most Epic Networking Event You'll Ever Attend","Mobile + Web Development Conference","Webinar: How to Create a More Productive Inside Sales Team with Better Data","2K19 Japan IT Week Sprint ","IT Pro Expo 2019","Call Center/CRM Demo & Conference 2019 in Karachi","	Information technology programme","ON24 Webinar World 2018 Sydney, Australia","ABM Reality: Aligning & Enabling Your SDRs for Better B2B Marketing and Sales"];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels && listData.length < listTotalSize) {
        // scroll to bottom, get next page data
//        print("load more ... ");
        curPage++;
        getNewsList(true);
      }
    });
    getNewsList(false);
  }

  Future<Null> _pullToRefresh() async {
    curPage = 1;
    getNewsList(false);
    return null;
  }

  @override
  Widget build(BuildContext context) {

    if (listData == null) {
      return new Center(
        child: new RefreshProgressIndicator(),
      );
    } else {
      Widget listView = new ListView.builder(
        itemCount: listData.length * 2,
        itemBuilder: (context, i) => renderRow(i),
        controller: _controller,
      );
      return new RefreshIndicator(child: listView, onRefresh: _pullToRefresh);
    }
  }

  getNewsList(bool isLoadMore) {
    String url = Api.NEWS_LIST;
    url += "?pageIndex=$curPage&pageSize=10";
    NetUtils.get(url).then((data) {
      if (data != null) {
        Map<String, dynamic> map = json.decode(data);
        if (map['code'] == 0) {
          var msg = map['msg'];
          listTotalSize = 10;
          var _listData = msg['news']['data'];
          var _slideData = msg['slide'];
          setState(() {
            if (!isLoadMore) {
              listData = _listData;
              slideData = _slideData;
            } else {
              List list1 = new List();
              list1.addAll(listData);
              list1.addAll(_listData);
              if (list1.length >= listTotalSize) {
                list1.add(Constants.END_LINE_TAG);
              }
              listData = list1;
              slideData = _slideData;
            }
            initSlider();
          });
        }
      }
    });
  }

  void initSlider() {
    indicator = new SlideViewIndicator(slideData.length);
    slideView = new SlideView(slideData, indicator);
  }

  Widget renderRow(i) {
    if (i == 0) {
      return new Container(
        height: 180.0,
        child: new Stack(
          children: <Widget>[
            slideView,
            new Container(
              alignment: Alignment.bottomCenter,
              child: indicator,
            )
          ],
        ),
      );
    }
    i -= 1;
    if (i.isOdd) {
      return new Divider(height: 1.0);
    }
    i = i ~/ 2;
    var itemData = listData[i];
    var itemTitle = titles[i];
    pos = i;
    if (itemData is String && itemData == Constants.END_LINE_TAG) {
      return new CommonEndLine();
    }
    var titleRow = new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(itemTitle, style: titleTextStyle),
        )
      ],
    );
    var timeRow = new Row(
      children: <Widget>[
        new Container(
          width: 20.0,
          height: 20.0,

          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: new AssetImage('./images/user_placeholder.png'), fit: BoxFit.cover),
            border: new Border.all(
              color: const Color(0xFFECECEC),
              width: 2.0,
            ),
          ),

        ),
        new Padding(
          padding: const EdgeInsets.fromLTRB(7.0, 0.0, 2.0, 0.0),
          child: new Text(
            itemData['timeStr'],
            style: subtitleStyle,
          ),
        ),
        new Expanded(
          flex: 1,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Text("3 attending ", style: subtitleStyle),
              new Image.asset('./images/group.png', width: 16.0, height: 16.0),
              new Image.asset('./images/group.png', width: 16.0, height: 16.0),
              new Image.asset('./images/group.png', width: 16.0, height: 16.0),
            ],
          ),
        )
      ],
    );
    var thumbImg = new Container(
      margin: const EdgeInsets.all(10.0),
      width: 60.0,
      height: 60.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
            image: new ExactAssetImage('./images/more.png'),
            fit: BoxFit.cover),
      ),
    );
    var row = new Row(
      children: <Widget>[
        new Expanded(
          flex: 1,
          child: new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
                titleRow,
                new Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                  child: timeRow,
                )
              ],
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.all(6.0),
          child: new Container(
            width: 60.0,
            height: 60.0,
            child: new Center(
              child: thumbImg,
            ),
          ),
        )
      ],
    );
    return new InkWell(
      child: row,
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(
          builder: (ctx) => new ProductDetailPage(product: itemTitle)
        ));
      },
    );
  }
}
