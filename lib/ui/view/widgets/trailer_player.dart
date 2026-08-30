import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Constrói o widget que reproduz o trailer identificado por [youtubeKey].
///
/// A tela de detalhes recebe uma função em vez de instanciar o player
/// diretamente: assim o teste de widget consegue substituir o player real (que
/// depende de uma WebView e, portanto, de plataforma) por um stub, sem abrir
/// mão de verificar que a chave certa chegou até ele.
typedef TrailerPlayerBuilder = Widget Function(
  BuildContext context,
  String youtubeKey,
);

/// Implementação padrão de [TrailerPlayerBuilder]: o player real do YouTube.
Widget defaultTrailerPlayerBuilder(BuildContext context, String youtubeKey) =>
    TrailerPlayer(youtubeKey: youtubeKey);

/// Reproduz o trailer do filme hospedado no YouTube.
///
/// Encapsula o pacote `youtube_player_flutter` para que o resto da UI dependa
/// apenas deste widget, e não da API de terceiros.
class TrailerPlayer extends StatefulWidget {
  const TrailerPlayer({super.key, required this.youtubeKey});

  /// Identificador do vídeo no YouTube (o valor de `key` no TMDB).
  final String youtubeKey;

  @override
  State<TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<TrailerPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  @override
  void didUpdateWidget(TrailerPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // O player é criado a partir do id do vídeo, então trocar de filme exige
    // um controller novo.
    if (oldWidget.youtubeKey != widget.youtubeKey) {
      _controller.close();
      _controller = _createController();
    }
  }

  YoutubePlayerController _createController() {
    return YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeKey,
      // Sem reprodução automática: o usuário decide quando assistir.
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _controller);
  }
}
