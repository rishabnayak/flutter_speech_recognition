package com.flutter.speech_recognition;

import android.content.Context;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

interface SpeechRecognitionAgent {

    void init(Context context, PluginRegistry.Registrar registrar, final MethodChannel.Result result);

    void isLangAvailable(Context context, String languageCode, final MethodChannel.Result result);

    void getAvailableLanguages(Context context, final MethodChannel.Result result);

    void setLanguage(Context context, String languageCode, final MethodChannel.Result result);

    void start(Context context,final EventChannel.EventSink eventSink);

    void stop(Context context);

}

interface OnLanguageDetailsListener
{
    void onLanguageDetailsReceived(LanguageDetailsChecker data);
}
