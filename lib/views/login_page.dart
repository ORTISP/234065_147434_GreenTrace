import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:obl_ihc_pruebasconflutter/views/home_page.dart';
import 'package:obl_ihc_pruebasconflutter/views/forgotpassword_page.dart';
import 'package:obl_ihc_pruebasconflutter/views/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _saveData(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("token", value);
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();

  void setDemo() {
    setState(() {
      emailController.text = "demo@greentrace.uy";
      passwordController.text = "demo1234";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GreenTrace'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () async {
                try {
                  final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  if (userCredential.user != null) {
                    final User user = userCredential.user!;
                    _saveData("yes");
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => HomePage(user),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Credenciales incorrectas',
                        style: TextStyle(color: Colors.white),
                      ),
                      duration: Duration(seconds: 5),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: Icon(
                Icons.login,
                color: Colors.white,
              ),
              label: Text('Iniciar sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10.0),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordPage(),
                  ),
                );
              },
              child: Text('Olvidé mi contraseña',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            GestureDetector(
              onTap: () {
                setDemo();
              },
              child: Text('Iniciar Demo',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 12.0),
            Center(
              child: Column(
                children: <Widget>[
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(Size(40, 40)),
                    ),
                    onPressed: () async {
                      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
                      final AuthCredential credential = GoogleAuthProvider.credential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );

                      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

                      if (userCredential.user != null) {
                        final User user = userCredential.user!;
                        _saveData("yes");
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => HomePage(user),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.g_mobiledata,
                      color: Colors.white,
                    ),
                    label: Text('Iniciar sesión con Google',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              },
              child: Text('¿No tienes una cuenta? Regístrate aquí',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}