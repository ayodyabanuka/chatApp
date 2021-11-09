import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:principal_club_app/Login.dart';

class chat extends StatefulWidget {
  String username;
  AgoraRtmClient client1;
  chat({Key key, this.username, this.client1}) : super(key: key);

  @override
  _chatState createState() => _chatState();
}

AgoraRtmClient _client;
final _infoStrings = <dynamic>[];
String _userName;
final _peerUserIdController = TextEditingController();
final _peerMessageController = TextEditingController();

class _chatState extends State<chat> {
  @override
  void initState() {
    super.initState();
    _createClient();

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
          backgroundColor: Colors.blue,
          leading: Container(),
          title: Text("Chat"),
          leadingWidth: 0,
          actions: [
            IconButton(
                onPressed: () {
                  _toggleLogin();
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              //_buildLogin(),
              _buildQueryOnlineStatus(),
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
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      _log("Peer msg: " + peerId + ", msg: " + message.text, Colors.red,
          CrossAxisAlignment.start);
      Container(
        color: Colors.red,
        child: Text(message.text),
      );
      print(peerId);
    };
    _client.onConnectionStateChanged = (int state, int reason) {
      _log(
          'Connection state changed: ' +
              state.toString() +
              ', reason: ' +
              reason.toString(),
          Colors.black,
          CrossAxisAlignment.center);
      if (state == 5) {
        _client.logout();
        _log('Logout.', Colors.black, CrossAxisAlignment.center);
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
      )
    ]);
  }

  Widget _buildSendPeerMessage() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      new Expanded(
          child: new TextField(
              controller: _peerMessageController,
              decoration: InputDecoration(hintText: 'Enter Message..'))),
      new IconButton(
        icon: Icon(Icons.send),
        onPressed: _toggleSendPeerMessage,
      )
    ]);
  }

  Widget _buildInfoList() {
    return Expanded(
        child: Container(
            child: ListView.builder(
      itemExtent: 24,
      itemBuilder: (context, i) {
        return Padding(
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
        );
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
    String peerUid = _peerUserIdController.text;
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
      _log('Query result: ' + result.toString(), Colors.black,
          CrossAxisAlignment.center);
    } catch (errorCode) {
      _log('Query error: ' + errorCode.toString(), Colors.black,
          CrossAxisAlignment.center);
    }
  }

  void _toggleSendPeerMessage() async {
    String peerUid = _peerUserIdController.text;
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
      _log(message.text, Colors.blue, CrossAxisAlignment.end);
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

  void _log(
      String info, Color color, CrossAxisAlignment crossAxisAlignmenttext) {
    print(info);
    setState(() {
      _infoStrings.insert(_infoStrings.length, info);
    });
  }
}
