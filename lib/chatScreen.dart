import 'dart:async';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:principal_club_app/Login.dart';
import 'package:intl/intl.dart';

class chat extends StatefulWidget {
  String username;
  AgoraRtmClient client1;
  chat({Key key, this.username, this.client1}) : super(key: key);

  @override
  _chatState createState() => _chatState();
}

AgoraRtmClient _client;
final _infoStrings = <String>[];
String _peerUser = "ab";
String _userName;
final _peerUserIdController = TextEditingController();
final _peerMessageController = TextEditingController();

Color colorContainer;
bool online;

String _timeString;

class _chatState extends State<chat> {
  @override
  void initState() {
    super.initState();
    _createClient();
    _toggleQuery();
    _timeString = _formatDateTime(DateTime.now());
    _getTime();
    online = false;
    colorContainer = Colors.red;
//Creates the client at the launch
  }

  bool _isLogin = true;

  static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);

  @override
  Widget build(BuildContext context) {
    _userName = widget.username;
    _client = widget.client1;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset("assets/Icons/back.png")),
          title: Row(
            children: [
              Text(
                'Chat',
                style: TextStyle(
                    color: Color(0xff000983),
                    fontSize: 25,
                    fontFamily: 'DM Serif Text',
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: colorContainer),
              )
            ],
          ),
          actions: [
            IconButton(
                iconSize: 30,
                onPressed: () {},
                icon: Image.asset('assets/Icons/notification.png')),
            SizedBox(
              child: IconButton(
                  onPressed: () {},
                  icon: Image.asset('assets/Icons/drawer.png')),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              //_buildLogin(),

              SizedBox(
                height: 10,
              ),
              _buildInfoList(),
              _buildSendPeerMessage(),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
  }

  //'5bba0ffad3fc4cb5ae0448840dc90d27'
  _createClient() async {
    _client = widget.client1;
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      _log(peerId + " : " + message.text);
      Container(
        color: Colors.red,
        child: Text(message.text),
      );
      print(peerId);
    };
    _client.onConnectionStateChanged = (int state, int reason) {
      Fluttertoast.showToast(
          msg: 'Connection state changed: ' +
              state.toString() +
              ', reason: ' +
              reason.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);

      if (state == 5) {
        _client.logout();
        _log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
  }

  Widget _buildLogin() {
    return Row(children: [
      _isLogin
          ? Expanded(child: new Text('User Id: ' + _userName, style: textStyle))
          : Expanded(child: Container())
    ]);
  }

  Widget _buildQueryOnlineStatus() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      new Expanded(
          child: new TextField(
              controller: _peerUserIdController,
              decoration: InputDecoration(hintText: 'Input peer user name'))),
      new OutlinedButton(
        child: Text('Check Online', style: textStyle),
        onPressed: _toggleQuery,
      ),
      SizedBox(
        width: 10,
      ),
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: colorContainer),
      )
    ]);
  }

  Widget _buildSendPeerMessage() {
    if (!_isLogin) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Color(0x23000983),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: <Widget>[
            new Expanded(
                child: new TextField(
                    enabled: true,
                    controller: _peerMessageController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Message..'))),
            new IconButton(
                icon: Image.asset(
                  'assets/Icons/chatsend.png',
                ),
                onPressed: _toggleSendPeerMessage)
          ]),
        ),
      ),
    );
  }

  Widget _buildInfoList() {
    return Expanded(
        child: Container(
            child: ListView.builder(
      itemExtent: 65,
      itemBuilder: (context, i) {
        print(_infoStrings[i].substring(0, _userName.length));
        if (_infoStrings[i].substring(0, _userName.length) == _userName) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                        color: Color(0xFF000983),
                      ),
                      height: 40,
                      width: 150,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        _infoStrings[i],
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ))
                ],
              ),
              Text(
                _timeString,
                style: TextStyle(
                    fontSize: 12, color: Colors.black, fontFamily: "poppins"),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        color: Color(0xFFDDDDDD),
                      ),
                      height: 40,
                      width: 150,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        _infoStrings[i],
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ))
                ],
              ),
              Text(
                _timeString,
                style: TextStyle(
                    fontSize: 12, color: Colors.black, fontFamily: "poppins"),
              ),
            ],
          );
        }
        /**return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _infoStrings[i],
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );**/
      },
      itemCount: _infoStrings.length,
    )));
  }

  void _toggleLogin() async {
    if (_isLogin) {
      try {
        await _client.logout();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => login()));

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
      String userId = _userName;
      if (userId.isEmpty) {
        Fluttertoast.showToast(
            msg: 'Please input your user id to login.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

        return;
      }

      try {
        await _client.login(null, userId);

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

  void _toggleQuery() async {
    String peerUid = _peerUser;
    if (peerUid.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Please input peer user id to query.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return;
    }
    try {
      Map<dynamic, dynamic> result =
          await _client.queryPeersOnlineStatus([peerUid]);

      //_log('Query result: ' + result.toString());
      if (result.toString() == "{" + _peerUserIdController.text + ": true}")
        setState(() {
          colorContainer = Colors.green;
          online = true;
        });
    } catch (errorCode) {
      _log('Query error: ' + errorCode.toString());
    }
  }

  void _toggleSendPeerMessage() async {
    String peerUid = _peerUser;
    if (peerUid.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Please input peer user id to send message.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return;
    }

    String text = _peerMessageController.text;
    if (text.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Please input text to send.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return;
    }

    try {
      AgoraRtmMessage message = AgoraRtmMessage.fromText(text);
      _log(_userName + ":" + message.text);

      Container(
        color: Colors.blue,
        child: Text(message.text),
      );
      await _client.sendMessageToPeer(peerUid, message, false);

      Fluttertoast.showToast(
          msg: 'Send peer message success.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    } catch (errorCode) {
      Fluttertoast.showToast(
          msg: 'Send peer message error: ' + errorCode.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  void _log(String info) {
    print(info);
    setState(() {
      _infoStrings.insert(_infoStrings.length, info);
    });
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }
}
