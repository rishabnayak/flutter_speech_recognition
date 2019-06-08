package com.flutter.speech_recognition;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;

import androidx.core.app.ActivityCompat;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

class FlutterSpeechRecognition implements SpeechRecognitionAgent, RecognitionListener, OnLanguageDetailsListener {

    static final FlutterSpeechRecognition instance = new FlutterSpeechRecognition();

    private FlutterSpeechRecognition() {
    }
    
    private static SpeechRecognizer speechRecognizer;
    private static List<String> supportedLanguages;
    private static Intent intent;
    private static EventChannel.EventSink recognitionData;
    private static FlutterSpeechRecognition flutterSpeechRecognition;
    private static MethodChannel.Result initResult;

    @Override
    public void init(final Context context, PluginRegistry.Registrar registrar, final MethodChannel.Result result) {
        initResult = result;
        if (SpeechRecognizer.isRecognitionAvailable(context)) {
            flutterSpeechRecognition = this;
            if (ActivityCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED){
                speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context);
                try {
                    speechRecognizer.setRecognitionListener(this);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                Intent detailsIntent = RecognizerIntent.getVoiceDetailsIntent(context);
                LanguageDetailsChecker checker = new LanguageDetailsChecker(this);
                context.sendOrderedBroadcast(detailsIntent, null, checker, null,
                        Activity.RESULT_OK, null, null);
                intent = new Intent
                        (RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                        RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
                intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
                intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3);
            }
            else {
                ActivityCompat.requestPermissions(registrar.activity(), new String[]{Manifest.permission.RECORD_AUDIO},1);
                registrar.addRequestPermissionsResultListener(new PluginRegistry.RequestPermissionsResultListener() {
                    @Override
                    public boolean onRequestPermissionsResult(int i, String[] strings, int[] ints) {
                        if (i == 1) {
                            if (ints[0] == PackageManager.PERMISSION_GRANTED){
                                speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context);
                                try {
                                    speechRecognizer.setRecognitionListener(flutterSpeechRecognition);
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                                Intent detailsIntent = RecognizerIntent.getVoiceDetailsIntent(context);
                                LanguageDetailsChecker checker = new LanguageDetailsChecker(flutterSpeechRecognition);
                                context.sendOrderedBroadcast(detailsIntent, null, checker, null,
                                        Activity.RESULT_OK, null, null);
                                intent = new Intent
                                        (RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
                                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                                        RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
                                intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
                                intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3);
                                return true;
                            }
                            else {
                                result.error("Permission not granted", null, false);
                                return false;
                            }
                        }
                        result.error("Permission not granted", null, false);
                        return false;
                    }
                });
            }
        } else {
            result.error("SpeechRecognition isn't supported on this Device", null, false);
        }

    }

    @Override
    public void isLangAvailable(Context context, String languageCode, MethodChannel.Result result) {
        result.success(supportedLanguages.contains(languageCode));
    }

    @Override
    public void getAvailableLanguages(Context context, MethodChannel.Result result) {
        result.success(supportedLanguages);
    }

    @Override
    public void setLanguage(Context context, String languageCode, MethodChannel.Result result) {
        if (supportedLanguages.contains(languageCode)) {
            intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, languageCode);
        }
    }

    @Override
    public void start(Context context, EventChannel.EventSink eventSink) {
        try {
            speechRecognizer.startListening(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
        recognitionData = eventSink;
    }

    @Override
    public void stop(Context context) {
        speechRecognizer.stopListening();
    }

    @Override
    public void onReadyForSpeech(Bundle bundle){

    }

    @Override
    public void onBeginningOfSpeech() {

    }

    @Override
    public void onRmsChanged(float v) {

    }

    @Override
    public void onBufferReceived(byte[] bytes) {

    }

    @Override
    public void onEndOfSpeech() {

    }

    @Override
    public void onError(int i) {
        try {
            speechRecognizer.stopListening();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onResults(Bundle bundle) {
        ArrayList<String> res = bundle.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
        if (res != null) {
            recognitionData.success(res.get(0));
            recognitionData.endOfStream();
        }
    }

    @Override
    public void onPartialResults(Bundle bundle) {
        ArrayList<String> res = bundle.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
        if (res != null) {
            recognitionData.success(res.get(0));
        }
    }

    @Override
    public void onEvent(int i, Bundle bundle) {
        Log.d("SpeechRecognition",  "ErrorCode: "+i);
    }

    @Override
    public void onLanguageDetailsReceived(LanguageDetailsChecker data) {
        supportedLanguages = data.getSupportedLanguages();
        initResult.success(!supportedLanguages.isEmpty());
    }
}
