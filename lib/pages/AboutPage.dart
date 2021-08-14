import 'package:flutter/material.dart';
import 'CommonWebPage.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new AboutPageState();
  }
}

class AboutPageState extends State<AboutPage> {
  bool showImage = false;
  TextStyle textStyle = new TextStyle(
      color: Colors.blue,
      decoration: new TextDecoration.combine([TextDecoration.underline]));
  Widget emailWidget, whatsappWidget;

  AboutPageState() {

    emailWidget = new Container(
        margin: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("Email："),
            new Text(
              "eventsapp7@gmail.com",
              style: textStyle,
            )
          ],
        ),
      );
    whatsappWidget = new Container(
        margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("Whatsapp："),
            new Text(
              "0092-090078601",
              style: textStyle,
            ),
          ],
        ),
      );
  }

  Widget buttonWidget() {
      return new Container(
        child: new Center(
          child: new InkWell(
            child: new Container(
              padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
              child: new Text("Join us on Facebook",style: TextStyle(color: Colors.white)),
              decoration: new BoxDecoration(
                  color: const Color(0xFF4267B2),
                  border: new Border.all(color: Colors.black),
                  borderRadius: new BorderRadius.all(new Radius.circular(5.0))),
            ),
            onTap: () {
              setState(() {

              });
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("ABOUT", style: new TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new Container(
              width: 1.0,
              height: 50.0,
              color: Colors.transparent,
            ),
            new Image.asset(
              './images/aaa.png',
              width: 200.0,
              height: 106.0,
            ),
            new Padding(padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text("Find NearBy Events Around You",style: TextStyle(fontSize: 22.0))),
            emailWidget,
            whatsappWidget,
            new Expanded(flex: 1, child: buttonWidget()),
            new Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0),
                child: new Text(
                  "All Copyrights © 2019",
                  style: new TextStyle(fontSize: 12.0),
                ))
          ],
        ),
      ));
  }
}
