import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/pages/Order.dart';
import 'package:shope/pages/account.dart';
import 'package:shope/pages/favorite.dart';
import 'package:shope/pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas Akhir Andri',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: "MaisonNeue",
      ),
      routes: <String, WidgetBuilder>{
        '/CheckUser': (BuildContext context) => new CheckUser(),
      },
      home: CheckUser(),
    );
  }
}

//check user yang masukk
class CheckUser extends StatefulWidget {
  @override
  _CheckUserState createState() => _CheckUserState();
}

enum LoginStatus { notSignIn, signIn, userSignIn, verifikasi }

class _CheckUserState extends State<CheckUser> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;

  var value;
  var status;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getString("level");
      status = preferences.getString("status1");
      if (status == "2") {
        _loginStatus = LoginStatus.verifikasi;
      } else if (value == "1") {
        _loginStatus = LoginStatus.signIn;
      } else if (value == "2") {
        _loginStatus = LoginStatus.userSignIn;
      } else {
        _loginStatus = LoginStatus.notSignIn;
      }
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.clear();
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return MyHomePage();
        break;
      case LoginStatus.signIn:
        return MyHomeSignIn(signOut);
        break;
      case LoginStatus.userSignIn:
        return MyHomeUser(signOut);
        break;
      case LoginStatus.verifikasi:
        return VerifikasiLogin(signOut);
        break;
    }
  }
}

class VerifikasiLogin extends StatefulWidget {
  final VoidCallback signOut;
  VerifikasiLogin(this.signOut);
  @override
  _VerifikasiLoginState createState() => _VerifikasiLoginState();
}

class _VerifikasiLoginState extends State<VerifikasiLogin> {
  signOut() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Information"),
            content: Text("apakah anda ingin keluar.?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Text("no"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    widget.signOut();
                  });
                },
                child: Text("Ok"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Status Akun"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: Icon(Icons.lock_open),
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 3),
                  Text(
                    "Akun Anda Menunggu Verifikasi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.5,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Mohon Menunggu Admin Melakukan Verifikasi"),
                  Text("Terima Kasih Atas Perhatiannya"),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      signOut();
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Keluar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//Halaman setelah masuk
class MyHomeSignIn extends StatefulWidget {
  final VoidCallback signOut;
  MyHomeSignIn(this.signOut);

  @override
  _MyHomeSignInState createState() => _MyHomeSignInState();
}

class _MyHomeSignInState extends State<MyHomeSignIn> {
  int i = 0;
  final List<Widget> pages = [
    Home(),
    Order(),
    Favorite(),
    Account(),
  ];

  signOut() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Information"),
            content: Text("apakah anda ingin keluar.?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Text("no"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    widget.signOut();
                  });
                },
                child: Text("Ok"),
              )
            ],
          );
        });
  }

  void _incremenTab(index) {
    setState(() {
      i = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: Icon(Icons.lock_open),
          ),
        ],
      ),
      body: pages[i],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: i,
          onTap: (index) {
            _incremenTab(index);
          },
          items: [
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/home.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/home-non.png', scale: 2.5),
                ),
                title: Text('Home')),
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/orders.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child:
                      Image.asset('assets/images/orders-non.png', scale: 2.5),
                ),
                title: Text('Orders')),
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/love.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/non-love.png', scale: 2.5),
                ),
                title: Text('Favorite')),
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/account.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child:
                      Image.asset('assets/images/account-non.png', scale: 2.5),
                ),
                title: Text('Account')),
          ]),
    );
  }
}

//halaman sebelum masuk
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int i = 0;
  final List<Widget> pages = [
    Home(),
    NonOrder(),
    FavoriteNonLogin(),
    NotAccount(),
  ];

  void _incremenTab(index) {
    setState(() {
      i = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[i],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: i,
          onTap: (index) {
            _incremenTab(index);
          },
          items: [
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/home.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/home-non.png', scale: 2.5),
                ),
                title: Text('Home')),
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/orders.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child:
                      Image.asset('assets/images/orders-non.png', scale: 2.5),
                ),
                title: Text('Orders')),
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/love.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/non-love.png', scale: 2.5),
                ),
                title: Text('Favorite')),
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/account.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child:
                      Image.asset('assets/images/account-non.png', scale: 2.5),
                ),
                title: Text('Account')),
          ]),
    );
  }
}

//halaman masuk sebagai user
class MyHomeUser extends StatefulWidget {
  final VoidCallback signOut;
  MyHomeUser(this.signOut);
  @override
  _MyHomeUserState createState() => _MyHomeUserState();
}

class _MyHomeUserState extends State<MyHomeUser> {
  int i = 0;
  final List<Widget> pages = [
    Home(),
    Order(),
    Favorite(),
    Account(),
  ];

  signOut() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Informasi"),
            content: Text("Apakah anda ingin keluar.?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Text("No"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    widget.signOut();
                  });
                },
                child: Text("Ok"),
              )
            ],
          );
        });
  }

  void _incremenTab(index) {
    setState(() {
      i = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: Icon(Icons.lock_open),
          ),
        ],
      ),
      body: pages[i],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: i,
          onTap: (index) {
            _incremenTab(index);
          },
          items: [
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/home.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/home-non.png', scale: 2.5),
                ),
                title: Text('Home')),
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/orders.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child:
                      Image.asset('assets/images/orders-non.png', scale: 2.5),
                ),
                title: Text('Orders')),
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/love.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/non-love.png', scale: 2.5),
                ),
                title: Text('Favorite')),
            BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset('assets/images/account.png', scale: 2.5),
                ),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child:
                      Image.asset('assets/images/account-non.png', scale: 2.5),
                ),
                title: Text('Account')),
          ]),
    );
  }
}
