
enum ChatMessageRole {
  user,
  assistant,
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.role,
  });

  final String text;
  final ChatMessageRole role;

  bool get isUser => role == ChatMessageRole.user;
}
