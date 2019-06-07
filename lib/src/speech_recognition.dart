part of speech_recognition;

class FlutterSpeechRecognition {
  FlutterSpeechRecognition._();

  @visibleForTesting
  static const MethodChannel channel =
      const MethodChannel('flutter_speech_recognition');

  static final FlutterSpeechRecognition instance = FlutterSpeechRecognition._();

  VoiceController voiceController() {
    return VoiceController._();
  }
}
