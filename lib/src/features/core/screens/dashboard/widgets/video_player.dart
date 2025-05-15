import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

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

  Future<void> _initializePlayer() async {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    if (widget.file != null) {
      _videoPlayerController = VideoPlayerController.file(widget.file!);
    } else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else {
      // Kein Video vorhanden, evtl. Fehlerbehandlung oder Default-Widget
      return;
    }

    await _videoPlayerController!.initialize();

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
