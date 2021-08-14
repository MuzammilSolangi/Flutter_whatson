import 'package:flutter/material.dart';

class EventDetailPage extends StatefulWidget {
  String id;

  EventDetailPage({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new EventDetailPageState(id: this.id);
}

class EventDetailPageState extends State<EventDetailPage> {
  String id;
  bool loaded = false;
  String detailDataStr;

  EventDetailPageState({Key key, this.id});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('Event Details', style: TextStyle(color: Colors.black)),
          expandedHeight: 200.0,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network('https://maps.googleapis.com/maps/api/staticmap?center=37.0902%2C-95.7192&zoom=4&size=600x400&AIzaSyA8QxGb0ewpgqSbTYdJDawy_C3BKcCRGto'),
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 150.0,
          delegate: SliverChildListDelegate(
            [
              Container(
                height: 150.0,
                color: Colors.white,
                child: Stack(
                children: <Widget>[
                  Container(
                    color: const Color(0x50000000),
                    child: Padding(
                        padding: EdgeInsets.only(right: 50.0, left: 10.0),
                        child: Text(id ,style: TextStyle(fontSize: 15.0, color: Colors.white,decoration: TextDecoration.none
                        ))
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 8.0),
                  child: Container(
                    height: 70.0,
                    width: 70.0,
                    child: Image.asset("images/ic_avatar_default.png"),
                  ))
                ]),
              ),
              Container(color: Colors.green),
              Container(color: Colors.orange),
              Container(color: Colors.yellow),
              Container(color: Colors.pink),
            ],
          ),
        ),
      ],
    );
  }
}
