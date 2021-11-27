import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class WaveWidget extends LeafRenderObjectWidget {
  final List<WaveInfo> waveInfo;

  const WaveWidget({Key? key, required this.waveInfo}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderWaveWidget(waveInfoList: waveInfo);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderWaveWidget renderObject) {
    renderObject.waveInfoList = waveInfo;
  }
}

class _RenderWaveWidget extends RenderProxyBox {
  List<WaveInfo> _waveInfoList = const [];

  _RenderWaveWidget({required List<WaveInfo> waveInfoList})
      : _waveInfoList = waveInfoList {
    _setupAnimation();
  }

  void _setupAnimation() {
    for (int i = 0; i < waveInfoList.length; i++) {
      var waveInfo = waveInfoList[i];
      _setupHeightAnimation(waveInfo, i);
      _setUpPhaseAnimation(waveInfo, i);
    }
  }

  Animation<double> _setupHeightAnimation(WaveInfo waveInfo, int i) {
    final Animation<double> animation = Tween(begin: 1.0, end: -0.5).animate(
        CurvedAnimation(parent: waveInfo.controller, curve: waveInfo.curve));

    animation.addListener(() {
      _waveInfoList[i] = waveInfo..amplitudeAnimationVal = animation.value;
      markNeedsPaint();
    });

    return animation;
  }

  Animation<double> _setUpPhaseAnimation(WaveInfo waveInfo, int i) {
    final Animation<double> animation = Tween<double>(begin: 1, end: -1)
        .animate(CurvedAnimation(
            parent: waveInfo.phaseController, curve: waveInfo.curve));

    animation.addListener(() {
      _waveInfoList[i] = waveInfo..phaseShiftAnimationVal = animation.value;
      markNeedsPaint();
    });
    return animation;
  }

  set waveInfoList(List<WaveInfo> value) {
    if (_waveInfoList == value) return;

    _waveInfoList = value;
    _setupAnimation();

    markNeedsPaint();
  }

  List<WaveInfo> get waveInfoList => _waveInfoList;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  bool get sizedByParent => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    offset = Offset(constraints.maxWidth, constraints.maxHeight);

    return _paintWave(context, offset);
  }

  void _paintWave(PaintingContext context, Offset offset) {
    final size = getDryLayout(constraints);
    Path path = Path();

    context.pushClipRect(
      true,
      Offset(0, size.height),
      Offset.zero & size,
      (context, offset) {
        final canvas = context.canvas;

        canvas.translate(0, size.height);

        for (WaveInfo wave in waveInfoList) {
          path.reset();

          path.moveTo(0, size.height);

          for (int i = 1; i < size.width; i++) {
            path.lineTo(
              i.toDouble(),
              verticlePoint(
                wave: wave,
                x: i.toDouble(),
              ),
            );
          }

          path.lineTo(size.width, size.height);

          canvas.drawPath(path, Paint()..color = wave.color.withOpacity(.4));
          path.close();
        }
      },
    );
  }

  double verticlePoint({required double x, required WaveInfo wave}) {
    var period = (2 * math.pi / wave.waveLength);

    /// Controls horizontal shift
    var sinX = (x + (wave.phaseShift * wave.phaseShiftAnimationVal));
    return (wave.amplitude * wave.amplitudeAnimationVal) *
            math.sin(period * sinX) +
        20 * wave.verticalShift;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return constraints.maxHeight;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return constraints.maxHeight;
  }
}

class WaveInfo {
  final Color color;

  ///[verticalShift] value within 1 to 10
  final double verticalShift;
  final double amplitude;
  final double phaseShift;
  final Duration duration;
  final double waveLength;

  final AnimationController controller;
  final AnimationController phaseController;
  final Curve curve;
  double amplitudeAnimationVal;
  double phaseShiftAnimationVal;

  WaveInfo({
    this.color = Colors.blue,
    this.verticalShift = 1,
    this.amplitude = 10,
    this.phaseShift = 0,
    required this.controller,
    required this.phaseController,
    this.curve = Curves.easeInOut,
    this.amplitudeAnimationVal = 1,
    this.phaseShiftAnimationVal = 0,
    this.waveLength = 150,
    this.duration = const Duration(milliseconds: 300),
  }) : assert(verticalShift >= 1 && verticalShift <= 10);
}
