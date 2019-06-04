import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_speech_recognition/flutter_speech_recognition.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_speech_recognition');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterSpeechRecognition.platformVersion, '42');
  });
}
