import 'package:firebase_app/variables..dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 60),
          CircleAvatar(
            radius: 80,
            backgroundImage: (Global.user != null)
                ? NetworkImage("${Global.user!.photoURL}")
                : null,
          ),
          (Global.user != null)
              ? (Global.user!.displayName != null)
                  ? Text("Name: ${Global.user!.displayName}")
                  : Text("Name: Not Available")
              : Text("Name: Not Available"),
          (Global.user != null)
              ? Text("Email: ${Global.user!.email}")
              : Text("Email: Not Available"),
        ],
      ),
    );
  }
}
