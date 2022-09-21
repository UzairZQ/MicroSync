import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_pharma/homepage.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3FB1BB),
      appBar: AppBar(
        backgroundColor: Color(0xFF1FB7CC),
        title: const Center(
          child: Text(
            'Login',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
              'assets/images/login.png',
            ),
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      color: Colors.blue,
                      width: 10.0,
                    )),
                hintText: 'User ID',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10.0,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    style: BorderStyle.solid,
                    color: Colors.blue,
                    width: 10.0,
                  ),
                ),
              ),
              textAlign: TextAlign.center,
              obscureText: true,
            ),
            SizedBox(height: 15.0),
            Container(
              height: 40.0,
              width: 150.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, HomePage.id);
                },
                child: Text(
                  'Login',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFFB800),
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {},
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
