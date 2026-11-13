import 'package:flutter/material.dart';

import '../../data/api_models/movie.dart';
import '../../l10n/app_localizations.dart';
import '../view_model/chat_message.dart';
import '../view_model/chat_view_model.dart';
import '../view_model/favorites_view_model.dart';
import 'home_page.dart';
import 'movie_details_page.dart';
import 'widgets/movie_ai_logo.dart';
import 'widgets/movie_card.dart';
import 'widgets/trailer_player.dart';

/// Tela do assistente MovieAI (chat): permite pedir sugestões personalizadas
/// de filmes e visualizar os resultados.
class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.viewModel,
    this.favoritesViewModel,
    this.detailsViewModelFactory,
    this.ratingViewModelFactory,
    this.trailerPlayerBuilder = defaultTrailerPlayerBuilder,
  });

  /// Estado e comandos do chat.
  final ChatViewModel viewModel;

  /// Lista de favoritos, repassada ao abrir a tela de detalhes.
  final FavoritesViewModel? favoritesViewModel;

  /// Fábrica da view model usada ao abrir a tela de detalhes.
  final MovieDetailsViewModelFactory? detailsViewModelFactory;

  /// Fábrica da view model da avaliação, usada ao abrir os detalhes.
  final MovieRatingViewModelFactory? ratingViewModelFactory;

  /// Repassado para a tela de detalhes. Veja [TrailerPlayerBuilder].
  final TrailerPlayerBuilder trailerPlayerBuilder;

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

  void _openDetails(Movie movie) {
    final detailsFactory = widget.detailsViewModelFactory;
    final ratingFactory = widget.ratingViewModelFactory;
    final favoritesVm = widget.favoritesViewModel;

    if (detailsFactory == null ||
        ratingFactory == null ||
        favoritesVm == null) {
      return;
    }

    Navigator.of(context).push(
      MovieDetailsPage.route(
        viewModel: detailsFactory(movie.id),
        ratingViewModel: ratingFactory(movie.id),
        favoritesViewModel: favoritesVm,
        fallbackTitle: movie.title,
        trailerPlayerBuilder: widget.trailerPlayerBuilder,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const Center(child: MovieAiLogo()),
        title: const Text('MovieAI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                final messages = widget.viewModel.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 48,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.chatEmptyTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.chatEmptyBody,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
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
                              onTap: () => _openDetails(movie),
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
                                hintText: l10n.chatInputHint,
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
                            tooltip: l10n.chatSendTooltip,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
