import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatson/constants/Constants.dart';
import 'package:flutter_whatson/events/ChangeThemeEvent.dart';
import 'package:flutter_whatson/pages/AboutPage.dart';
import 'package:flutter_whatson/pages/NewLoginPage.dart';
import 'package:flutter_whatson/pages/OfflineActivityPage.dart';
import 'package:flutter_whatson/pages/SettingsPage.dart';
import 'package:flutter_whatson/util/DataUtils.dart';
import 'package:flutter_whatson/util/ThemeUtils.dart';
import 'pages/NewsListPage.dart';
import './widgets/MyDrawer.dart';

void main() {
  runApp(new WhatsOnClient());
}

class WhatsOnClient extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new WhatsOnClientState();
}

class WhatsOnClientState extends State<WhatsOnClient> {
  final appBarTitles = ['Login','My Events','Search','Setting','About'];
  final tabTextStyleSelected = new TextStyle(color: const Color(0xff63ca6c));
  final tabTextStyleNormal = new TextStyle(color: const Color(0xff969696));

  Color themeColor = ThemeUtils.currentColorTheme;
  int _tabIndex = 2;

  var tabImages;
  var _body;
  var pages;

  Image getTabImage(path) {
    return new Image.asset(path, width: 20.0, height: 20.0);
  }

  @override
  void initState() {
    super.initState();
    DataUtils.getColorThemeIndex().then((index) {
      print('color theme index = $index');
      if (index != null) {
        ThemeUtils.currentColorTheme = ThemeUtils.supportColors[index];
        Constants.eventBus.fire(new ChangeThemeEvent(ThemeUtils.supportColors[index]));
      }
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      setState(() {
        themeColor = event.color;
      });
    });
    pages = <Widget>[
      NewLoginPage(),
      OfflineActivityPage(),
      NewsListPage(),
      SettingsPage(),
      AboutPage()
    ];
    if (tabImages == null) {
      tabImages = [
        [
          getTabImage('images/login_normal.png'),
          getTabImage('images/login_activated.png')
        ],
        [
          getTabImage('images/event_normal.png'),
          getTabImage('images/event_activated.png')
        ],
        [
          getTabImage('images/search_normal.png'),
          getTabImage('images/search_activated.png')
        ],
        [
          getTabImage('images/settings_normal.png'),
          getTabImage('images/settings_activated.png')
        ],
        [
          getTabImage('images/user_normal.png'),
          getTabImage('images/user_activated.png')
        ]
      ];
    }
  }

  TextStyle getTabTextStyle(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabTextStyleSelected;
    }
    return tabTextStyleNormal;
  }

  Image getTabIcon(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabImages[curIndex][1];
    }
    return tabImages[curIndex][0];
  }

  Text getTabTitle(int curIndex) {
    return new Text(appBarTitles[curIndex], style: getTabTextStyle(curIndex));
  }

  @override
  Widget build(BuildContext context) {
    _body = new IndexedStack(
      children: pages,
      index: _tabIndex,
    );
    return new MaterialApp(
      theme: new ThemeData(
          primaryColor: themeColor
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(appBarTitles[_tabIndex],
          style: new TextStyle(color: Colors.white)),
          iconTheme: new IconThemeData(color: Colors.white)
        ),
        body: _body,
        bottomNavigationBar: new CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(
                icon: getTabIcon(0),
                title: getTabTitle(0)),
            new BottomNavigationBarItem(
                icon: getTabIcon(1),
                title: getTabTitle(1)),
            new BottomNavigationBarItem(
                icon: getTabIcon(2),
                title: getTabTitle(2)),
            new BottomNavigationBarItem(
                icon: getTabIcon(3),
                title: getTabTitle(3)),
            new BottomNavigationBarItem(
                icon: getTabIcon(4),
                title: getTabTitle(4)),
          ],
          currentIndex: _tabIndex,
          onTap: (index) {
            setState((){
              _tabIndex = index;
            });
          },
        ),
        drawer: MyDrawer()
      ),
    );
  }
}