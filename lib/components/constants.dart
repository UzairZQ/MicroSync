import 'package:flutter/material.dart';

Color kappbarColor = const Color(0xff1FB7CC);

// ignore: must_be_immutable
class MyButton extends StatelessWidget {
  MyButton(
      {super.key, this.color, required this.text, required this.onPressed});
  Color? color = const Color(0xFFFFB800);
  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      width: 170.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.appBartxt});
  final String appBartxt;

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kappbarColor,
      centerTitle: true,
      title: Text(
        appBartxt,
        style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

final formKey = GlobalKey<FormState>();

//I have added a comment
TextStyle ktextstyle = const TextStyle(
    fontFamily: 'Poppins,', fontSize: 17.5, fontWeight: FontWeight.w400);

class MyTextwidget extends StatelessWidget {
  const MyTextwidget(
      {super.key, this.fontWeight, required this.fontSize, required this.text});

  final FontWeight? fontWeight;
  final double fontSize;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Poppins', fontWeight: fontWeight, fontSize: fontSize),
    );
  }
}

String? validateEmail(String? email) {
  if (email!.isEmpty) {
    return 'Please Enter Email Address';
  } else if (!RegExp(
          r'^[a-zA-Z0-9._%+-]+@(gmail|email|yahoo|outlook|hotmail|live|aol)\.[a-zA-Z]{2,}$')
      .hasMatch(email)) {
    return ("Please enter a valid Email Address ");
  } else {
    return null;
  }
}

String? validatePassword(String? password) {
  RegExp regex = RegExp(r'^.{6,}$');
  if (password!.isEmpty) {
    return 'Please Enter Password';
  } else if (!regex.hasMatch(password)) {
    return 'Enter Password with min. 6 Characters';
  } else {
    return null;
  }
}

Future<void> showCustomDialog({
  required BuildContext context,
  required Widget title,
  required Widget content,
  List<Widget>? actions,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title,
        content: SingleChildScrollView(
          child: content,
        ),
        actions: actions ??
            <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
      );
    },
  );
}

class MyTextFormField extends StatelessWidget {
 const MyTextFormField(
      {super.key,
      required this.hintext,
      this.onSaved,
      this.validator,
      this.controller});

  final String? hintext;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onSaved: onSaved,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[50],
        hintText: '$hintext',
        hintStyle: const TextStyle(fontFamily: 'Poppins'),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
