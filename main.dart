import 'package:flutter/material.dart';
import 'session.dart';
import 'dart:convert';
import 'package:async_loader/async_loader.dart';
import 'dart:async';

void main() => runApp(new MyApp());

const String _url = 'http://192.168.0.165:8080/outlab8/';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'What A Sap',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyLoginPage(title: 'Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.session, this.id}) : super(key: key);
  final Session session;
  final String id;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  var _allConv = <dynamic>[];

  void _allConversations(s) {
    Map<String, dynamic> response = json.decode(s);
    setState(() {
      _allConv = response["data"];
    });
  }

  Widget _buildRow(dynamic row) {
    return new ListTile(
      title: Text(row["name"], style: _biggerFont),
      trailing: Text(row["timestamp"]),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatDetail(
                      session: widget.session,
                      id: widget.id,
                      otherId: row["uid"],
                      otherName: row["name"],
                    )));
      },
    );
  }

  Widget _buildChats() {
    print("hi");
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (_, i) {
//        else
        return _buildRow(_allConv[i]);
      },
      itemCount: _allConv.length,
    );
  }

  _getChats() async {
    widget.session.post(
        _url + 'AllConversations', {"id": widget.id}).then(_allConversations);
    return new Future.delayed(Duration(seconds: 1), () => _buildChats());
  }

  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();

  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
      key: _asyncLoaderState,
      initState: () async => await _getChats(),
      renderLoad: () => Text("Loading : Wait for some time"),
      renderSuccess: ({data}) => data,
    );

    print(_allConv.length);
    return Scaffold(
      appBar: AppBar(title: Text('Chats'), actions: <Widget>[
        new IconButton(icon: const Icon(Icons.create), onPressed: null),
        new IconButton(
          icon: const Icon(Icons.home), onPressed: null,
//            onPressed: () {
//              Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      builder: (context) => ChatDetail(
//                            session: widget.session,
//                            id: widget.id,
//                            otherId: otherId,
//                          )));
//            }
        ),
        new IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context);
            })
      ]),
      body: _asyncLoader,
    );
  }
}

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyLoginPageState createState() => new _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String username = '';
  String password = '';

  Session session = new Session();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Form(
          key: _formKey,
          autovalidate: true,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new TextFormField(
                validator: (val) => val.isEmpty ? "Username is required" : null,
                onSaved: (val) => username = val,
              ),
              new TextFormField(
                validator: (val) => val.isEmpty ? "Password is required" : null,
                onSaved: (val) => password = val,
              ),
              new RaisedButton(
                onPressed: _authUser,
                child: const Text('Login'),
              )
            ],
          ),
        ),
      ),
//      floatingActionButton: new FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: new Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _authUser() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      print('Username: $username');
      print('Password: $password');
      session.post(_url + 'LoginServlet',
          {"userid": username, "password": password}).then(_resToAuth);
    }
  }

  void _resToAuth(s) {
    Map<String, dynamic> response = json.decode(s);
    if (response['status']) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MyHomePage(session: session, id: username)));
      print('Authorised');
    } else {
      print('Authorisation failed');
      final snackBar = SnackBar(content: Text('Login Failed'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}

class ChatDetail extends StatefulWidget {
  final Session session;
  final String id;
  final String otherId;
  final String otherName;

  ChatDetail({Key key, this.session, this.id, this.otherId, this.otherName})
      : super(key: key);
  @override
  _ChatDetailState createState() => new _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final TextEditingController _textController = new TextEditingController();
  var _messages = <dynamic>[];

  void _resToConv(s) {
    Map<String, dynamic> response = json.decode(s);
    setState(() {
      _messages = response["data"];
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    widget.session.post(_url + 'ConversationDetail',
        {"id": widget.id, "other_id": widget.otherId}).then(_resToConv);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.otherName),
      ),
      body: new Column(
        children: <Widget>[
//
          new Flexible(
              child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, i) => new ChatMessage(
                  name: _messages[i]["name"],
                  text: _messages[i]["text"],
                ),
            itemCount: _messages.length,
          )),
          new Divider(
            height: 1.0,
          ),
          new Container(
            child: _buildTextComposer(),
          )
        ],
      ),
    );
  }

//  Widget _buildChat() {
//    return
//  }

  void _handleSubmitted(String val) {
    _textController.clear();
    widget.session.post(_url + 'NewMessage', {
      "id": widget.id,
      "other_id": widget.otherId,
      "msg": val
    }).then((val) => widget.session.post(_url + 'ConversationDetail',
        {"id": widget.id, "other_id": widget.otherId}).then(_resToConv));
  }

  Widget _buildTextComposer() {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          new Flexible(
            child: new TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration:
                  new InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text)),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String name;
  final String text;

  ChatMessage({this.name, this.text});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(name),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: Text(text),
              )
            ],
          )
        ],
      ),
    );
  }
}
