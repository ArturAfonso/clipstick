

import 'package:clipstick/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  final Duration minDisplayDuration;
  const SplashScreen({super.key, this.minDisplayDuration = const Duration(milliseconds: 800)});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration && !_navigated) {
        _navigated = true;
        _goToHome();
      }
    });

    // fallback: por segurança, navega após minDisplayDuration + 3s
    Future.delayed(widget.minDisplayDuration + const Duration(seconds: 5), () {
      if (!_navigated) {
        _navigated = true;
        _goToHome();
      }
    });
  }

  void _goToHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

   double circleSize = 250.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: /* _controller.value.isInitialized
            ?  */SizedBox(
              width: circleSize, // Largura e Altura iguais para um CÍRCULO
              height: circleSize,
              child: ClipOval(

                child: FittedBox(
                   fit: BoxFit.fill, // ou BoxFit.scaleDown
                  child: SizedBox(
                     width: _controller.value.size.width,
                  height: _controller.value.size.height,
                    child: VideoPlayer(_controller))),
              ),
            )
          /*   : Image.asset('assets/clipstick-logo.png', width: 160, height: 160), */
      ),
    );
  }
}
