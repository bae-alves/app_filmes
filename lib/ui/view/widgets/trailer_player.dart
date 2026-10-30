import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
/// Encapsula o pacote `youtube_player_iframe` para que o resto da UI dependa
/// apenas deste widget, e não da API de terceiros.
class TrailerPlayer extends StatefulWidget {
  const TrailerPlayer({super.key, required this.youtubeKey});

  /// Identificador do vídeo no YouTube (o valor de `key` no TMDB).
  final String youtubeKey;

  /// Quanto do vídeo o app deixa assistir: a prévia é curta para não
  /// entregar a história.
  static const maxDuration = Duration(minutes: 2);

  @override
  State<TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<TrailerPlayer> {
  late YoutubePlayerController _controller;
  late StreamSubscription<YoutubeVideoState> _durationLimit;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _durationLimit = _limitDuration();
  }

  @override
  void didUpdateWidget(TrailerPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // O player é criado a partir do id do vídeo, então trocar de filme exige
    // um controller novo.
    if (oldWidget.youtubeKey != widget.youtubeKey) {
      _durationLimit.cancel();
      _controller.close();
      _controller = _createController();
      _durationLimit = _limitDuration();
    }
  }

  YoutubePlayerController _createController() {
    return YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeKey,
      // Sem reprodução automática: o usuário decide quando assistir.
      autoPlay: false,
      endSeconds: _maxSeconds,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  static final _maxSeconds = TrailerPlayer.maxDuration.inSeconds.toDouble();

  /// O `endSeconds` do YouTube sozinho não segura o limite: ele se perde
  /// quando o usuário assiste de novo, avança a barra além dos 2 minutos ou
  /// abre um vídeo relacionado. Por isso a posição também é vigiada aqui, e
  /// ao passar do limite o trailer é carregado de novo, parado no início.
  ///
  /// `cueVideoById`, e não `seekTo`: na web o `seekTo` do pacote não faz
  /// nada (o player.html não consegue ler os dois argumentos que ele manda).
  StreamSubscription<YoutubeVideoState> _limitDuration() {
    return _controller.videoStateStream.listen((state) {
      if (state.position >= TrailerPlayer.maxDuration) {
        _controller.cueVideoById(
          videoId: widget.youtubeKey,
          endSeconds: _maxSeconds,
        );
      }
    });
  }

  @override
  void dispose() {
    _durationLimit.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      // Sem isso, rolar a tela até o player sumir reinicia o vídeo.
      keepAlive: true,
      // Enquanto o player carrega, aparece a miniatura do vídeo. Na web o
      // Flutter a baixa por XHR, e a WebP do YouTube não tem CORS: a imagem
      // falha e o console mostra erro. A JPEG do mesmo CDN tem.
      thumbnailFormat: ThumbnailFormat.jpeg,
    );
  }
}
