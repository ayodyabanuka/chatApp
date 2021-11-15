import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:principal_club_app/chatScreen.dart';

class login extends StatefulWidget {
  login({Key key}) : super(key: key);

  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  bool _isLogin = false;
  final _userNameController = TextEditingController();

  AgoraRtmClient _client;
  final _infoStrings = <String>[];

  @override
  void initState() {
    super.initState();
    _createClient();
  }

  String _peerUser = "ab";

  static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: FlutterLogo(),
                ),
              ),
              Text(
                "Live Chat",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  _isLogin
                      ? new Text('User Id: ' + _userNameController.text,
                          style: textStyle)
                      : Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.left,
                            controller: _userNameController,
                            decoration: InputDecoration(
                                focusColor: Color(0xff2e2e91),
                                hoverColor: Color(0xff2e2e91),
                                labelText: "User ID",
                                labelStyle: TextStyle(color: Color(0xff2e2e91)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(5.0)))),
                          ),
                        )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue,
                  child: MaterialButton(
                    onPressed: () {
                      _toggleLogin();
                    },
                    minWidth: 400.0,
                    height: 45.0,
                    child: Text(
                      _isLogin ? "Logout" : "Log in",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
  }

  void _toggleLogin() async {
    if (_isLogin) {
      try {
        await _client.logout();

        Fluttertoast.showToast(
            msg: "Logout Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

        setState(() {
          _isLogin = false;
        });
      } catch (errorCode) {
        Fluttertoast.showToast(
            msg: 'Logout error: ' + errorCode.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    } else {
      String userId = _userNameController.text;
      if (userId.isEmpty) {
        Fluttertoast.showToast(
            msg: 'Please input your user id to login.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

        return;
      }

      try {
        String username = userId;
        await _client.login(null, userId);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => chat(
                      username: userId,
                      client1: _client,
                    )));

        Fluttertoast.showToast(
            msg: 'Login success: ' + userId,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

        setState(() {
          _isLogin = true;
        });
      } catch (errorCode) {
        Fluttertoast.showToast(
            msg: 'Login error: ' + errorCode.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    }
  }

  _createClient() async {
    _client =
        await AgoraRtmClient.createInstance('fb44d8fb61614cc78f14aa9d0e121d3a');
    _client.onConnectionStateChanged = (int state, int reason) {
      _log('Connection state changed: ' +
          state.toString() +
          ', reason: ' +
          reason.toString());
      if (state == 5) {
        _client.logout();
        _log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
  }

  void _log(String info) {
    print(info);
    setState(() {
      _infoStrings.insert(0, info);
    });
  }
}
