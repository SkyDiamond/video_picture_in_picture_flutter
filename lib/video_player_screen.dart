import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  final GlobalKey<State<StatefulWidget>> _playerKey =
      GlobalKey<State<StatefulWidget>>();
  final Key _pictureInPictureKey = UniqueKey();
  bool _pipBg = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/mov_bbb.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video player')),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        key: _playerKey,
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          VideoPlayer(_controller),
                          ClosedCaption(text: _controller.value.caption.text),
                          if (_controller
                              .value.isPictureInPictureActive) ...<Widget>[
                            Container(color: Colors.white),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.picture_in_picture),
                                SizedBox(height: 8),
                                Text(
                                    'This video is playing in picture in picture.'),
                              ],
                            ),
                          ] else ...<Widget>[
                            VideoProgressIndicator(_controller,
                                allowScrubbing: true),
                          ],
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<bool>(
                    key: _pictureInPictureKey,
                    future: _controller.isPictureInPictureSupported(),
                    builder: (context, snapshot) {
                      if (snapshot.data ?? false) {
                        return const Text('Picture in picture is supported');
                      }

                      return const Text('Picture in picture is not supported');
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text('picture in picture when going to bg'),
                      ),
                      Switch(
                        value: _pipBg,
                        onChanged: (bool newValue) {
                          setState(() {
                            _pipBg = newValue;
                          });
                          if (newValue) {
                            final RenderBox? box = _playerKey.currentContext
                                ?.findRenderObject() as RenderBox?;
                            if (box == null) {
                              return;
                            }
                            final Offset offset =
                                box.localToGlobal(Offset.zero);
                            _controller.setPictureInPictureOverlayRect(
                              rect: Rect.fromLTWH(
                                offset.dx,
                                offset.dy,
                                box.size.width,
                                box.size.height,
                              ),
                            );
                          } else {
                            _controller.setPictureInPictureOverlayRect(
                              rect: Rect.zero,
                            );
                          }
                          _controller.setAutomaticallyStartPictureInPicture(
                              enableStartPictureInPictureAutomaticallyFromInline:
                                  _pipBg);
                        },
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  // ElevatedButton(
                  //   onPressed: _pipBg
                  //       ? () {
                  //           final RenderBox? box = _playerKey.currentContext
                  //               ?.findRenderObject() as RenderBox?;
                  //           if (box == null) {
                  //             return;
                  //           }
                  //           final Offset offset =
                  //               box.localToGlobal(Offset.zero);
                  //           _controller.setPictureInPictureOverlayRect(
                  //             rect: Rect.fromLTWH(
                  //               offset.dx,
                  //               offset.dy,
                  //               box.size.width,
                  //               box.size.height,
                  //             ),
                  //           );
                  //         }
                  //       : null,
                  //   child: const Text('Set picture in picture overlay rect'),
                  // ),
                ],
              )
            : Container(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              if (_controller.value.isPictureInPictureActive) {
                _controller.stopPictureInPicture();
              } else {
                _controller.startPictureInPicture();
              }
            },
            child: const Icon(
              Icons.picture_in_picture,
            ),
          ),
        ],
      ),
    );
  }
}
