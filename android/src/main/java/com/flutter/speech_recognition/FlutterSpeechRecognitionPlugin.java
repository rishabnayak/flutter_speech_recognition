package com.flutter.speech_recognition;

import android.content.Context;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterSpeechRecognitionPlugin */
public class FlutterSpeechRecognitionPlugin implements MethodCallHandler, EventChannel.StreamHandler {

  private static Context context;
  private static Registrar flutterRegistrar;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_speech_recognition");
    final EventChannel textChannel = new EventChannel(registrar.messenger(), "textChannel");
    channel.setMethodCallHandler(new FlutterSpeechRecognitionPlugin());
    textChannel.setStreamHandler(new FlutterSpeechRecognitionPlugin());
    flutterRegistrar = registrar;
    context = registrar.activeContext();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String languageCode = call.argument("languageCode");
    switch (call.method){
      case "SpeechRecognition#Init":
        FlutterSpeechRecognition.instance.init(context, flutterRegistrar, result);
        break;
      case "SpeechRecognition#IsLangAvailable":
        FlutterSpeechRecognition.instance.isLangAvailable(context, languageCode, result);
        break;
      case "SpeechRecognition#GetAvailableLanguages":
        FlutterSpeechRecognition.instance.getAvailableLanguages(context, result);
        break;
      case "SpeechRecognition#SetLanguage":
        FlutterSpeechRecognition.instance.setLanguage(context, languageCode, result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    FlutterSpeechRecognition.instance.start(context, eventSink);
  }

  @Override
  public void onCancel(Object o) {
    FlutterSpeechRecognition.instance.stop(context);
  }
}
