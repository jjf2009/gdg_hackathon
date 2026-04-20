import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service using Android TTS engine.
/// Supports Hindi, Marathi, and Kannada with dynamic language switching.
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLang = 'hi-IN';

  final StreamController<TtsState> _stateController =
      StreamController<TtsState>.broadcast();

  Stream<TtsState> get onStateChange => _stateController.stream;
  bool get isSpeaking => _isSpeaking;

  /// Language code to TTS locale mapping.
  static const Map<String, String> _langMap = {
    'en': 'en-IN',
    'hi': 'hi-IN',
    'mr': 'mr-IN',
    'kn': 'kn-IN',
    'te': 'te-IN',
    'ta': 'ta-IN',
  };

  /// Initialize TTS engine.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      await _tts.setEngine('com.google.android.tts');

      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
        _stateController.add(TtsState.speaking);
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        _stateController.add(TtsState.idle);
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        _stateController.add(TtsState.error);
        print('TTS error: $msg');
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
        _stateController.add(TtsState.idle);
      });

      _isInitialized = true;
      return true;
    } catch (e) {
      print('TTS init error: $e');
      return false;
    }
  }

  /// Set TTS language by app language code (e.g., 'hi', 'mr', 'kn').
  Future<bool> setLanguage(String langCode) async {
    final locale = _langMap[langCode] ?? 'hi-IN';

    try {
      final result = await _tts.setLanguage(locale);
      if (result == 1) {
        _currentLang = locale;
        return true;
      }
      // Fallback: try just the language part
      final fallback = locale.split('-').first;
      final fallbackResult = await _tts.setLanguage(fallback);
      if (fallbackResult == 1) {
        _currentLang = fallback;
        return true;
      }
      return false;
    } catch (e) {
      print('TTS setLanguage error: $e');
      return false;
    }
  }

  /// Check if a language is available.
  Future<bool> isLanguageAvailable(String langCode) async {
    final locale = _langMap[langCode] ?? langCode;
    try {
      final result = await _tts.isLanguageAvailable(locale);
      return result == 1;
    } catch (_) {
      return false;
    }
  }

  /// Speak the given text in the current language.
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    if (text.isEmpty) return;

    // Stop any ongoing speech
    if (_isSpeaking) {
      await stop();
    }

    await _tts.speak(text);
  }

  /// Speak text in a specific language.
  Future<void> speakInLanguage(String text, String langCode) async {
    await setLanguage(langCode);
    await speak(text);
  }

  /// Stop speaking.
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    _stateController.add(TtsState.idle);
  }

  /// Get available languages.
  Future<List<String>> getAvailableLanguages() async {
    try {
      final langs = await _tts.getLanguages;
      if (langs is List) {
        return langs.map((e) => e.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  void dispose() {
    stop();
    _stateController.close();
    _tts.stop();
  }
}

enum TtsState {
  idle,
  speaking,
  error,
}
