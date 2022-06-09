import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class AppRateChart extends StatefulWidget {
  ///Parameters for AppRateChart
  final Curve curve;
  final Duration duration;
  final bool animation;
  final bool repeatAnimation;
  final VoidCallback? onAnimationEnd;

  final List<double> dots;
  final Widget Function(BuildContext, int, double, double, bool)? dotBuilder;

  final double dotRadius;
  final double height;
  final double width;
  final double? lineWidth;
  final Color? color;
  final LinearGradient? gradient;
  final MaskFilter? filter;

  get dotsEqual => const ListEquality().equals;

  const AppRateChart({
    required this.dots,
    this.dotRadius = 18,
    this.dotBuilder,
    this.color,
    this.lineWidth,
    this.gradient,
    this.filter,
    this.onAnimationEnd,
    this.repeatAnimation = false,
    this.animation = true,
    this.curve = Curves.ease,
    this.duration = const Duration(milliseconds: 1000),
    double? height,
    double? width,
  })  : height = height ?? double.infinity,
        width = width ?? double.infinity;

  @override
  State<StatefulWidget> createState() {
    return _AppRateChartState();
  }
}

class _AppRateChartState extends State<AppRateChart>
    with TickerProviderStateMixin {
  ///Stateless parameters
  AnimationController? _animationController;
  Animation? _animation;
  double _status = 0.0;
  List<Offset> dotsOffsets = [];

  ///Calculate dots Offsets using widget Size
  void calcOffsets(Size size) {
    dotsOffsets = [];
    for (int i = 0; i < widget.dots.length; i++) {
      Offset currentOffset;
      final bottom = (0.5 + widget.dots[i]) * 0.5;
      if (i == 0) {
        currentOffset = Offset(
          _percentLeft(size, 0.12),
          _percentBottom(size, bottom),
        );
      } else if (i == widget.dots.length - 1) {
        currentOffset = Offset(
          _percentLeft(size, 0.88),
          _percentBottom(size, bottom),
        );
      } else {
        final double rightPercent = (1 / (widget.dots.length + 1)) * (i + 1);
        currentOffset = Offset(
          _percentLeft(size, rightPercent + (1 - rightPercent) * 0.2),
          _percentBottom(size, bottom),
        );
      }
      dotsOffsets.add(currentOffset);
    }
  }

  ///Updating status and screen state when animation update
  onAnimationUpdate() {
    setState(() {
      _status = widget.animation ? _animation?.value ?? 1.0 : 1.0;
    });
    if (widget.animation && widget.repeatAnimation && _status == 1.0) {
      _animationController?.repeat(min: 0, max: 1.0);
    }
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      _animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: widget.curve,
        ),
      )..addListener(onAnimationUpdate);
      _animationController!.addStatusListener((status) {
        if (widget.onAnimationEnd != null &&
            status == AnimationStatus.completed) {
          widget.onAnimationEnd!();
        }
      });
      _animationController!.forward();
    } else {
      onAnimationUpdate();
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppRateChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.dotsEqual(oldWidget.dots, widget.dots)) {
      if (_animationController != null) {
        _animationController!.duration = widget.duration;
        _animation = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController!, curve: widget.curve),
        );
        _animationController!.forward(from: 0.0);
      } else {
        onAnimationUpdate();
      }
    }
    if (oldWidget.animation && !widget.animation) _animationController?.stop();
  }

  @override
  Widget build(BuildContext context) {
    ///Calculate dotsOffset when screen size will be available
    if (widget.height != double.infinity && widget.width != double.infinity) {
      calcOffsets(Size(widget.width, widget.height));
    } else {
      RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) calcOffsets(renderBox.size);
    }

    ///Render body
    return body(
      painterBuilder: painter,
      dotsWidgetsBuilder: dotsWidgets,
    );
  }

  Widget body({
    required Widget Function() painterBuilder,
    required List<Widget> Function() dotsWidgetsBuilder,
  }) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ClipRRect(
        child: Stack(
          children: [
            if (dotsOffsets.length > 0) painterBuilder(),
            if (widget.dotBuilder != null) ...dotsWidgets()
          ],
        ),
      ),
    );
  }

  ///Build painter what will draw chart lines
  Widget painter() {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: CustomPaint(
        painter: _ChartPainter(
          dots: widget.dots,
          dotsOffsets: dotsOffsets,
          status: _status,
          lineColor: widget.color,
          lineWidth: widget.lineWidth ?? 10,
          linearGradient: widget.gradient,
          maskFilter: widget.filter,
        ),
      ),
    );
  }

  ///Build dotsWidget what will draw widget with center in dotOffsets
  List<Widget> dotsWidgets() {
    return [
      for (int i = 0; i < dotsOffsets.length; i++)
        Positioned(
          left: dotsOffsets[i].dx - widget.dotRadius,
          top: (dotsOffsets[i].dy - widget.dots[i]) - widget.dotRadius,
          child: widget.dotBuilder!(context, i, _status, widget.dots[i],
              _status > (i + 2) / (dotsOffsets.length + 2)),
        ),
    ];
  }
}

class _ChartPainter extends CustomPainter {
  ///Parameters for _ChartPainter
  final Paint _paintLine = Paint();
  final double lineWidth;
  final Color lineColor;
  final LinearGradient? linearGradient;
  final MaskFilter? maskFilter;
  final double status;

  late final List<double> dots;
  late final List<Offset> dotsOffsets;

  _ChartPainter({
    required this.dots,
    required this.dotsOffsets,
    required this.status,
    required this.lineWidth,
    Color? lineColor,
    this.linearGradient,
    this.maskFilter,
  }) : this.lineColor = lineColor ?? Colors.redAccent {
    _paintLine.color = this.lineColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;
    _paintLine.strokeCap = StrokeCap.round;
  }

  ///Main paint method what called every frame
  @override
  void paint(Canvas canvas, Size size) {
    ///Set FILTER mask
    if (maskFilter != null) {
      _paintLine.maskFilter = maskFilter;
    }

    ///Set GRADIENT shader
    if (linearGradient != null) {
      _paintLine.shader = linearGradient!.createShader(
        Rect.fromCenter(
          width: size.width - _percentLeft(size, 0.05),
          height: size.height,
          center: Offset(size.width / 2, size.height / 2),
        ),
      );
    }

    ///Draw lines
    final Offset startOffset = Offset(0, _percentBottom(size, 0));
    final Offset endOffset = Offset(size.width, _percentBottom(size, 0.96));
    Offset lastOffset = startOffset;
    Tween<Offset> tweenOffset;
    double currentLocalStatus;

    ///Draw line from previous to CURRENT DOT
    for (int i = 0; i < dots.length; i++) {
      currentLocalStatus = _calcLocalStatus(
        (i + 1) / (dots.length + 2),
        (i + 2) / (dots.length + 2),
        status,
      );
      tweenOffset = Tween<Offset>(
        begin: lastOffset,
        end: dotsOffsets[i],
      );
      if (currentLocalStatus > 0)
        canvas.drawLine(
          lastOffset,
          tweenOffset.transform(currentLocalStatus),
          _paintLine,
        );
      lastOffset = dotsOffsets[i];
    }

    ///Draw line from previous to END DOT
    tweenOffset = Tween<Offset>(
      begin: lastOffset,
      end: endOffset,
    );
    currentLocalStatus = _calcLocalStatus(
      (dots.length + 1) / (dots.length + 2),
      1,
      status,
    );
    if (currentLocalStatus > 0)
      canvas.drawLine(
        lastOffset,
        tweenOffset.transform(
          currentLocalStatus,
        ),
        _paintLine,
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

///Calculate local status(0..1) from section of global status (start<end, start > 0, end  < 1)
double _calcLocalStatus(double start, double end, double globalStatus) =>
    globalStatus <= start
        ? 0
        : globalStatus >= end
            ? 1
            : (globalStatus - start) * (1 / (end - start));

///Get left edge from size and size percent
double _percentLeft(Size size, double percent) => size.width * percent;

///Get bottom edge from size and size percent
double _percentBottom(Size size, double percent) =>
    size.height - size.height * percent;
