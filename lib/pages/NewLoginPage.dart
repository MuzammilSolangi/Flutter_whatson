import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whatson/widgets/NumberTextFormat.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class NewLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      home: MyHomePage(title: 'Firebase Auth Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> _message = Future<String>.value('');
  TextEditingController _smsCodeController = TextEditingController();
  String verificationId;
  final String testSmsCode = '######';
  final String testPhoneNumber = '+92 3162973558';
  final _mobileFormatter = NumberTextInputFormatter();
  TextEditingController etcontroller = TextEditingController();
  String phoneNumber;

  Future<void> _testVerifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (FirebaseUser user) {
      setState(() {
        _message = Future<String>.value('signInWithPhoneNumber auto succeeded: $user');
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message = Future<String>.value(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      _smsCodeController.text = testSmsCode;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      _smsCodeController.text = testSmsCode;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: etcontroller.text,
        timeout: const Duration(seconds: 10),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future<String> _testSignInWithPhoneNumber(String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    _smsCodeController.text = '';
    return 'signInWithPhoneNumber succeeded: $user';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/loginbg.png"), fit: BoxFit.cover)),
        ),
        SafeArea(
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 50.0),
                          child: OutlineButton(
                              child: new Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    "Events App",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24.0),
                                  )),
                              borderSide: BorderSide(color: Colors.black),
                              onPressed: () {},
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(50.0))),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                      child: TextFormField(
                        controller: etcontroller,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                          _mobileFormatter,
                        ],
                        decoration: InputDecoration(
                          icon: Icon(Icons.phone_iphone),
                          hintText: "Mobile*",
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text("We will send you a SMS with a verification code", style: TextStyle(fontSize: 12.0, decoration: TextDecoration.none, color: Colors.black54)),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: TextField(
                      controller: _smsCodeController,
                      decoration: const InputDecoration(
                        hintText: 'SMS Code',
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 100.0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 20.0),
                            child: RaisedButton(onPressed: (){
                              _testVerifyPhoneNumber();
                            }, color: Color(0xFF505050),
                                child: Text("Login", style: TextStyle(fontSize: 20.0, color: Colors.white),)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        )
      ],
    );



    /*Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MaterialButton(
                  child: const Text('Test verifyPhoneNumber'),
                  onPressed: () {
                    _testVerifyPhoneNumber();
                  }),
              Container(
                margin: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 8.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: TextField(
                  controller: _smsCodeController,
                  decoration: const InputDecoration(
                    hintText: 'SMS Code',
                  ),
                ),
              ),
              MaterialButton(
                  child: const Text('Test signInWithPhoneNumber'),
                  onPressed: () {
                    if (_smsCodeController.text != null) {
                      setState(() {
                        _message =
                            _testSignInWithPhoneNumber(_smsCodeController.text);
                      });
                    }
                  }),
              FutureBuilder<String>(
                  future: _message,
                  builder: (_, AsyncSnapshot<String> snapshot) {
                    return Text(snapshot.data ?? '',
                        style:
                        const TextStyle(color: Color.fromARGB(255, 0, 0, 0)));
                  }),
            ],
          ),
        ],
      )
    );*/
  }
}




/*
*
*
*
* import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osc/widgets/NumberTextFormat.dart';

class NewLoginPage extends StatefulWidget {
  @override
  _NewLoginPageState createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  final _mobileFormatter = NumberTextInputFormatter();
  TextEditingController etcontroller;
  String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return
  }
}
*
*
* */