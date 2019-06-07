#import "FlutterSpeechRecognitionPlugin.h"

@implementation FlutterSpeechRecognitionPlugin

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
    
}

+ (void)isLangAvailable:(NSString *)languageCode result:(FlutterResult)result{
  
}

+ (void)getAvailableLanguages:(FlutterResult)result{
    
}

+ (void)setLanguage:(NSString *)languageCode result:(FlutterResult)result{

}

- (FlutterError *)onCancelWithArguments:(id)arguments {
    return nil;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    return nil;
}

@end
