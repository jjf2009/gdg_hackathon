import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'intent_service.dart';

/// Groq AI integration for enhanced intent understanding.
/// Uses LLaMA/Mixtral via Groq API with tool-calling schema.
/// Falls back to offline IntentService when unavailable.
class GroqService {
  static final GroqService _instance = GroqService._internal();
  factory GroqService() => _instance;
  GroqService._internal();

  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';
  static const Duration _timeout = Duration(seconds: 5);

  String? _apiKey;
  bool _isAvailable = false;
  final IntentService _offlineParser = IntentService();

  bool get isAvailable => _isAvailable;

  /// Initialize with API key from .env
  void initialize() {
    _apiKey = dotenv.env['GROQ_API_1'];
    _isAvailable = _apiKey != null && _apiKey!.isNotEmpty;
    if (!_isAvailable) {
      print('Groq API key not found in .env — using offline intent only');
    }
  }

  /// Check if network is available.
  Future<bool> _hasNetwork() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results is List) {
        return !(results as List).contains(ConnectivityResult.none);
      }
      return results != ConnectivityResult.none;
    } catch (_) {
      return false;
    }
  }

  /// Parse intent using Groq API with tool-calling, falling back to offline.
  Future<VoiceIntent> parseIntent(String text, {String lang = 'hi'}) async {
    // Always prepare offline fallback
    final offlineFuture = _offlineParser.parseIntent(text, lang: lang);

    // Skip API if not configured or no network
    if (!_isAvailable) return offlineFuture;

    final hasNet = await _hasNetwork();
    if (!hasNet) return offlineFuture;

    try {
      final result = await _callGroqApi(text, lang).timeout(_timeout);
      if (result != null) return result;
    } catch (e) {
      print('Groq API error (falling back to offline): $e');
    }

    return offlineFuture;
  }

  /// Call Groq API with tool-calling schema.
  Future<VoiceIntent?> _callGroqApi(String text, String lang) async {
    final systemPrompt = '''You are a voice assistant for a crop disease diagnosis app called CropDoc.
The user speaks in Hindi, Marathi, or Kannada. Parse their voice command and call the appropriate tool.
Current language: $lang

Available pages: scan (camera/photo), result (diagnosis), treatment (spray/medicine), history (past scans), community (nearby reports).

Always call exactly one tool. If you cannot determine the intent, call open_page with name "unknown".''';

    final tools = [
      {
        'type': 'function',
        'function': {
          'name': 'open_page',
          'description': 'Navigate to a page in the app',
          'parameters': {
            'type': 'object',
            'properties': {
              'name': {
                'type': 'string',
                'enum': ['scan', 'result', 'treatment', 'history', 'community', 'unknown'],
                'description': 'Page to navigate to',
              },
            },
            'required': ['name'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'show_recommendation',
          'description': 'Show treatment recommendation for a specific crop and disease',
          'parameters': {
            'type': 'object',
            'properties': {
              'crop': {
                'type': 'string',
                'description': 'Crop name (tomato, onion, wheat, rice, soybean, cotton)',
              },
              'disease': {
                'type': 'string',
                'description': 'Disease name (early_blight, late_blight, powdery_mildew, leaf_curl, root_rot)',
              },
            },
            'required': ['crop'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'repeat_last',
          'description': 'Repeat the last action or response',
          'parameters': {
            'type': 'object',
            'properties': {},
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'go_back',
          'description': 'Go back to the previous page',
          'parameters': {
            'type': 'object',
            'properties': {},
          },
        },
      },
    ];

    final body = json.encode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': text},
      ],
      'tools': tools,
      'tool_choice': 'auto',
      'temperature': 0.1,
      'max_tokens': 256,
    });

    final client = HttpClient();
    client.connectionTimeout = _timeout;
    try {
      final request = await client.postUrl(Uri.parse(_baseUrl));
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.headers.set('Content-Type', 'application/json');
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        print('Groq API status ${response.statusCode}: $responseBody');
        return null;
      }

      return _parseToolCallResponse(responseBody, text);
    } finally {
      client.close();
    }
  }

  /// Parse Groq tool-call response into a VoiceIntent.
  VoiceIntent? _parseToolCallResponse(String responseBody, String originalText) {
    try {
      final data = json.decode(responseBody) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return null;

      final message = choices[0]['message'] as Map<String, dynamic>;
      final toolCalls = message['tool_calls'] as List<dynamic>?;

      if (toolCalls == null || toolCalls.isEmpty) {
        // No tool call — treat as content response
        final content = message['content'] as String? ?? '';
        return VoiceIntent(
          name: 'unknown',
          originalText: originalText,
          confidence: 0.5,
          slots: {'ai_response': content},
        );
      }

      final toolCall = toolCalls[0] as Map<String, dynamic>;
      final functionData = toolCall['function'] as Map<String, dynamic>;
      final functionName = functionData['name'] as String;
      final args = json.decode(functionData['arguments'] as String? ?? '{}')
          as Map<String, dynamic>;

      switch (functionName) {
        case 'open_page':
          final pageName = args['name'] as String? ?? 'unknown';
          final intentName = pageName == 'unknown'
              ? 'unknown'
              : 'navigate_$pageName';
          return VoiceIntent(
            name: intentName,
            originalText: originalText,
            confidence: 0.95,
          );

        case 'show_recommendation':
          final slots = <String, String>{};
          if (args.containsKey('crop')) slots['crop'] = args['crop'] as String;
          if (args.containsKey('disease')) slots['disease'] = args['disease'] as String;
          return VoiceIntent(
            name: 'navigate_treatment',
            originalText: originalText,
            confidence: 0.95,
            slots: slots,
          );

        case 'repeat_last':
          return VoiceIntent(
            name: 'repeat',
            originalText: originalText,
            confidence: 0.95,
          );

        case 'go_back':
          return VoiceIntent(
            name: 'go_back',
            originalText: originalText,
            confidence: 0.95,
          );

        default:
          return null;
      }
    } catch (e) {
      print('Groq response parse error: $e');
      return null;
    }
  }
}
