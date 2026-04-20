import 'dart:convert';
import 'package:flutter/services.dart';

/// Offline rule-based intent parser for voice commands.
/// Uses keyword matching and regex patterns in Hindi, Marathi, and Kannada.
class IntentService {
  static final IntentService _instance = IntentService._internal();
  factory IntentService() => _instance;
  IntentService._internal();

  Map<String, dynamic> _hiKeywords = {};
  Map<String, dynamic> _mrKeywords = {};
  Map<String, dynamic> _knKeywords = {};
  bool _isLoaded = false;

  /// Load intent keyword maps from locale JSON files.
  Future<void> loadKeywords() async {
    if (_isLoaded) return;

    try {
      final hiJson = await rootBundle.loadString('assets/lang/hi.json');
      final mrJson = await rootBundle.loadString('assets/lang/mr.json');
      final knJson = await rootBundle.loadString('assets/lang/kn.json');

      final hiData = json.decode(hiJson) as Map<String, dynamic>;
      final mrData = json.decode(mrJson) as Map<String, dynamic>;
      final knData = json.decode(knJson) as Map<String, dynamic>;

      _hiKeywords = (hiData['intent_keywords'] as Map<String, dynamic>?) ?? {};
      _mrKeywords = (mrData['intent_keywords'] as Map<String, dynamic>?) ?? {};
      _knKeywords = (knData['intent_keywords'] as Map<String, dynamic>?) ?? {};

      _isLoaded = true;
    } catch (e) {
      print('Intent keyword load error: $e');
    }
  }

  /// Parse spoken text into a VoiceIntent.
  /// Tries language-specific keywords first, then falls back to all languages.
  Future<VoiceIntent> parseIntent(String text, {String lang = 'hi'}) async {
    if (!_isLoaded) await loadKeywords();

    final normalized = text.toLowerCase().trim();

    // Try English commands first (universal)
    final englishIntent = _matchEnglishCommands(normalized);
    if (englishIntent != null) return englishIntent;

    // Try the selected language keywords
    Map<String, dynamic> primaryKeywords;
    switch (lang) {
      case 'mr':
        primaryKeywords = _mrKeywords;
        break;
      case 'kn':
        primaryKeywords = _knKeywords;
        break;
      case 'hi':
      default:
        primaryKeywords = _hiKeywords;
        break;
    }

    final primaryResult = _matchKeywords(normalized, primaryKeywords);
    if (primaryResult != null) return primaryResult;

    // Fallback: try all language keywords
    for (final keywords in [_hiKeywords, _mrKeywords, _knKeywords]) {
      if (keywords == primaryKeywords) continue;
      final result = _matchKeywords(normalized, keywords);
      if (result != null) return result;
    }

    // No match found
    return VoiceIntent(
      name: 'unknown',
      originalText: text,
      confidence: 0.0,
    );
  }

  /// Match against English commands (for bilingual users).
  VoiceIntent? _matchEnglishCommands(String text) {
    final englishPatterns = <String, List<String>>{
      'navigate_scan': ['scan', 'camera', 'photo', 'capture', 'leaf', 'check'],
      'navigate_result': ['result', 'diagnosis', 'disease', 'detect'],
      'navigate_treatment': ['treatment', 'treat', 'spray', 'medicine', 'cure', 'what to do'],
      'navigate_history': ['history', 'record', 'previous', 'past', 'old'],
      'navigate_community': ['community', 'feed', 'report', 'nearby', 'alert'],
      'go_back': ['back', 'go back', 'return', 'previous'],
      'repeat': ['repeat', 'again', 'say again'],
    };

    return _matchKeywords(text, englishPatterns);
  }

  /// Match normalized text against keyword map. Returns null if no match.
  VoiceIntent? _matchKeywords(String text, Map<String, dynamic> keywordMap) {
    String? bestIntent;
    int bestMatchCount = 0;

    for (final entry in keywordMap.entries) {
      final intentName = entry.key;
      final keywords = (entry.value as List<dynamic>).cast<String>();

      int matchCount = 0;
      for (final keyword in keywords) {
        if (text.contains(keyword.toLowerCase())) {
          matchCount++;
        }
      }

      if (matchCount > bestMatchCount) {
        bestMatchCount = matchCount;
        bestIntent = intentName;
      }
    }

    if (bestIntent != null && bestMatchCount > 0) {
      // Extract potential slots from text
      final slots = _extractSlots(text);

      return VoiceIntent(
        name: bestIntent,
        originalText: text,
        confidence: (bestMatchCount / 3.0).clamp(0.3, 1.0),
        slots: slots,
      );
    }

    return null;
  }

  /// Extract crop/disease slots from text using keyword matching.
  Map<String, String> _extractSlots(String text) {
    final slots = <String, String>{};

    // Crop detection
    final cropKeywords = {
      'tomato': ['टमाटर', 'टोमॅटो', 'ಟೊಮೆಟೋ', 'tomato'],
      'onion': ['प्याज', 'कांदा', 'ಈರುಳ್ಳಿ', 'onion'],
      'soybean': ['सोयाबीन', 'ಸೋಯಾಬೀನ್', 'soybean'],
      'cotton': ['कपास', 'कापूस', 'ಹತ್ತಿ', 'cotton'],
      'wheat': ['गेहूं', 'गहू', 'ಗೋಧಿ', 'wheat'],
      'rice': ['चावल', 'तांदूळ', 'ಅಕ್ಕಿ', 'rice'],
    };

    for (final entry in cropKeywords.entries) {
      for (final kw in entry.value) {
        if (text.contains(kw.toLowerCase())) {
          slots['crop'] = entry.key;
          break;
        }
      }
      if (slots.containsKey('crop')) break;
    }

    // Disease detection
    final diseaseKeywords = {
      'early_blight': ['झुलसा', 'करपा', 'blight', 'डाग', 'spots'],
      'powdery_mildew': ['चूर्णी', 'भुरी', 'mildew', 'पावडर', 'सफ़ेद'],
      'leaf_curl': ['मुड़ना', 'मुडणे', 'curl', 'मुड'],
      'root_rot': ['सड़न', 'कुजणे', 'rot'],
    };

    for (final entry in diseaseKeywords.entries) {
      for (final kw in entry.value) {
        if (text.contains(kw.toLowerCase())) {
          slots['disease'] = entry.key;
          break;
        }
      }
      if (slots.containsKey('disease')) break;
    }

    return slots;
  }
}

/// A parsed voice intent with name, confidence, and optional slots.
class VoiceIntent {
  final String name;
  final String originalText;
  final double confidence;
  final Map<String, String> slots;

  VoiceIntent({
    required this.name,
    required this.originalText,
    this.confidence = 1.0,
    this.slots = const {},
  });

  bool get isUnknown => name == 'unknown';
  bool get isNavigation => name.startsWith('navigate_');

  /// Get the tab index for navigation intents.
  int? get tabIndex {
    switch (name) {
      case 'navigate_scan':
        return 0;
      case 'navigate_result':
        return 1;
      case 'navigate_treatment':
        return 2;
      case 'navigate_community':
        return 3;
      case 'navigate_history':
        return 4;
      default:
        return null;
    }
  }

  @override
  String toString() =>
      'VoiceIntent(name: $name, confidence: ${confidence.toStringAsFixed(2)}, slots: $slots)';
}
