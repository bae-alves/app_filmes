
import '../../data/api_models/movie.dart';

enum ChatMessageRole {
  user,
  assistant,
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.role,
    this.movies = const [],
  });

  final String text;
  final ChatMessageRole role;
  final List<Movie> movies;

  bool get isUser => role == ChatMessageRole.user;
}
