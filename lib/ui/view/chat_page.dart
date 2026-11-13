import 'package:flutter/material.dart';

import '../view_model/chat_message.dart';
import '../view_model/chat_view_model.dart';
import 'widgets/movie_ai_logo.dart';
import 'widgets/movie_card.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.viewModel});

  final ChatViewModel viewModel;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final message = _controller.text.trim();

    if (message.isEmpty || widget.viewModel.isLoading) return;

    _controller.clear();
    widget.viewModel.sendMessage(message);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [MovieAiLogo(), SizedBox(width: 8), Text('MovieAI')],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                final messages = widget.viewModel.messages;

                if (messages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.movie_filter_outlined, size: 64),
                          SizedBox(height: 16),
                          Text(
                            'Qual é o seu clima para hoje?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Conte como você está se sentindo ou '
                            'qual tipo de filme gostaria de assistir.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      messages.length + (widget.viewModel.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= messages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final message = messages[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.text.isNotEmpty)
                          _MessageBubble(message: message),

                        if (message.movies.isNotEmpty)
                          ...message.movies.map(
                            (movie) => MovieCard(
                              movie: movie,
                              onTap: () {
                                // A navegação para os detalhes será conectada depois.
                              },
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              final error = widget.viewModel.errorMessage;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              enabled: !widget.viewModel.isLoading,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: InputDecoration(
                                hintText: 'Descreva seu humor...',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: widget.viewModel.isLoading
                                ? null
                                : _sendMessage,
                            icon: const Icon(Icons.send),
                            tooltip: 'Enviar mensagem',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatMessageRole.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message.text),
      ),
    );
  }
}
