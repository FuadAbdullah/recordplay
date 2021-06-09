import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:convert';
import 'dart:math';

// https://github.com/Canardoux/tau/blob/master/flutter_sound/example/lib/simple_playback/simple_playback.dart

void main() {
  runApp(SoundPlayer());
}

class SoundPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Record And Play",
        home: SoundPlayerHome());
  }
}

class SoundPlayerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: DefaultAppBar(), body: SoundPlayerCore());
  }

  Widget DefaultAppBar() {
    return AppBar(
      title: Text("Record And Play"),
      centerTitle: true,
    );
  }
}

class SoundPlayerCore extends StatefulWidget {
  @override
  _SoundPlayerCoreState createState() => _SoundPlayerCoreState();
}

class _SoundPlayerCoreState extends State<SoundPlayerCore> {
  FlutterSoundPlayer DefaultSoundPlayer;
  List soundURI = [];

  String _durationFormatter(Duration duration) {
    String doubleDigit(int dD) => dD.toString().padLeft(2, "0");
    String quadDigit(int dD) => dD.toString().padLeft(4, "0");
    String doubleDigitMilliseconds =
        quadDigit(duration.inMilliseconds.remainder(1000));
    String doubleDigitSeconds = doubleDigit(duration.inSeconds.remainder(60));
    String doubleDigitMinutes = doubleDigit(duration.inMinutes.remainder(60));
    return "${doubleDigit(duration.inHours)}:$doubleDigitMinutes:$doubleDigitSeconds:$doubleDigitMilliseconds";
  }

  int _randomIndex(){
    final _rnd = new Random();
    return _rnd.nextInt(soundURI.length);
  }

  void _playSound() {
    if (DefaultSoundPlayer.isPaused) {
      DefaultSoundPlayer.resumePlayer();
    } else {
      DefaultSoundPlayer.startPlayer(
        fromURI: soundURI[_randomIndex()]["url"],
        codec: Codec.mp3,
      )
          .then((value) => {
                print(
                    "Playing audio with duration of ${_durationFormatter(value)}")
              })
          .catchError((error, stackTrace) {
        print("error encountered: $error, at stack $stackTrace");
      });
    }
  }

  void _stopSound() {
    DefaultSoundPlayer.stopPlayer();
  }

  void _pauseSound() {
    DefaultSoundPlayer.pausePlayer();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/song.json');
    final data = await json.decode(response);
    setState(() {
      soundURI = data["song"];
});
  }

  @override
  void initState() {
    readJson();
    DefaultSoundPlayer = FlutterSoundPlayer();
    DefaultSoundPlayer.openAudioSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        _playSound();
                      },
                      child: Text("Play")),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _pauseSound();
                    },
                    child: Text("Pause"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        _stopSound();
                      },
                      child: Text("Stop")),
                ),
              ],
            )
          ],
        ));
  }
}
