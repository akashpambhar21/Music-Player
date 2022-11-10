import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadSong extends StatefulWidget {
  const UploadSong({Key? key}) : super(key: key);

  @override
  State<UploadSong> createState() => _UploadSongState();
}

class _UploadSongState extends State<UploadSong> {
  TextEditingController songname = TextEditingController();
  TextEditingController artistname = TextEditingController();
  PlatformFile? pickedImage, pickedSong;

  Future selectImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      print("No image selected!");
      return;
    }
    setState(() {
      pickedImage = result.files.first;
    });
  }

  Future selectSong() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      print("No song selected!");
      return;
    }
    setState(() {
      pickedSong = result.files.first;
    });
  }

  Future<String> uploadImage() async {
    if (pickedImage != null) {
      final path = 'images/${pickedImage!.name}';
      final file = File(pickedImage!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);
      ref.putFile(file);
      return await ref.getDownloadURL();
    }
    return "";
  }

  Future<String> uploadSong() async {
    if (pickedSong != null) {
      final path = 'songs/${pickedSong!.name}';
      final file = File(pickedSong!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);
      ref.putFile(file);
      return await ref.getDownloadURL();
    }
    return "";
  }

  Future upload() async {
    if (pickedSong != null &&
        pickedImage != null &&
        songname.text!="" &&
        artistname.text!="") {
      print("checkpost1");
      String image = await uploadImage() ;
      String song = await uploadSong();
      print(image+" "+song);
      print("hello heloo");
      if (image.isNotEmpty && song.isNotEmpty) {
        FirebaseFirestore.instance.collection('songs').doc().set({
          'name': songname.text,
          'artistname': artistname.text,
          'songurl':song,
          'image':image,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Welcome Admin"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],

      ),
      body: Container(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Text('Selected Image:'),
              pickedImage != null?Image.file(
                File(pickedImage!.path!),
                width: 100,
                fit: BoxFit.fill,
              ):Text(" "),
              RaisedButton(
                onPressed: selectImage,
                child: Text("Select Image"),
                color: Colors.blue,
              ),
              RaisedButton(
                onPressed: selectSong,
                child: Text("Select Song"),
                color: Colors.blue,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: TextField(
                  controller: songname,
                  decoration: InputDecoration(
                    hintText: "Enter song name",
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: TextField(
                  controller: artistname,
                  decoration: InputDecoration(
                    hintText: "Enter artist name",
                  ),
                ),
              ),
              RaisedButton(
                onPressed: upload,
                child: Text("Upload"),
                color: Colors.redAccent,
              ),
            ],
          )),
    );
    ;
  }
}