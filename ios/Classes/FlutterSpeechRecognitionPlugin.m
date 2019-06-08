#import "FlutterSpeechRecognitionPlugin.h"

@import Speech;
@import AVFoundation;

@implementation FlutterSpeechRecognitionPlugin

SFSpeechRecognizer *speechRecognizer;
AVAudioEngine *audioEngine;
AVAudioSession *audioSession;
NSSet<NSLocale *> *locales;
NSMutableArray<NSString *> *languageSet;
SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
SFSpeechRecognitionTask *recognitionTask;
AVAudioInputNode *inputNode;
NSTimer *timer;
FlutterEventSink recognitionResult;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_speech_recognition"
                                     binaryMessenger:[registrar messenger]];
    FlutterEventChannel *textChannel = [FlutterEventChannel eventChannelWithName:@"textChannel" binaryMessenger:[registrar messenger]];
    FlutterSpeechRecognitionPlugin* instance = [[FlutterSpeechRecognitionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [textChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *languageCode = call.arguments[@"languageCode"];
    if ([@"SpeechRecognition#Init" isEqualToString:call.method]){
        [FlutterSpeechRecognitionPlugin init: result];
    } else if ([@"SpeechRecognition#IsLangAvailable" isEqualToString:call.method]){
        [FlutterSpeechRecognitionPlugin isLangAvailable: languageCode result:result];
    } else if ([@"SpeechRecognition#GetAvailableLanguages" isEqualToString:call.method]){
        [FlutterSpeechRecognitionPlugin getAvailableLanguages: result];
    } else if ([@"SpeechRecognition#SetLanguage" isEqualToString:call.method]){
        [FlutterSpeechRecognitionPlugin setLanguage: languageCode result: result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

+ (void)init:(FlutterResult)result{
    NSError *error;
    audioEngine = [[AVAudioEngine alloc] init];
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:&error];
    if([SFSpeechRecognizer authorizationStatus] == !SFSpeechRecognizerAuthorizationStatusAuthorized){
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status){
            switch (status) {
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    speechRecognizer = [[SFSpeechRecognizer alloc] init];
                    locales = SFSpeechRecognizer.supportedLocales;
                    languageSet = [NSMutableArray new];
                    for(NSLocale *locale in locales){
                        NSString *localeName = [locale localeIdentifier];
                        [languageSet addObject: localeName];
                    }
                    result(@(YES));
                    break;
                case SFSpeechRecognizerAuthorizationStatusDenied:
                    result(@(NO));
                    break;
                case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    result(@(NO));
                    break;
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                    result(@(NO));
                    break;
                default:
                    break;
            }
        }];
    }
    else{
        speechRecognizer = [[SFSpeechRecognizer alloc] init];
        locales = SFSpeechRecognizer.supportedLocales;
        languageSet = [NSMutableArray new];
        for(NSLocale *locale in locales){
            NSString *localeName = [locale localeIdentifier];
            [languageSet addObject: localeName];
        }
        result(@(YES));
    }
}

+ (void)isLangAvailable:(NSString *)languageCode result:(FlutterResult)result{
    if([languageSet containsObject:languageCode]){
        result(@(YES));
    }
    result(@(NO));
}

+ (void)getAvailableLanguages:(FlutterResult)result{
    result(languageSet);
}

+ (void)setLanguage:(NSString *)languageCode result:(FlutterResult)result{
    if([languageSet containsObject:languageCode]){
        speechRecognizer = nil;
        speechRecognizer = [speechRecognizer initWithLocale:[NSLocale localeWithLocaleIdentifier:languageCode]];
        result(@(YES));
    }
    result(@(NO));
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    
    if (recognitionTask) {
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    
    recognitionResult = eventSink;
    NSError *error;
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    inputNode = audioEngine.inputNode;
    recognitionRequest.shouldReportPartialResults = YES;
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerCalled) userInfo:nil repeats:NO];
        if (result) {
            timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerCalled) userInfo:nil repeats:NO];
            recognitionResult(result.bestTranscription.formattedString);
            isFinal = result.isFinal;
        }
        if (error != nil || isFinal) {
            recognitionResult(FlutterEndOfEventStream);
            [audioEngine stop];
            [inputNode removeTapOnBus:0];
            recognitionRequest = nil;
            recognitionTask = nil;
        }
    }];
    
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [audioEngine prepare];
    [audioEngine startAndReturnError:&error];
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
    if(audioEngine.isRunning){
        recognitionResult(FlutterEndOfEventStream);
        [audioEngine stop];
        [inputNode removeTapOnBus:0];
        [recognitionRequest endAudio];
        recognitionRequest = nil;
        recognitionTask = nil;
        return nil;
    }
    return nil;
}

- (void)timerCalled
{
    recognitionResult(FlutterEndOfEventStream);
    [audioEngine stop];
    [inputNode removeTapOnBus:0];
    recognitionRequest = nil;
    recognitionTask = nil;
}

@end
