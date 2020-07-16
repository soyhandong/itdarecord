
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_sound_demo/demo_util/temp_file.dart';
import 'package:permission_handler/permission_handler.dart';

import 'demo_active_codec.dart';
import 'recorder_state.dart';

///
class MainBody extends StatefulWidget {
  ///
  const MainBody({
    Key key,
  }) : super(key: key);

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  bool initialized = false;

  String recordingFile;
  Track track;

  @override
  void initState() {
    Future<PermissionStatus> status =  Permission.microphone.request();
    status.then((stat) {
      if (stat != PermissionStatus.granted) {
        throw RecordingPermissionException("Microphone permission not granted");
      }
    });

    super.initState();
     tempFile(suffix: '.aac').then( (path){
       recordingFile = path;
       track = Track(trackPath: recordingFile);
       setState(() {
       });
     });


  }

  Future<bool> init()  async {
    if (!initialized) {
      initializeDateFormatting();
      await UtilRecorder().init();
      ActiveCodec().recorderModule = UtilRecorder().recorderModule;
      ActiveCodec().setCodec(withUI: false, codec: Codec.aacADTS);

      initialized = true;
    }
    return initialized;
  }

  void dispose() {
    if (recordingFile != null) {
      File(recordingFile).delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        initialData: false,
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return Container(
              width: 0,
              height: 0,
              color: Colors.white,
            );
          } else {
            return ListView(
              children: <Widget>[
                _buildRecorder(track),
              ],
            );
          }
        });
  }


  Widget _buildRecorder(Track track) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: RecorderPlaybackController(
            child: Column(
          children: [
            Left("Recorder"),
            SoundRecorderUI(track),
            Left("Recording Playback"),
            SoundPlayerUI.fromTrack(
              track,
              enabled: false,
              showTitle: true,
              audioFocus: true
                  ? AudioFocus.requestFocusAndDuckOthers
                  : AudioFocus.requestFocusAndDuckOthers,
            ),
          ],
        )));
  }

}

///
class Left extends StatelessWidget {
  ///
  final String label;

  ///
  Left(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4, left: 8),
      child: Container(
          alignment: Alignment.centerLeft,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
