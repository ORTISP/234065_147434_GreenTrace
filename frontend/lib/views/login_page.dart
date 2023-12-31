import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:obl_ihc_pruebasconflutter/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:obl_ihc_pruebasconflutter/views/home_page.dart';
import 'package:obl_ihc_pruebasconflutter/views/forgotpassword_page.dart';
import 'package:obl_ihc_pruebasconflutter/views/register_page.dart';

// ==========================
// Vista
// ==========================
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

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
            Image.asset('images/GREENTRACE_WHITE.png', width: 200),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 160,
              height: 40,
              child:
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
                      saveData("yes");
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => HomePage(user),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      Utils.getSnackBarError('Credenciales incorrectas')
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
            SizedBox(height: 20),
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
                        saveData("yes");
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

// ==========================
// Lógica
// ==========================
void saveData(String value) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("token", value);
}