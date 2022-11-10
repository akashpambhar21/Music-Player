import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../nowplaying.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({Key? key}) : super(key: key);

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  playSong(String? uri) {
    try {
      _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(uri!)),
      );
      _audioPlayer.play();
    } on Exception {
      log("Error parsing song");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("Music Player"),
        // actions: [
        //   IconButton(
        //     onPressed: (){},
        //     icon: const Icon(Icons.search),),
        // ],
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
            sortType: null,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true),
        builder: (context, item) {
          if (item.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if(item.data!.isEmpty) {
            return const Center(child: Text("No Songs found"));
          }
          return ListView.builder(
              itemCount: item.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(item.data![index].title),
                  subtitle: Text(item.data![index].artist ?? "No Artist"),
                  leading: const CircleAvatar(
                    child: Icon(Icons.music_note),
                  ),
                  onTap: () {
                    List<SongModel>songs=item.data!;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NowPlaying(songmodel:songs,index:index,audioPlayer:_audioPlayer),
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => NowPlaying(item!.data[index]),
                      ),
                    );
                  },
                );
              }
              // itemCount: item.data!.length,
              );
        },
      ),
    );
  }
}
