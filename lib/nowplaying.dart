import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({Key? key, required this.songmodel, required this.index, required this.audioPlayer}) : super(key: key);
  final List<SongModel> songmodel;
  final int index;
  final AudioPlayer audioPlayer;
  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  int _index=0;
  Duration position = new Duration();
  Duration musicLength = new Duration();
  bool playing = false;
  IconData playBtn = Icons.pause; // the main state of the play button icon
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playing=true;
    setSongs();
    _index=widget.index;
  }
  void setSongs() {
    try {
      widget.audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(widget.songmodel[_index].uri!),

      ));
      if(playing){
        playSong();
      }
    } on Exception {
      print('Error in playing song');
    }
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        musicLength = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        position = p;
      });
    });
  }
  void playSong() {
    widget.audioPlayer.play();
    playing = true;
  }

  void changeToSecond(int seek) {
    Duration duration = new Duration(seconds: seek);
    widget.audioPlayer.seek(duration);
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 100.0,
                      child: Icon(
                        Icons.music_note,
                        size: 80.0,
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Center(
                      child:Text(
                        widget.songmodel[_index].displayNameWOExt.toString(),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child:Text(
                        widget.songmodel[_index].artist.toString(),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Text(position.toString().split(".")[0]),
                        Expanded(
                          child: Slider(
                              max: musicLength.inSeconds.toDouble(),
                              min: const Duration(microseconds: 0)
                                  .inSeconds
                                  .toDouble(),
                              value: position.inSeconds.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              changeToSecond(value.toInt());
                              value = value;
                            });
                          }),
                        ),
                        Text(musicLength.toString().split(".")[0],),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            onPressed: (){
                              changeToSecond(0);
                            },
                            icon: Icon(Icons.repeat_one_outlined,size: 35.0,),
                        ),

                        IconButton(
                          iconSize: 45.0,
                          color: Colors.black,
                          onPressed: () {
                            if (_index != 0) {
                              _index--;
                            } else {
                              _index = widget.songmodel.length - 1;
                            }
                            setState((){
                              setSongs();
                            });
                          },
                          icon: const Icon(
                            Icons.skip_previous,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (!playing) {
                              //now let's play the song
                              setState(() {
                                widget.audioPlayer.play();
                                playBtn = Icons.pause;
                                playing = true;
                              });
                            } else {
                              setState(() {
                                widget.audioPlayer.pause();
                                playBtn = Icons.play_arrow;
                                playing = false;
                              });
                            }
                          },
                          icon: Icon(
                            playBtn,
                            size: 40.0,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        IconButton(
                          iconSize: 45.0,
                          color: Colors.black,
                          onPressed: () {
                            if (_index == widget.songmodel.length - 1) {
                              _index = 0;
                            } else {
                              _index++;
                            }
                            // setState((){
                            setSongs();
                          },
                          icon: const Icon(
                            Icons.skip_next,
                          ),
                        ),
                        IconButton(
                            onPressed: (){
                              Duration duration = new Duration(seconds: 10);
                              widget.audioPlayer.seek(position+duration);
                            },
                            icon: Icon(Icons.fast_forward_sharp,size: 35.0,)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
