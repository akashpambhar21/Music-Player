import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player/model/user_model.dart';
import 'package:music_player/screens/all_songs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'online_song.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("Music Player"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 180,
                child: Image.asset(
                  'assets/music.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
               Text(
                "Welcome ${loggedInUser.firstName}",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Text(
              //   " ${loggedInUser.firstName} ${loggedInUser.secondName}",
              //   style: const TextStyle(
              //     fontSize: 18,
              //     color: Colors.black54,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              // Text(
              //   "${loggedInUser.email}",
              //   style: const TextStyle(
              //     fontSize: 18,
              //     color: Colors.black54,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              const SizedBox(
                height: 15,
              ),
              ActionChip(
                label: const Text("Play Local Songs",style: TextStyle(color: Colors.white),),
                backgroundColor: Colors.blue[900],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllSongs()),
                  );
                },
              ),

              // ActionChip(
              //   label: const Text("Listen popular artist"),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => const AllSongs()),
              //     );
              //   },
              // ),

              ActionChip(
                label: const Text("Online Music Streaming",style: TextStyle(color: Colors.white),),
                backgroundColor: Colors.blue[900],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>OnlineSong()),
                  );
                },
              ),

              ActionChip(
                label: const Text("Logout",style: TextStyle(color: Colors.white),),
                backgroundColor: Colors.redAccent,
                onPressed: () {
                  logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
