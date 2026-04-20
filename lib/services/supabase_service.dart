import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      print('Supabase credentials missing in .env');
      return;
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
    _isInitialized = true;
  }

  /// Perform RAG search for crop disease context
  Future<List<Map<String, dynamic>>> searchContext(String query) async {
    if (!_isInitialized) {
      print('Supabase not initialized');
      return [];
    }

    try {
      print('Generating embedding for query: $query');
      // 1. Generate embedding for the query
      final embedding = await _generateEmbedding(query);
      if (embedding == null) {
        print('Failed to generate embedding');
        return [];
      }

      print('Calling Supabase RPC match_crop_knowledge');
      // 2. Call the match_crop_knowledge function in Supabase
      final response = await _client.rpc(
        'match_crop_knowledge',
        params: {
          'query_embedding': embedding,
          'match_threshold': 0.3, // Lowered threshold slightly to be more inclusive
          'match_count': 3,
        },
      );

      print('Supabase search context success: ${response.length} matches found');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching Supabase context: $e');
      return [];
    }
  }

  /// Generate embedding using HuggingFace Inference API (Free tier)
  Future<List<double>?> _generateEmbedding(String text) async {
    final hfToken = dotenv.env['HUGGINGFACE_TOKEN'];
    if (hfToken == null || hfToken.isEmpty) {
      print('HuggingFace token missing in .env');
      return null;
    }

    const modelId = 'sentence-transformers/all-MiniLM-L6-v2';
    final url = Uri.parse('https://api-inference.huggingface.co/pipeline/feature-extraction/$modelId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $hfToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'inputs': text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> result = json.decode(response.body);
        return result.map((e) => (e as num).toDouble()).toList();
      } else {
        print('HF API error (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating embedding: $e');
      return null;
    }
  }

  /// Save a user report to Supabase for community feed
  Future<void> saveReport(Map<String, dynamic> reportData) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Please check your .env configuration.');
    }

    try {
      print('Saving report to Supabase...');
      // Also generate embedding for the report itself so it can be searched later
      final textToEmbed = '${reportData['crop_name']} ${reportData['suspected_disease']} ${reportData['symptom_description']}';
      final embedding = await _generateEmbedding(textToEmbed);

      if (embedding == null) {
        print('Warning: Could not generate embedding for report. Saving without it.');
      }

      final dataToInsert = {
        ...reportData,
      };
      
      if (embedding != null) {
        dataToInsert['embedding'] = embedding;
      }

      await _client.from('community_reports').insert(dataToInsert);
      print('Report saved successfully to Supabase');
    } catch (e) {
      print('Error saving report to Supabase: $e');
      rethrow;
    }
  }
}
