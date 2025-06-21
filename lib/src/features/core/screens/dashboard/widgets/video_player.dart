import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

/// A widget that plays a video from a network URL or a local file using
/// [video_player] and [chewie] for a consistent video UI.
///
/// This widget supports reinitialization if the source file or URL changes,
/// and handles video looping back to the start once finished.
class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final File? file;

  const VideoPlayerWidget({super.key, this.videoUrl, this.file});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl || oldWidget.file?.path != widget.file?.path) {
      _initializePlayer();
    }
  }

  /// Initializes the video player and chewie controller based on input source.
  ///
  /// Disposes of any previously created controllers. If the video finishes,
  /// it automatically seeks back to the beginning.
  Future<void> _initializePlayer() async {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    if (widget.file != null) {
      _videoPlayerController = VideoPlayerController.file(widget.file!);
    } else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else {
      return;
    }

    await _videoPlayerController!.initialize();

    _videoPlayerController!.addListener(() {
      final isFinished = _videoPlayerController!.value.position >= _videoPlayerController!.value.duration;
      if (isFinished && !_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.seekTo(Duration.zero);
        _chewieController?.pause();
      }
    });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null && _videoPlayerController!.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
