package com.flutter.speech_recognition;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.speech.RecognizerIntent;

import java.util.ArrayList;
import java.util.List;

public class LanguageDetailsChecker extends BroadcastReceiver
{

    private List<String> supportedLanguages;


    private OnLanguageDetailsListener doAfterReceive;

    public LanguageDetailsChecker(OnLanguageDetailsListener doAfterReceive)
    {
        supportedLanguages = new ArrayList<>();
        this.doAfterReceive = doAfterReceive;
    }

    @Override
    public void onReceive(Context context, Intent intent)
    {
        Bundle results = getResultExtras(true);
        if (results.containsKey(RecognizerIntent.EXTRA_SUPPORTED_LANGUAGES))
        {
            supportedLanguages =
                    results.getStringArrayList(
                            RecognizerIntent.EXTRA_SUPPORTED_LANGUAGES);
        }

        if (doAfterReceive != null)
        {
            doAfterReceive.onLanguageDetailsReceived(this);
        }
    }

    public List<String> getSupportedLanguages()
    {
        return supportedLanguages;
    }
}
