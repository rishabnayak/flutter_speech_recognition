part of speech_recognition;

class FlutterSpeechRecognition {
  static const MethodChannel _channel =
      const MethodChannel('flutter_speech_recognition');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
