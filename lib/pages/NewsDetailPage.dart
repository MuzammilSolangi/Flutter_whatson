import 'package:flutter/material.dart';
import 'package:flutter_whatson/widgets/SilverContainer.dart';

class ProductDetailPage extends StatefulWidget {
  final String product;

  ProductDetailPage({this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState(product);
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  final String product;

  _ProductDetailPageState(this.product);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Builder(
        builder: (context) => SliverContainer(
              expandedHeight: 256.0,
              slivers: <Widget>[
                new SliverAppBar(
                  iconTheme: IconThemeData(color: Colors.white),
                  expandedHeight: 256.0,
                  pinned: true,
                  flexibleSpace: new FlexibleSpaceBar(
                    title: new Text(
                      "Event Details",
                      style: TextStyle(color: Colors.black54),
                    ),
                    background: Image.network('https://maps.googleapis.com/maps/api/staticmap?center=Berkeley,CA&zoom=14&size=400x400&key=AIzaSyCMvboG5e4_07Cdd-WLsK9x6FvJPCFaN6g', fit: BoxFit.cover,),
                  ),
                ),
                new SliverList(
                  delegate: new SliverChildListDelegate(
                    new List.generate(
                      30,
                      (int index) =>
                          new ListTile(title: new Text("Item $index")),
                    ),
                  ),
                ),
              ],
            ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  _buildBottomNavigationBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: RaisedButton(
              onPressed: () {},
              color: Colors.redAccent,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "REJECT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: RaisedButton(
              onPressed: () {},
              color: Color(0xff21E86D),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "ATTEND",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: RaisedButton(
              onPressed: () {},
              color: Colors.amberAccent,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.query_builder,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "MAYBE",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
