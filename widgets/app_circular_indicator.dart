///Modified 'percent_indicator 3.0.1' licensed by BSD 2-Clause License

///LICENSE: Don't remove it
//BSD 2-Clause License
//
// Copyright (c) 2018, diegoveloper@gmail.com
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

///SOURCE
import 'package:flutter/material.dart';
import 'dart:math' as math;

enum MaskFilterSide { center, internal, external }

enum CircularStrokeCap { butt, round, square }

enum ArcType {
  HALF,
  FULL,
}

///Create new Paint from existing
Paint createPaintFrom(Paint fromPaint) {
  Paint to = Paint();
  to.color = fromPaint.color;
  to.style = fromPaint.style;
  to.strokeWidth = fromPaint.strokeWidth;
  to.strokeCap = fromPaint.strokeCap;
  to.maskFilter = fromPaint.maskFilter;
  to.shader = fromPaint.shader;
  return to;
}

class AppCircularIndicator extends StatefulWidget {
  ///Percent value between 0.0 and 1.0
  final double percent;
  final double radius;

  ///Width of the progress bar of the circle
  final double lineWidth;

  ///Width of the unfilled background of the progress bar
  final double backgroundWidth;

  ///Color of the background of the circle , default = transparent
  final Color fillColor;

  ///First color applied to the complete circle
  final Color backgroundColor;

  Color get progressColor => _progressColor;

  final Color _progressColor;

  ///true if you want the circle to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget at the top of the circle
  final Widget? header;

  ///widget at the bottom of the circle
  final Widget? footer;

  ///widget inside the circle
  final Widget Function(double)? center;

  final LinearGradient? linearGradient;

  ///The kind of finish to place on the end of lines drawn, values supported: butt, round, square
  final CircularStrokeCap? circularStrokeCap;

  ///the angle which the circle will start the progress (in degrees, eg: 0.0, 45.0, 90.0)
  final double startAngle;

  /// set true if you want to animate the linear from the last percent value you set
  final bool animateFromLastPercent;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set the arc type
  final ArcType? arcType;

  /// set a circular background color when use the arcType property
  final Color? arcBackgroundColor;

  /// set true when you want to display the progress in reverse mode
  final bool reverse;

  /// Creates a mask filter that takes the progress shape being drawn and blurs it.
  final MaskFilter? maskFilter;

  /// set a circular curve animation type
  final Curve curve;

  /// set true when you want to restart the animation, it restarts only when reaches 1.0 as a value
  /// defaults to false
  final bool restartAnimation;

  /// Callback called when the animation ends (only if `animation` is true)
  final VoidCallback? onAnimationEnd;

  /// Display a widget indicator at the end of the progress. It only works when `animation` is true
  final Widget? widgetIndicator;

  /// Set to true if you want to rotate linear gradient in accordance to the [startAngle].
  final bool rotateLinearGradient;

  /// Modified: Difference between main circle and background circle;
  final double radiusBackgroundDifference;

  ///Modified: Rounded radius parameter for create specific non-existent CircularStrokeCap named 'roundedSquare'.
  ///Warning: Use this param may be unstable with some parameters.
  final double specificLineRound;

  ///Modified: This parameter need to change if you need to fix roundedSquare visualisation bug. Temporary solution!
  final double lambda;

  ///Modified: Make param for filter
  ///Warning: Use this param may be unstable with some parameters.
  final MaskFilterSide maskFilterSide;

  AppCircularIndicator({
    Key? key,
    this.percent = 0.0,
    this.lineWidth = 16.0,
    this.startAngle = 0.0,
    required this.radius,
    this.fillColor = Colors.transparent,
    this.backgroundColor = const Color(0xFFB8C7CB),
    Color? progressColor,
    this.backgroundWidth =
        12, //negative values ignored, replaced with lineWidth
    this.linearGradient,
    this.animation = false,
    this.animationDuration = 500,
    this.header,
    this.footer,
    this.center,
    this.addAutomaticKeepAlive = true,
    this.circularStrokeCap,
    this.arcBackgroundColor,
    this.arcType,
    this.animateFromLastPercent = false,
    this.reverse = false,
    this.curve = Curves.linear,
    this.maskFilter,
    this.restartAnimation = false,
    this.onAnimationEnd,
    this.widgetIndicator,
    this.rotateLinearGradient = false,
    this.maskFilterSide = MaskFilterSide.internal,
    this.radiusBackgroundDifference = 2,
    this.specificLineRound = 3,
    this.lambda = 1462,
  })  : _progressColor = progressColor ?? Colors.red,
        super(key: key) {
    if (linearGradient != null && progressColor != null) {
      throw ArgumentError(
          'Cannot provide both linearGradient and progressColor');
    }
    assert(startAngle >= 0.0);
    if (percent < 0.0 || percent > 1.0) {
      throw Exception("Percent value must be a double between 0.0 and 1.0");
    }

    if (arcType == null && arcBackgroundColor != null) {
      throw ArgumentError('arcType is required when you arcBackgroundColor');
    }
  }

  @override
  _AppCircularIndicatorState createState() => _AppCircularIndicatorState();
}

class _AppCircularIndicatorState extends State<AppCircularIndicator>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController? _animationController;
  Animation? _animation;
  double _percent = 0.0;

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController!.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.animationDuration));
      _animation = Tween(begin: 0.0, end: widget.percent).animate(
        CurvedAnimation(parent: _animationController!, curve: widget.curve),
      )..addListener(() {
          setState(() {
            _percent = _animation!.value;
          });
          if (widget.restartAnimation && _percent == 1.0) {
            _animationController!.repeat(min: 0, max: 1.0);
          }
        });
      _animationController!.addStatusListener((status) {
        if (widget.onAnimationEnd != null &&
            status == AnimationStatus.completed) {
          widget.onAnimationEnd!();
        }
      });
      _animationController!.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  void _checkIfNeedCancelAnimation(AppCircularIndicator oldWidget) {
    if (oldWidget.animation &&
        !widget.animation &&
        _animationController != null) {
      _animationController!.stop();
    }
  }

  @override
  void didUpdateWidget(AppCircularIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent ||
        oldWidget.startAngle != widget.startAngle) {
      if (_animationController != null) {
        _animationController!.duration =
            Duration(milliseconds: widget.animationDuration);
        _animation = Tween(
                begin: widget.animateFromLastPercent ? oldWidget.percent : 0.0,
                end: widget.percent)
            .animate(
          CurvedAnimation(parent: _animationController!, curve: widget.curve),
        );
        _animationController!.forward(from: 0.0);
      } else {
        _updateProgress();
      }
    }
    _checkIfNeedCancelAnimation(oldWidget);
  }

  _updateProgress() {
    setState(() {
      _percent = widget.percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var items = List<Widget>.empty(growable: true);
    if (widget.header != null) {
      items.add(widget.header!);
    }
    items.add(
      Container(
        height: widget.radius,
        width: widget.radius,
        child: Stack(
          children: [
            CustomPaint(
              painter: CirclePainter(
                progress: _percent * 360,
                progressColor: widget.progressColor,
                backgroundColor: widget.backgroundColor,
                startAngle: widget.startAngle,
                circularStrokeCap: widget.circularStrokeCap,
                radius: (widget.radius / 2) - widget.lineWidth / 2,
                lineWidth: widget.lineWidth,
                backgroundWidth: //negative values ignored, replaced with lineWidth
                    widget.backgroundWidth >= 0.0
                        ? (widget.backgroundWidth)
                        : widget.lineWidth,
                arcBackgroundColor: widget.arcBackgroundColor,
                arcType: widget.arcType,
                reverse: widget.reverse,
                linearGradient: widget.linearGradient,
                maskFilter: widget.maskFilter,
                rotateLinearGradient: widget.rotateLinearGradient,
                radiusBackgroundDifference: widget.radiusBackgroundDifference,
                specificLineRound: widget.specificLineRound,
                maskFilterSide: widget.maskFilterSide,
                lambda: widget.lambda,
              ),
              child: (widget.center != null)
                  ? Center(child: widget.center!(_percent))
                  : Container(),
            ),
            if (widget.widgetIndicator != null && widget.animation)
              Positioned.fill(
                child: Transform.rotate(
                  angle: radians(
                          (widget.circularStrokeCap != CircularStrokeCap.butt &&
                                  widget.reverse)
                              ? -15
                              : 0)
                      .toDouble(),
                  child: Transform.rotate(
                    angle: radians((widget.reverse ? -360 : 360) * _percent)
                        .toDouble(),
                    child: Transform.translate(
                      offset: Offset(
                        (widget.circularStrokeCap != CircularStrokeCap.butt)
                            ? widget.lineWidth / 2
                            : 0,
                        (-widget.radius / 2 + widget.lineWidth / 2),
                      ),
                      child: widget.widgetIndicator,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.footer != null) {
      items.add(widget.footer!);
    }

    return Material(
      color: widget.fillColor,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class CirclePainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final Paint _paintBackgroundStartAngle = Paint();
  final double lineWidth;
  final double backgroundWidth;
  final double progress;
  final double radius;
  final Color progressColor;
  final Color backgroundColor;
  final CircularStrokeCap? circularStrokeCap;
  final double startAngle;
  final LinearGradient? linearGradient;
  final Color? arcBackgroundColor;
  final ArcType? arcType;
  final bool reverse;
  final MaskFilter? maskFilter;
  final bool rotateLinearGradient;

  ///Modified params
  late final Paint _innerPaintLine;
  late final Paint _outerPaintLine;
  final double radiusBackgroundDifference;
  final double specificLineRound;
  final MaskFilterSide maskFilterSide;
  final double lambda;

  CirclePainter({
    required this.lineWidth,
    required this.backgroundWidth,
    required this.progress,
    required this.radius,
    required this.progressColor,
    required this.backgroundColor,
    this.startAngle = 0.0,
    this.circularStrokeCap = CircularStrokeCap.round,
    this.linearGradient,
    required this.reverse,
    this.arcBackgroundColor,
    this.arcType,
    this.maskFilter,
    required this.rotateLinearGradient,
    required this.radiusBackgroundDifference,
    required this.maskFilterSide,
    required this.lambda,
    required double specificLineRound,
  }) : this.specificLineRound = specificLineRound > lineWidth / 2
            ? lineWidth / 2
            : specificLineRound {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = backgroundWidth;
    if (circularStrokeCap == CircularStrokeCap.round) {
      _paintBackground.strokeCap = StrokeCap.round;
    } else if (circularStrokeCap == CircularStrokeCap.butt) {
      _paintBackground.strokeCap = StrokeCap.butt;
    } else {
      _paintBackground.strokeCap = StrokeCap.square;
    }
    if (arcBackgroundColor != null) {
      _paintBackgroundStartAngle.color = arcBackgroundColor!;
      _paintBackgroundStartAngle.style = PaintingStyle.stroke;
      _paintBackgroundStartAngle.strokeWidth = lineWidth;
      if (circularStrokeCap == CircularStrokeCap.round) {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.round;
      } else if (circularStrokeCap == CircularStrokeCap.butt) {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.butt;
      } else {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.square;
      }
    }

    _paintLine.color = progressColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;
    if (circularStrokeCap == CircularStrokeCap.round) {
      _paintLine.strokeCap = StrokeCap.round;
    } else if (circularStrokeCap == CircularStrokeCap.butt) {
      _paintLine.strokeCap = StrokeCap.butt;
    } else {
      _paintLine.strokeCap = StrokeCap.square;
    }
    _paintLine.strokeCap = StrokeCap.square;

    if (this.specificLineRound > 0) {
      ///INNER LINE
      _innerPaintLine = createPaintFrom(_paintLine);
      _innerPaintLine.strokeWidth = specificLineRound * 2;
      _innerPaintLine.strokeCap = StrokeCap.round;

      ///OUTER LINE
      _outerPaintLine = createPaintFrom(_paintLine);
      _outerPaintLine.strokeWidth = specificLineRound * 2;
      _outerPaintLine.strokeCap = StrokeCap.round;

      ///CENTER LINE
      _paintLine.strokeWidth = lineWidth - specificLineRound * 2;
      _paintLine.strokeCap = StrokeCap.square;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundRadius = this.radius + this.radiusBackgroundDifference;
    final center = Offset(size.width / 2, size.height / 2);
    double fixedStartAngle = startAngle;
    final rectForArc = Rect.fromCircle(center: center, radius: radius);
    double startAngleFixedMargin = 1.0;
    if (arcType != null) {
      if (arcType == ArcType.FULL) {
        fixedStartAngle = 220;
        startAngleFixedMargin = 172 / fixedStartAngle;
      } else {
        fixedStartAngle = 270;
        startAngleFixedMargin = 135 / fixedStartAngle;
      }
    }
    if (arcType == ArcType.HALF) {
      canvas.drawArc(
          rectForArc,
          radians(-90.0 + fixedStartAngle).toDouble(),
          radians(360 * startAngleFixedMargin).toDouble(),
          false,
          _paintBackground);
    } else {
      canvas.drawCircle(center, backgroundRadius, _paintBackground);
    }

    if (maskFilter != null) {
      _paintLine.maskFilter = maskFilter;
    }
    if (linearGradient != null) {
      if (rotateLinearGradient && progress > 0) {
        double correction = 0;
        if (_paintLine.strokeCap == StrokeCap.round ||
            _paintLine.strokeCap == StrokeCap.square) {
          if (reverse) {
            correction = math.atan(_paintLine.strokeWidth / 2 / radius);
          } else {
            correction = math.atan(_paintLine.strokeWidth / 2 / radius);
          }
        }
        _paintLine.shader = SweepGradient(
                transform: reverse
                    ? GradientRotation(
                        radians(-90 - progress + startAngle) - correction)
                    : GradientRotation(
                        radians(-90.0 + startAngle) - correction),
                startAngle: radians(0).toDouble(),
                endAngle: radians(progress).toDouble(),
                tileMode: TileMode.clamp,
                colors: reverse
                    ? linearGradient!.colors.reversed.toList()
                    : linearGradient!.colors)
            .createShader(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
        );
      } else if (!rotateLinearGradient) {
        _paintLine.shader = linearGradient!.createShader(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
        );
      }
    }

    fixedStartAngle = startAngle;

    startAngleFixedMargin = 1.0;
    if (arcType != null) {
      if (arcType == ArcType.FULL) {
        fixedStartAngle = 220;
        startAngleFixedMargin = 172 / fixedStartAngle;
      } else {
        fixedStartAngle = 270;
        startAngleFixedMargin = 135 / fixedStartAngle;
      }
    }

    if (arcBackgroundColor != null) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians(-90.0 + fixedStartAngle).toDouble(),
        radians(360 * startAngleFixedMargin).toDouble(),
        false,
        _paintBackgroundStartAngle,
      );
    }

    final double start;
    final double end;
    if (reverse) {
      start = radians(360 * startAngleFixedMargin - 90.0 + fixedStartAngle)
          .toDouble();
      end = radians(-progress * startAngleFixedMargin).toDouble();
    } else {
      start = radians(-90.0 + fixedStartAngle).toDouble();
      end = radians(progress * startAngleFixedMargin).toDouble();
    }

    if (specificLineRound > 0 && progress > 0) {
      ///It temporary solution. Enough for the current tasks.
      final percentLambda = 0.00001;
      final _innerPaintLineSpaceSize = percentLambda *
          (lambda + specificLineRound * _paintLine.strokeWidth / 2);
      final _outerPaintLineSpaceSize = percentLambda *
          (lambda - specificLineRound * _paintLine.strokeWidth / 2);
      final _paintLineSpaceSize =
          percentLambda * lambda * (1 / specificLineRound);

      ///-------------------------------------------------

      if (maskFilterSide != MaskFilterSide.internal)
        _innerPaintLine.maskFilter = null;
      else
        _innerPaintLine.maskFilter = maskFilter;

      if (maskFilterSide != MaskFilterSide.external)
        _outerPaintLine.maskFilter = null;
      else
        _outerPaintLine.maskFilter = maskFilter;

      if (maskFilterSide != MaskFilterSide.center)
        _paintLine.maskFilter = null;
      else
        _paintLine.maskFilter = maskFilter;

      ///INNER LINE
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius - lineWidth / 2 + specificLineRound,
        ),
        start - _innerPaintLineSpaceSize,
        end + _innerPaintLineSpaceSize * 2,
        false,
        _innerPaintLine,
      );

      ///OUTER LINE
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius + lineWidth / 2 - specificLineRound,
        ),
        start - _outerPaintLineSpaceSize,
        end + _outerPaintLineSpaceSize * 2,
        false,
        _outerPaintLine,
      );

      ///CENTER LINE
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        start + _paintLineSpaceSize,
        end - _paintLineSpaceSize * 2,
        false,
        _paintLine,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        start,
        end,
        false,
        _paintLine,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

num radians(num deg) => deg * (math.pi / 180.0);
