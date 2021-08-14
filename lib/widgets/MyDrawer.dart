import 'package:flutter/material.dart';

import '../pages/Dashboard.dart';

class MyDrawer extends StatelessWidget {

  static const double IMAGE_ICON_WIDTH = 30.0;

  static const double ARROW_ICON_WIDTH = 16.0;

  var rightArrowIcon = new Image.asset(
    'images/ic_arrow_right.png',
    width: ARROW_ICON_WIDTH,
    height: ARROW_ICON_WIDTH,
  );

  List menuTitles = ['DASHBOARD', 'NEW EVENT', 'PAYMENTS', 'LOG OUT'];

  List menuIcons = [
    './images/leftmenu/speedometer.png',
    './images/leftmenu/add-event.png',
    './images/leftmenu/payment.png',
    './images/leftmenu/out.png'
  ];

  TextStyle menuStyle = new TextStyle(
    fontSize: 15.0,
  );

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: const BoxConstraints.expand(width: 304.0),
      child: new Material(
        elevation: 16.0,
        child: new Container(
          decoration: new BoxDecoration(
            color: const Color(0xFFFFFFFF),
          ),
          child: new ListView.builder(
            itemCount: menuTitles.length * 2 + 1,
            itemBuilder: renderRow,
          ),
        ),
      ),
    );
  }

  Widget getIconImage(path) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 0.0, 6.0, 0.0),
      child: new Image.asset(path, width: 28.0, height: 28.0),
    );
  }

  Widget renderRow(BuildContext context, int index) {
    if (index == 0) {
      // render cover image
      var img = new Image.asset(
        './images/cover_background.png',
        width: 304.0,
        height: 304.0,
      );
      return new Container(
        width: 304.0,
        height: 304.0,
        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
        child: img,
      );
    }

    index -= 1;

    if (index.isOdd) {
      return new Divider();
    }
    index = index ~/ 2;

    var listItemContent = new Padding(

      padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),

      child: new Row(
        children: <Widget>[

          getIconImage(menuIcons[index]),

          new Expanded(
            child: new Text(
              menuTitles[index],
              style: menuStyle,
            )
          ),
          rightArrowIcon
        ],
      ),
    );

    return new InkWell(
      child: listItemContent,
      onTap: () {
        switch (index) {
          case 0:

            Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) {
              return DashboardPage();
            }));
            break;
          case 1:

            Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) {
              return new Container();
            }));
            break;
          case 2:

            Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) {
              return new Container();
            }));
            break;
          case 3:

            Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) {
              return new Container();
            }));
            break;
        }
      },
    );
  }
}
