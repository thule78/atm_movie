import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../domain/models/movie_trailer.dart';

class TrailerPlayerScreen extends StatefulWidget {
  const TrailerPlayerScreen({
    super.key,
    required this.trailers,
    required this.initialTrailer,
  });

  final List<MovieTrailer> trailers;
  final MovieTrailer initialTrailer;

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late final YoutubePlayerController _controller;
  late MovieTrailer _selectedTrailer;
  int _errorCode = 0;

  @override
  void initState() {
    super.initState();
    _selectedTrailer = widget.initialTrailer;
    _controller = YoutubePlayerController(
      initialVideoId: _selectedTrailer.youtubeKey,
      flags: const YoutubePlayerFlags(autoPlay: true, enableCaption: true),
    )..addListener(_onPlayerChanged);
  }

  void _onPlayerChanged() {
    if (!mounted) {
      return;
    }

    final nextErrorCode = _controller.value.errorCode;
    if (nextErrorCode == _errorCode) {
      return;
    }

    setState(() {
      _errorCode = nextErrorCode;
    });
  }

  void _selectTrailer(MovieTrailer trailer) {
    if (trailer.youtubeKey == _selectedTrailer.youtubeKey) {
      return;
    }

    setState(() {
      _selectedTrailer = trailer;
      _errorCode = 0;
    });
    _controller.load(trailer.youtubeKey);
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Theme.of(context).colorScheme.primary,
      progressColors: ProgressBarColors(
        playedColor: Theme.of(context).colorScheme.primary,
        handleColor: Theme.of(context).colorScheme.primary,
      ),
    );

    return YoutubePlayerBuilder(
      player: player,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: Text(_selectedTrailer.name)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
            children: [
              _errorCode == 0
                  ? player
                  : _BlockedTrailerState(errorCode: _errorCode),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Trailer List',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.trailers.map(
                (trailer) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        trailer.youtubeKey == _selectedTrailer.youtubeKey
                            ? Icons.play_circle_filled_rounded
                            : Icons.play_circle_outline_rounded,
                      ),
                      title: Text(trailer.name),
                      subtitle: Text(
                        trailer.isOfficial
                            ? 'Official YouTube trailer'
                            : 'YouTube trailer',
                      ),
                      trailing:
                          trailer.youtubeKey == _selectedTrailer.youtubeKey
                          ? Text(
                              'Playing',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: () => _selectTrailer(trailer),
                    ),
                  ),
                ),
              ),
              if (_errorCode != 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Text(
                    _errorDescription(_errorCode),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _errorDescription(int errorCode) {
    switch (errorCode) {
      case 2:
        return 'This trailer link is invalid.';
      case 5:
        return 'YouTube could not start this trailer in the embedded player.';
      case 100:
      case 105:
        return 'This trailer is no longer available on YouTube.';
      case 101:
      case 150:
      case 152:
        return 'This YouTube trailer cannot be played inside embedded players. Select another trailer below.';
      default:
        return 'YouTube blocked or failed this trailer inside the embedded player. Select another trailer below.';
    }
  }
}

class _BlockedTrailerState extends StatelessWidget {
  const _BlockedTrailerState({required this.errorCode});

  final int errorCode;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  'Trailer unavailable in embedded player',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'YouTube error: $errorCode',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
