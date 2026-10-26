
import 'package:flutter/foundation.dart';

import '../../data/services/gemini_service.dart';
import 'chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    required GeminiService geminiService,
  }) : _geminiService = geminiService;

  final GeminiService _geminiService;

  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> sendMessage(String message) async {
    final text = message.trim();

    if (text.isEmpty || _isLoading) return;

    _messages.add(
      ChatMessage(
        text: text,
        role: ChatMessageRole.user,
      ),
    );

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _geminiService.interpretPreferences(text);

      final explanation = result['explanation'] as String? ??
          'Vamos encontrar filmes para você!';

      _messages.add(
        ChatMessage(
          text: explanation,
          role: ChatMessageRole.assistant,
        ),
      );
    } catch (error) {
      _errorMessage =
          'Não consegui consultar a IA. Verifique sua conexão e tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
