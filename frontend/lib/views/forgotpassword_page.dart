import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:obl_ihc_pruebasconflutter/utils.dart';
import 'package:obl_ihc_pruebasconflutter/views/login_page.dart';

// ==========================
// Vista
// ==========================
class ForgotPasswordPage extends StatefulWidget {
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olvidé mi contraseña'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Te enviaremos un enlace para restablecer tu contraseña. \n\nPor favor, proporciona tu dirección de correo electrónico a continuación.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 100),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                sendPasswordResetEmail();
                Future.delayed(Duration(seconds: 6), () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                });
              },
              icon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              label: Text(
                'Enviar enlace',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // Lógica
  // ==========================
  Future<void> sendPasswordResetEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se ha enviado un enlace para restablecer la contraseña a su correo electrónico.',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          Utils.getSnackBarError('No se pudo enviar el enlace para restablecer la contraseña. Verifique su correo electrónico e inténtelo nuevamente.')
      );
    }
  }
}