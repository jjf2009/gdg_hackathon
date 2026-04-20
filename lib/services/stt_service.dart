import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

/// Speech-to-Text service using Android's native STT engine.
/// Supports Hindi (hi-IN), Marathi (mr-IN), Kannada (kn-IN).
/// Push-to-talk with partial + final results.
class SttService {
  static final SttService _instance = SttService._internal();
  factory SttService() => _instance;
  SttService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _currentLocale = 'hi_IN';

  final StreamController<SttResult> _resultController =
      StreamController<SttResult>.broadcast();
  final StreamController<String> _partialController =
      StreamController<String>.broadcast();
  final StreamController<SttState> _stateController =
      StreamController<SttState>.broadcast();

  /// Stream of final recognized results.
  Stream<SttResult> get onResult => _resultController.stream;

  /// Stream of partial (interim) results while user speaks.
  Stream<String> get onPartial => _partialController.stream;

  /// Stream of STT state changes.
  Stream<SttState> get onStateChange => _stateController.stream;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  /// Language code mapping (app language → STT locale).
  static const Map<String, String> _localeMap = {
    'en': 'en_IN',
    'hi': 'hi_IN',
    'mr': 'mr_IN',
    'kn': 'kn_IN',
    'te': 'te_IN',
    'ta': 'ta_IN',
  };

  /// Initialize the STT engine.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: false,
      );

      if (_isInitialized) {
        _stateController.add(SttState.ready);
      } else {
        _stateController.add(SttState.error);
      }

      return _isInitialized;
    } catch (e) {
      print('STT init error: $e');
      _stateController.add(SttState.error);
      return false;
    }
  }

  /// Set the recognition language.
  void setLanguage(String langCode) {
    _currentLocale = _localeMap[langCode] ?? 'hi_IN';
  }

  /// Start listening (push-to-talk).
  Future<bool> startListening({String? langCode}) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return false;
    }

    if (_isListening) return true;

    if (langCode != null) {
      setLanguage(langCode);
    }

    try {
      await _speech.listen(
        onResult: _onResult,
        localeId: _currentLocale,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          cancelOnError: false,
          partialResults: true,
        ),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );

      _isListening = true;
      _stateController.add(SttState.listening);
      return true;
    } catch (e) {
      print('STT start error: $e');
      _stateController.add(SttState.error);
      return false;
    }
  }

  /// Stop listening.
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      _isListening = false;
      _stateController.add(SttState.ready);
    } catch (e) {
      print('STT stop error: $e');
    }
  }

  /// Cancel listening without processing.
  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
      _isListening = false;
      _stateController.add(SttState.ready);
    } catch (e) {
      print('STT cancel error: $e');
    }
  }

  /// Get available locales/languages on device.
  Future<List<String>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();
    try {
      final locales = await _speech.locales();
      return locales.map((l) => '${l.localeId}: ${l.name}').toList();
    } catch (_) {
      return [];
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      _isListening = false;
      _resultController.add(SttResult(
        text: result.recognizedWords,
        isFinal: true,
        confidence: result.confidence,
      ));
      _stateController.add(SttState.ready);
    } else {
      _partialController.add(result.recognizedWords);
    }
  }

  void _onError(SpeechRecognitionError error) {
    print('STT error: ${error.errorMsg} (${error.permanent})');
    _isListening = false;

    if (error.errorMsg == 'error_permission') {
      _stateController.add(SttState.noPermission);
    } else {
      _stateController.add(SttState.error);
    }
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }

  void dispose() {
    stopListening();
    _resultController.close();
    _partialController.close();
    _stateController.close();
  }
}

/// Result from STT recognition.
class SttResult {
  final String text;
  final bool isFinal;
  final double confidence;

  SttResult({
    required this.text,
    this.isFinal = false,
    this.confidence = 1.0,
  });

  @override
  String toString() => 'SttResult(text: $text, final: $isFinal, conf: ${confidence.toStringAsFixed(2)})';
}

/// STT service state.
enum SttState {
  uninitialized,
  ready,
  listening,
  processing,
  error,
  noPermission,
}
