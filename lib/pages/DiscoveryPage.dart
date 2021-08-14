import 'package:flutter/material.dart';

class DiscoveryPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 170.0,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/avatar_default.png"),

            ),
            boxShadow: [new BoxShadow(color: Colors.black, blurRadius: 8.0)],
            color: Colors.green),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  top: 60.0, bottom: 18.0, right: 18.0, left: 18.0),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: new AssetImage("images/ic_house.png"),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}