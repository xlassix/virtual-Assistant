import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/screens/todo_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = "registrationScreen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

//enum TextType { email, password }

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String displayName;
  String password;
  String confirmPassword;
  SharedPreferences prefs;

  final _auth = FirebaseAuth.instance;
  bool _loading = false;
  String errorMessage;

  // void update(TextType textType, String value) {
  //   setState(() {
  //     if (textType == TextType.email) {
  //       email = value;
  //     } else if (textType == TextType.password) {
  //       password = value;
  //     }
  //   });
  // }

  Widget errorWidget(String value) {
    String temp = value ?? "";
    temp = temp.toLowerCase().contains("network")
        ? "A network Error Occured"
        : temp.toLowerCase().contains("email-already-in-use")
            ? "Email address already exists"
            : temp;
    return temp.length > 0
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              temp,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          )
        : SizedBox(
            height: 24,
          );
  }

  void init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: "logo",
                  child: Container(
                    height: 100.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email),
                    hintText: 'Enter your Email',
                    labelText: 'Email *',
                  ),
                  validator:
                      EmailValidator(errorText: 'enter a valid email address'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    hintText: 'Enter password',
                    labelText: 'Password *',
                  ),
                  textAlign: TextAlign.center,
                  obscureText: true,
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'password is required'),
                    MinLengthValidator(8,
                        errorText: 'password must be at least 8 digits long'),
                    PatternValidator(r'(?=.*?[#?!@$%^&*-])',
                        errorText:
                            'passwords must have at least one special character')
                  ]),
                ),
                TextFormField(
                  onChanged: (value) {
                    confirmPassword = value;
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    hintText: 'Enter confirmed Password',
                    labelText: 'Confirm Password *',
                  ),
                  textAlign: TextAlign.center,
                  obscureText: true,
                  validator: (val) =>
                      MatchValidator(errorText: 'passwords do not match')
                          .validateMatch(val, password),
                ),
                errorWidget(errorMessage),
                TextButton(
                    child: Text('Sign Up'),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        setState(() {
                          _loading = true;
                        });
                        try {
                          final user =
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);
                          if (user != null) {
                            await user.user
                                .updateProfile(displayName: displayName);
                            await prefs.setString(
                                "userId", _auth.currentUser.uid);
                            await Navigator.pushNamedAndRemoveUntil(
                                context, TodoScreen.id, (route) => false);
                          }
                        } catch (e) {
                          print(e.toString());
                          setState(() {
                            errorMessage = e.toString();
                          });
                        }
                        setState(() {
                          _loading = false;
                        });
                      }
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "I have an Account.",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Login In",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
