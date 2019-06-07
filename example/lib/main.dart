import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_speech_recognition/flutter_speech_recognition.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    VoiceController controller =
        FlutterSpeechRecognition.instance.voiceController();
    controller.init().then((_) {
      controller.getAvailableLanguages().then((onValue) {
        print(onValue);
      });
      controller.recognize().listen((onData) {
        print(onData);
      }, onDone: () {
        print("Done");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
      ),
    );
  }
}
