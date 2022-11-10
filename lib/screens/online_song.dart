import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/screens/login_screen.dart';

import '../model/user_model.dart';
// import 'package:music_player/screens/songpage.dart';

class OnlineSong extends StatefulWidget {
  OnlineSong({Key? key}) : super(key: key);
  // Function miniPlayer;

  @override
  _OnlineSongState createState() => _OnlineSongState();
}

class _OnlineSongState extends State<OnlineSong> {
  User? user = FirebaseAuth.instance.currentUser;
  late List<DocumentSnapshot> _list;
  AudioPlayer audioPlayer = new AudioPlayer();
  bool isPlaying=true;
  dynamic music;
  UserModel loggedInUser = UserModel();

  @override
  initState(){
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
  //
  // Widget miniPlayer(DocumentSnapshot documentSnapshot,{bool stop=false}) {
  //   if (documentSnapshot == null) {
  //     return SizedBox();
  //   }
  //   this.music = documentSnapshot;
  //   if(stop){
  //     isPlaying=false;
  //     audioPlayer.stop();
  //   }
  //   // setState(() {});
  //   Size deviceSize = MediaQuery.of(context).size;
  //
  //   return Column(
  //     children: [
  //       AnimatedContainer(
  //         duration: const Duration(milliseconds: 450),
  //         color: Colors.brown,
  //         width: deviceSize.width,
  //         height: 50,
  //         child: InkWell(
  //           onTap: (){
  //             audioPlayer.setAudioSource(AudioSource.uri(
  //                 Uri.parse((documentSnapshot.data()! as Map)['songurl'])));
  //             !isPlaying?audioPlayer.play():audioPlayer.pause();
  //             isPlaying=!isPlaying;
  //             // isPlaying?myBtn=Icon(Icons.play_arrow):Icon(Icons.pause);
  //             print(isPlaying);
  //
  //           },
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Image.network(
  //                 (documentSnapshot.data()! as Map)['image'],
  //                 fit: BoxFit.cover,
  //               ),
  //
  //               Padding(
  //                 padding: const EdgeInsets.only(left:130.0),
  //                 child: Text((documentSnapshot.data()! as Map)['name'],
  //                     style: TextStyle(color: Colors.white)),
  //               ),
  //
  //               // IconButton(
  //               //   onPressed: (){},
  //               //   icon: myBtn,
  //               //   color: Colors.white,
  //               // )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget createMusicList(String label) {
    //itemBuilder creates a scrollable, linear array of widgets that are created on demand.This constructor is appropriate for list views with a large (or infinite) number of children because the builder is called only for those children that are actually visible.
    return Padding(
      padding: const EdgeInsets.only(left:15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,style: const TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
          SizedBox(
            height: 400,
            child: ListView.custom(
                scrollDirection: Axis.horizontal,
                childrenDelegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return createMusic( _list[index]);
                  },
                  childCount: _list.length,
                )),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    void logoutUser() async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>LoginScreen()));
      // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>Login()))
    }
    User _auth= FirebaseAuth.instance.currentUser!;
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('songs')
            .orderBy('name')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
             child: CircularProgressIndicator(),
            );
          } else {
            _list = snapshot.data!.docs;

     return SingleChildScrollView(
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
              Colors.blueGrey.shade300,
              Colors.black,
              Colors.black,
              Colors.black
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),

          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                // elevation property controls the size of the shadow below the app bar if shadowColor is not null If surfaceTintColor is not null then it will apply a surface tint overlay to the background color (see Material.surfaceTintColor for more detail).
                elevation: 0.0,
                title: Text("Welcome ${loggedInUser.firstName}"),
                actions: [
                Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                onTap: logoutUser,
                child: Icon(Icons.logout)),
                )
                ],
              ),

            createMusicList('Trending now'),
            createMusicList('Best of artists'),
            // createMusicList('Remix')
            //   (music!=null)?miniPlayer(music,stop: true):SizedBox(),
            ],
          ),
          ),
        ),
    );
    }
    },
    )
    );

  }
  Widget createMusic(DocumentSnapshot documentSnapshot) {
    return Padding(
      padding: EdgeInsets.only(top: 10, right: 12),
      child: Column(
        //we make it align to start so that song name and description comes at the start of the column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: 200,
            child: InkWell(
              onTap: () {
                // miniPlayer(documentSnapshot);
                audioPlayer.setAudioSource(AudioSource.uri(
                    Uri.parse((documentSnapshot.data()! as Map)['songurl'])));
                !isPlaying?audioPlayer.play():audioPlayer.pause();
                isPlaying=!isPlaying;
                setState(() {

                });
              },
              child: Image.network(
                (documentSnapshot.data()! as Map)['image'],
                // 'https://firebasestorage.googleapis.com/v0/b/music-player-ca0c9.appspot.com/o/images%2F41JINRlOkpL.jpg?alt=media&token=68c96fb0-c7a0-4f3b-ae95-9e0ec1cedbb5',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // SizedBox(),
          Text((documentSnapshot.data()! as Map)['name'],
              style: const TextStyle(color: Colors.white)),
          Text((documentSnapshot.data()! as Map)['artistname'],
              style: const TextStyle(color: Colors.white))
          // Text((documentSnapshot.data()! as Map)['image']),
        ],
      ),
    );
  }
  // Widget buildList(BuildContext context, DocumentSnapshot documentSnapshot) {
    // return InkWell(
      // onTap: () => Navigator.push(
          // context,
          // MaterialPageRoute(
          //     builder: (context) => Songspage(
          //       song_name: (documentSnapshot.data()! as Map)['name'],
          //       artist_name: (documentSnapshot.data()! as Map)["artist"],
          //       song_url: (documentSnapshot.data()! as Map)["songurl"],
          //       image_url: (documentSnapshot.data()! as Map)["image"],
          //     ))),
      // child: Padding(
      //   padding: const EdgeInsets.only(left:15),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text('Old hits',style: const TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
      //       SizedBox(
      //         height: 270,
      //         child: ListView.builder(
      //             scrollDirection: Axis.horizontal,
      //             itemBuilder: (context, index) {
      //               return createMusic(documentSnapshot);
      //             },
      //             itemCount: 3),
      //       ),
      //     ],
      //   ),
      // ),
    // );
  // }
}