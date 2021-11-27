import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:wave_widget/widgets/wave_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  List<AnimationController> animationController = [];
  List<AnimationController> phaseAnimationController = [];

  @override
  void initState() {
    animationController = [
      _buildAnimationController(2500),
      _buildAnimationController(3500)
    ];

    phaseAnimationController = [
      _buildAnimationController(3500, isPhase: true),
      _buildAnimationController(4500, isPhase: true)
    ];
    _play();
    super.initState();
  }

  AnimationController _buildAnimationController(int miliSecond,
      {bool isPhase = false}) {
    var animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: miliSecond),
    );
    if (isPhase) {
      animationController.repeat(
          reverse: true, period: const Duration(seconds: 5));
    } else {
      animationController.repeat(reverse: true);
    }
    return animationController;
  }

  void _play() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/ocean_wave.mp3"),
      autoStart: true,
      showNotification: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: 400,
            width: 392,
            child: WaveWidget(
              waveInfo: [
                WaveInfo(
                  amplitude: 15,
                  color: Colors.blue,
                  verticalShift: 3,
                  waveLength: 300,
                  phaseShift: 300,
                  curve: Curves.easeInSine,
                  controller: animationController[0],
                  phaseController: phaseAnimationController[0],
                ),
                WaveInfo(
                  amplitude: 15,
                  color: Colors.blueAccent,
                  verticalShift: 3,
                  phaseShift: -250,
                  waveLength: 230,
                  controller: animationController[1],
                  phaseController: phaseAnimationController[1],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    
    for (var element in animationController) {
      element.dispose();
    }

    for (var element in phaseAnimationController) {
      element.dispose();
    }
    super.dispose();
  }
}
