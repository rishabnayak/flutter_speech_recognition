part of speech_recognition;

class VoiceController {
  VoiceController._();

  bool _isInitialized = false;
  Stream<String> textChannelSubscription;

  Future<bool> init() async {
    _isInitialized = await FlutterSpeechRecognition.channel
        .invokeMethod("SpeechRecognition#Init");
    return _isInitialized;
  }

  Future<bool> isLangAvailable(String languageCode) async {
    if (!_isInitialized) {
      throw new Exception(
          "isLangAvailable called on an uninitialized VoiceController");
    }
    final bool _isAvailable = await FlutterSpeechRecognition.channel
        .invokeMethod("SpeechRecognition#IsLangAvailable", <String, dynamic>{
      "languageCode": languageCode,
    });
    return _isAvailable;
  }

  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) {
      throw new Exception(
          "getAvailableLanguages called on an uninitialized VoiceController");
    }
    final List<String> languages = <String>[];
    final List<dynamic> _reply = await FlutterSpeechRecognition.channel
        .invokeMethod("SpeechRecognition#GetAvailableLanguages");
    for (dynamic lang in _reply) {
      languages.add(lang);
    }
    return languages;
  }

  Future<bool> setLanguage(String languageCode) async {
    if (!_isInitialized) {
      throw new Exception(
          "setlanguage called on an uninitialized VoiceController");
    }
    final bool _reply = await FlutterSpeechRecognition.channel
        .invokeMethod("SpeechRecognition#SetLanguage", <String, dynamic>{
      "languageCode": languageCode,
    });
    return _reply;
  }

  Stream<String> recognize() {
    if (!_isInitialized) {
      throw new Exception(
          "Recognize called on an uninitialized VoiceController");
    }
    const EventChannel textChannel = EventChannel('textChannel');
    textChannelSubscription = textChannel
        .receiveBroadcastStream()
        .map((dynamic convert) => convert.toString());
    return (textChannelSubscription);
  }

  Future<void> stop() async {
    if (!_isInitialized) {
      throw new Exception("Stop called on an uninitialized VoiceController");
    }
    textChannelSubscription = null;
    _isInitialized = false;
  }
}
