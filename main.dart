import 'package:flutter/material.dart';
import 'session.dart';
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyLoginPage(title: 'Login'),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyLoginPageState createState() => new _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      // This call to setState tells the Flutter framework that something has
//      // changed in this State, which causes it to rerun the build method below
//      // so that the display can reflect the updated values. If we changed
//      // _counter without calling setState(), then the build method would not be
//      // called again, and so nothing would appear to happen.
//      _counter++;
//    });
//  }
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String username = '';
  String password = '';

  Session session = new Session();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
      print('Authorised');
    } else {
      print('Authorisation failed');
      final snackBar = SnackBar(content: Text('Login Failed'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }
}
