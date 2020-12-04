import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InfoUpdate extends StatefulWidget {
  @override
  _InfoUpdateState createState() => _InfoUpdateState();
}

class _InfoUpdateState extends State<InfoUpdate> {
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController passwordUpdateController = TextEditingController();
  bool _passwordVisible = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  var oldPass;
  bool isUser;
  var title = 'Change password...';
  final User user = FirebaseAuth.instance.currentUser;

  // @override
  // void initState() {}
  void passCheck() {
    AuthCredential authCredential = EmailAuthProvider.credential(
      email: user.email,
      password: oldPass,
    );

    user
        .reauthenticateWithCredential(authCredential)
        .then((value) => () {
              setState(() {
                isUser = true;
              });
            })
        .catchError((error) {
      setState(() {
        isUser = true;
        print('WOUIUIUI ' + error.toString());
      });
    });
    print('lasha ' + oldPass);
  }

  void snackbar(BuildContext context) {
    // final scaffold = Scaffold.of(context)
    //     .showSnackBar(SnackBar(content: Text('Successfuly Updated!')));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            onChanged: (value) {
              setState(() {
                oldPass = value;
              });
              print('ikant ' + oldPass);
              passCheck();
            },
            autofocus: true,
            textInputAction: TextInputAction.done,
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
            },
            obscureText: !this._passwordVisible,
            controller: oldPasswordController,
            decoration: InputDecoration(
                hintText: 'Enter old password...',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
                suffixIcon: IconButton(
                  icon: Icon(
                    this._passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    setState(() {
                      this._passwordVisible = !this._passwordVisible;
                    });
                  },
                )),
            validator: (value) {
              //passCheck();
              //print('ikant ' + oldPass);
              if (value.isEmpty) {
                return 'Enter Password';
              } else if (value.length < 6) {
                return 'Password too short!';
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            autofocus: true,
            textInputAction: TextInputAction.done,
            onEditingComplete: () => FocusScope.of(context).unfocus(),
            obscureText: !this._passwordVisible,
            controller: passwordUpdateController,
            decoration: InputDecoration(
                hintText: 'Enter New password...',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
                suffixIcon: IconButton(
                  icon: Icon(
                    this._passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    setState(() {
                      this._passwordVisible = !this._passwordVisible;
                    });
                  },
                )),
            validator: (value) {
              if (value.isEmpty) {
                return 'Enter Password';
              } else if (value.length < 6) {
                return 'Password too short!';
              }
              return null;
            },
          ),
        ]),
      ),
      actions: [
        new FlatButton(
          onPressed: () {
            if (_formKey.currentState.validate() && isUser == true) {
              setState(() {
                this
                    ._firebaseAuth
                    .currentUser
                    .updatePassword(passwordUpdateController.text.trim())
                    .then((value) => snackbar)
                    .catchError((error) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(error.toString())));
                  print('IJIJIJIJI ' + error.toString());
                  //title = error.toString();
                });
              });

              Navigator.of(context).pop();
            } else {
              print('ZIZIZ ' + isUser.toString() + ' ' + oldPass);
            }
          },
          child: new Text('Submit'),
        ),
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: new Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    passwordUpdateController.dispose();

    super.dispose();
  }
}
