import 'package:flutter/material.dart';
import 'session.dart';
import 'dart:convert';

void main() => runApp(new MyApp());

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
  String otherId = 'p2';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chats'), actions: <Widget>[
        new IconButton(icon: const Icon(Icons.create), onPressed: null),
        new IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatDetail(
                            session: widget.session,
                            id: widget.id,
                            otherId: otherId,
                          )));
            }),
        new IconButton(icon: const Icon(Icons.exit_to_app), onPressed: null)
      ]),
      body: Text('Hello and fuck off'),
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
      session.post('http://10.196.5.236:8080/outlab8/LoginServlet',
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

  ChatDetail({Key key, this.session, this.id, this.otherId}) : super(key: key);
  @override
  _ChatDetailState createState() => new _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
//  String id = widget.id;
//  String otherId = ;
//
//  var Session session;
//  session = widget.session;
  var _messages = <Map<String, dynamic>>[];

  void _resToConv(s) {
    Map<String, dynamic> response = json.decode(s);
    _messages = response["data"];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    widget.session.post('http://10.196.5.236:8080/outlab8/LoginServlet',
        {"id": widget.id, "other_id": widget.otherId}).then(_resToConv);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.otherId),
      ),
      body: new Column(
        children: <Widget>[
          _buildConv(),
          new Divider(
            height: 1.0,
          ),
          new TextFormField(
            onFieldSubmitted: (val) {
              widget.session.post(
                  'http://10.196.5.236:8080/outlab8/LoginServlet',
                  {"id": widget.id, "other_id": widget.otherId, "msg": val});
            },
          )
        ],
      ),
    );
  }

  Widget _buildConv() {
    return ListView.builder(itemBuilder: (context, i) {
      return ListTile(
        title: Text(_messages[i]["text"]),
      );
    });
  }
}
