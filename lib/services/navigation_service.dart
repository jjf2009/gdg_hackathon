import 'dart:convert';
import 'package:flutter/services.dart';
import 'intent_service.dart';
import 'tts_service.dart';
import 'scan_history_service.dart';

/// Central navigation service that maps voice intents → app actions.
/// Decoupled from UI — receives callbacks for tab switching and actions.
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final TtsService _tts = TtsService();

  /// Callback to switch tabs in the app shell.
  void Function(int tabIndex)? onTabSwitch;

  /// Current app language.
  String _currentLang = 'hi';

  /// Last executed intent for "repeat" command.
  VoiceIntent? _lastIntent;

  /// Cached voice action strings per language.
  final Map<String, Map<String, String>> _voiceStrings = {};

  void setLanguage(String lang) {
    _currentLang = lang;
  }

  /// Load voice-specific strings from locale JSON files.
  Future<void> loadVoiceStrings() async {
    for (final lang in ['hi', 'mr', 'kn']) {
      try {
        final jsonStr = await rootBundle.loadString('assets/lang/$lang.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        _voiceStrings[lang] = {};
        data.forEach((key, value) {
          if (value is String) {
            _voiceStrings[lang]![key] = value;
          }
        });
      } catch (e) {
        print('Failed to load voice strings for $lang: $e');
      }
    }
  }

  /// Get a voice string in the current language.
  String _getVoiceString(String key) {
    return _voiceStrings[_currentLang]?[key] ??
        _voiceStrings['hi']?[key] ??
        key;
  }

  /// Execute a voice intent — navigate and provide TTS feedback.
  Future<String> executeIntent(VoiceIntent intent) async {
    if (intent.isUnknown) {
      final msg = _getVoiceString('voice_action_unknown');
      await _tts.speakInLanguage(msg, _currentLang);
      return msg;
    }

    // Handle repeat command
    if (intent.name == 'repeat') {
      if (_lastIntent != null) {
        return executeIntent(_lastIntent!);
      }
      final msg = _getVoiceString('voice_action_unknown');
      await _tts.speakInLanguage(msg, _currentLang);
      return msg;
    }

    _lastIntent = intent;

    // Handle navigation intents
    if (intent.isNavigation && intent.tabIndex != null) {
      onTabSwitch?.call(intent.tabIndex!);

      final actionKey = _getActionKey(intent.name);
      String msg = _getVoiceString(actionKey);

      // Add contextual summary based on current app state!
      final prediction = ScanHistoryService.instance.lastPrediction;
      if (prediction != null) {
        final isHealthy = prediction.isHealthy;
        if (intent.name == 'navigate_treatment') {
          if (isHealthy) {
            msg = _currentLang == 'hi'
                ? '${prediction.cropName} स्वस्थ है। कोई इलाज की जरूरत नहीं है।'
                : _currentLang == 'mr'
                    ? '${prediction.cropName} निरोगी आहे. कोणत्याही उपचाराची गरज नाही.'
                    : _currentLang == 'kn'
                        ? '${prediction.cropName} ಆರೋಗ್ಯಕರವಾಗಿದೆ. ಯಾವುದೇ ಚಿಕಿತ್ಸೆ ಅಗತ್ಯವಿಲ್ಲ.'
                        : 'Your ${prediction.cropName} is healthy. No treatment needed.';
          } else {
            msg = _currentLang == 'hi'
                ? 'इलाज टैब खुल गया है। आपके ${prediction.cropName} के ${prediction.diseaseName} का इलाज यहाँ है। क्या मैं इसे पढ़कर सुनाऊँ?'
                : _currentLang == 'mr'
                    ? 'उपचार टॅब उघडला. तुमच्या ${prediction.cropName} च्या ${prediction.diseaseName} साठी उपचार माहिती येथे आहे. मी वाचून दाखवू का?'
                    : _currentLang == 'kn'
                        ? 'ಚಿಕಿತ್ಸೆ ಟ್ಯಾಬ್ ತೆರೆಯಲಾಗಿದೆ. ನಿಮ್ಮ ${prediction.cropName} ನ ${prediction.diseaseName} ಚಿಕಿತ್ಸೆ ಇಲ್ಲಿದೆ. ನಾನು ಓದಬೇಕೇ?'
                        : 'Treatment tab opened. Treatment for ${prediction.diseaseName} on ${prediction.cropName} is shown here. Should I read it?';
          }
        } else if (intent.name == 'navigate_result') {
          if (isHealthy) {
            msg = _currentLang == 'hi'
                ? 'नतीजा: आपका ${prediction.cropName} पौधे स्वस्थ है।'
                : _currentLang == 'mr'
                    ? 'निकाल: तुमचे ${prediction.cropName} निरोगी आहे.'
                    : _currentLang == 'kn'
                        ? 'ಫಲಿತಾಂಶ: ನಿಮ್ಮ ${prediction.cropName} ಆರೋಗ್ಯಕರವಾಗಿದೆ.'
                        : 'Result: your ${prediction.cropName} is healthy.';
          } else {
            final conf = (prediction.confidence * 100).toInt();
            msg = _currentLang == 'hi'
                ? 'नतीजा। ${prediction.cropName} पर ${prediction.diseaseName} मिला है जिसकी संभावना $conf% है।'
                : _currentLang == 'mr'
                    ? 'निकाल. ${prediction.cropName} वर ${prediction.diseaseName} आढळले आहे, ज्याची शक्यता $conf% आहे.'
                    : _currentLang == 'kn'
                        ? 'ಫಲಿತಾಂಶ. ${prediction.cropName} ಮೇಲೆ ${prediction.diseaseName} ಕಂಡುಬಂದಿದೆ ($conf% ಖಚಿತತೆ).'
                        : 'Result tab. ${prediction.diseaseName} detected on ${prediction.cropName} with $conf% confidence.';
          }
        }
      }

      await _tts.speakInLanguage(msg, _currentLang);
      return msg;
    }

    // Handle go_back
    if (intent.name == 'go_back') {
      // Navigate to scan (home) tab
      onTabSwitch?.call(0);
      final msg = _getVoiceString('voice_action_scan');
      await _tts.speakInLanguage(msg, _currentLang);
      return msg;
    }

    final msg = _getVoiceString('voice_action_unknown');
    await _tts.speakInLanguage(msg, _currentLang);
    return msg;
  }

  /// Map intent name to voice action string key.
  String _getActionKey(String intentName) {
    switch (intentName) {
      case 'navigate_scan':
        return 'voice_action_scan';
      case 'navigate_result':
        return 'voice_action_result';
      case 'navigate_treatment':
        return 'voice_action_treatment';
      case 'navigate_history':
        return 'voice_action_history';
      case 'navigate_community':
        return 'voice_action_community';
      default:
        return 'voice_action_unknown';
    }
  }
}
