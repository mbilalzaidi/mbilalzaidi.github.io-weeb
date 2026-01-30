import 'dart:convert';
import 'package:http/http.dart' as http;

/// Ollama API Service for Flutter
/// 
/// This service handles communication with the Ollama API
/// running on your VPS server.
class OllamaService {
  // Replace with your actual domain
  final String baseUrl = 'https://learnwithus.cloud/api';
  
  // Timeout for API requests (2 minutes for long-running AI tasks)
  final Duration timeout = const Duration(seconds: 120);

  /// Generate a response from the AI model
  /// 
  /// [prompt] - The user's question or input
  /// [model] - The model to use (e.g., 'llama2', 'mistral', 'codellama')
  /// [stream] - Whether to stream the response (not implemented in this example)
  Future<String> generateResponse(
    String prompt,
    String model, {
    bool stream = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/generate'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'prompt': prompt,
              'stream': stream,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response generated';
      } else {
        throw Exception(
          'Failed to generate response: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to Ollama: $e');
    }
  }

  /// Get a list of available models on the server
  Future<List<OllamaModel>> listModels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tags'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = (data['models'] as List?)
            ?.map((model) => OllamaModel.fromJson(model))
            .toList();
        return models ?? [];
      } else {
        throw Exception('Failed to list models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error listing models: $e');
    }
  }

  /// Check if the Ollama service is running
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tags'),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Generate with context (for chat-like interactions)
  /// 
  /// [messages] - List of previous messages for context
  /// [model] - The model to use
  Future<String> generateWithContext(
    List<Map<String, String>> messages,
    String model,
  ) async {
    // Build context from messages
    final contextPrompt = messages
        .map((msg) => '${msg['role']}: ${msg['content']}')
        .join('\n');
    
    return generateResponse(contextPrompt, model);
  }
}

/// Model class representing an Ollama model
class OllamaModel {
  final String name;
  final String? size;
  final DateTime? modifiedAt;

  OllamaModel({
    required this.name,
    this.size,
    this.modifiedAt,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return OllamaModel(
      name: json['name'] as String,
      size: json['size']?.toString(),
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'])
          : null,
    );
  }

  String get displayName {
    // Format model name for display (e.g., "llama2:latest" -> "Llama 2")
    return name.split(':').first.replaceAllMapped(
          RegExp(r'([a-z])([0-9])'),
          (match) => '${match[1]} ${match[2]}',
        );
  }

  String get formattedSize {
    if (size == null) return 'Unknown size';
    
    // Convert size to human-readable format
    final bytes = int.tryParse(size!) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Example usage in a Flutter widget:
/// 
/// ```dart
/// final ollamaService = OllamaService();
/// 
/// // Check if service is available
/// bool isAvailable = await ollamaService.healthCheck();
/// 
/// // List available models
/// List<OllamaModel> models = await ollamaService.listModels();
/// 
/// // Generate a response
/// String response = await ollamaService.generateResponse(
///   'What is the capital of France?',
///   'llama2',
/// );
/// ```
