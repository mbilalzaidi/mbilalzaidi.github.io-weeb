import 'package:flutter/material.dart';
import 'ollama_service.dart';

/// Complete Chat Screen Example for Flutter
/// 
/// This is a fully functional chat interface that connects to your
/// Ollama server running on your VPS.
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OllamaService _ollamaService = OllamaService();
  
  final List<ChatMessage> _messages = [];
  String _selectedModel = 'llama2';
  List<OllamaModel> _availableModels = [];
  bool _isLoading = false;
  bool _serviceAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkService();
    _loadModels();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkService() async {
    final isAvailable = await _ollamaService.healthCheck();
    setState(() {
      _serviceAvailable = isAvailable;
    });
    
    if (!isAvailable) {
      _showError('Cannot connect to Ollama service. Please check your server.');
    }
  }

  Future<void> _loadModels() async {
    try {
      final models = await _ollamaService.listModels();
      setState(() {
        _availableModels = models;
        if (models.isNotEmpty) {
          _selectedModel = models.first.name;
        }
      });
    } catch (e) {
      debugPrint('Error loading models: $e');
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    final message = ChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _isLoading = true;
    });
    
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _ollamaService.generateResponse(
        userMessage,
        _selectedModel,
      );
      
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ollama Chat'),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Model selector
          if (_availableModels.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.model_training),
              onSelected: (value) {
                setState(() {
                  _selectedModel = value;
                });
              },
              itemBuilder: (context) => _availableModels.map((model) {
                return PopupMenuItem<String>(
                  value: model.name,
                  child: Row(
                    children: [
                      Icon(
                        _selectedModel == model.name
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              model.formattedSize,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
          // Refresh connection button
          IconButton(
            icon: Icon(
              Icons.wifi,
              color: _serviceAvailable ? Colors.white : Colors.red,
            ),
            onPressed: _checkService,
            tooltip: 'Check connection',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          if (!_serviceAvailable)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Not connected to Ollama service',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _checkService,
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ask me anything!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Thinking...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          
          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading && _serviceAvailable,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _isLoading || !_serviceAvailable
                        ? null
                        : _sendMessage,
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual message bubble widget
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isError
              ? Colors.red[100]
              : message.isUser
                  ? Colors.blue[100]
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isError ? Colors.red[900] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

/// Example main.dart usage:
/// 
/// ```dart
/// void main() {
///   runApp(const MyApp());
/// }
/// 
/// class MyApp extends StatelessWidget {
///   const MyApp({Key? key}) : super(key: key);
/// 
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       title: 'Ollama Chat',
///       theme: ThemeData(
///         primarySwatch: Colors.deepPurple,
///       ),
///       home: const ChatScreen(),
///     );
///   }
/// }
/// ```
