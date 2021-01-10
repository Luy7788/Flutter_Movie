import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nmtv/common/model/eventBusModes.dart';
import 'package:nmtv/common/config/adapt.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/common/utils/navigation.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

class LaunchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new LaunchPageState();
  }
}

class LaunchPageState extends State<LaunchPage> with SingleTickerProviderStateMixin implements OnSkipClickListener {
  Timer _timer;
  //动画控制器
  AnimationController controller;
//  admob _admmob;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();

    Timer(Duration(seconds: 1), () {
      // 只在倒计时结束时回调
      controller.forward(from: 0.5);
    });

    _timer = Timer(Duration(seconds: 2), () {
      // 只在倒计时结束时回调
      onSkipClick();
    });

    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
        print("status is dismissed");
      } else if (status == AnimationStatus.forward) {
        print("status is forward");
        //执行 controller.forward() 会回调此状态
      } else if (status == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
        print("status is reverse");
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
//    _admmob?.hideAdInterstitial();
    Global.eventBus.fire(EventBusBannerAd()..isShow = true);
//    _timer = null;
  }

  void onSkipClick() {
    print('点击onSkipClick');
    Navigation.pushHomePage(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        new Container(
          color: Colors.yellow.shade600,
          child: Center(
            child:  ScaleTransition(
              //设置动画的缩放中心
              alignment: Alignment.center,
              //动画控制器
              scale: controller,
              //将要执行动画的子view
              child: Image.asset(
                IconsCustom.ICON_APP,
                width: 300,
                height: 300,
              ),
            ),
          ),
          constraints: new BoxConstraints.expand(),
        ),
      ],
    );
  }
}

class _DrawProgress extends CustomPainter {
  final Color color;
  final double radius;
  double angle;
  AnimationController animation;

  Paint circleFillPaint;
  Paint progressPaint;
  Rect rect;

  _DrawProgress(this.color, this.radius,
      {double this.angle, AnimationController this.animation}) {
    circleFillPaint = new Paint();
    circleFillPaint.color = Colors.white;
    circleFillPaint.style = PaintingStyle.fill;

    progressPaint = new Paint();
    progressPaint.color = color;
    progressPaint.style = PaintingStyle.stroke;
    progressPaint.strokeCap = StrokeCap.round;
    progressPaint.strokeWidth = 4.0;

    if (animation != null && !animation.isAnimating) {
      animation.forward();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    double x = size.width / 2;
    double y = size.height / 2;
    Offset center = new Offset(x, y);
    canvas.drawCircle(center, radius - 2, circleFillPaint);
    rect = Rect.fromCircle(center: center, radius: radius);
    angle = angle * (-1);
    double startAngle = -math.pi / 2;
    double sweepAngle = math.pi * angle / 180;
//    print("draw paint-------------------= $startAngle, $sweepAngle");
    // canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    //1.0.0之后换种绘制圆弧的方式:
    Path path = new Path();
    path.arcTo(rect, startAngle, sweepAngle, true);
    canvas.drawPath(path, progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class SkipDownTimeProgress extends StatefulWidget {
  final Color color;
  final double radius;
  final Duration duration;
  final Size size;
  String skipText;
  OnSkipClickListener clickListener;

  SkipDownTimeProgress(
    this.color,
    this.radius,
    this.duration,
    this.size, {
    Key key,
    String this.skipText = "跳过",
    OnSkipClickListener this.clickListener,
  }) : super(key: key);

  @override
  _SkipDownTimeProgressState createState() {
    return new _SkipDownTimeProgressState();
  }
}

class _SkipDownTimeProgressState extends State<SkipDownTimeProgress>
    with TickerProviderStateMixin {
  AnimationController animationController;
  double curAngle = 360.0;

  @override
  void initState() {
    super.initState();
    print('initState----------------------');
    animationController =
        new AnimationController(vsync: this, duration: widget.duration);
    animationController.addListener(_change);
    _doAnimation();
  }

  @override
  void didUpdateWidget(SkipDownTimeProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget----------------------');
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose----------------------');
    animationController.dispose();
  }

  void _onSkipClick() {
    if (widget.clickListener != null) {
      print('skip onclick ---------------');
      widget.clickListener.onSkipClick();
    }
  }

  void _doAnimation() async {
    Future.delayed(new Duration(milliseconds: 50), () {
      if (mounted) {
        animationController.forward().orCancel;
      } else {
        _doAnimation();
      }
    });
  }

  void _change() {
//    print('ange == $animationController.value');
    double ange =
        double.parse(((animationController.value * 360) ~/ 1).toString());
    if (ange == 360.0) {
      _onSkipClick();
    }
    setState(() {
      curAngle = (360.0 - ange);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: _onSkipClick,
      child: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          new CustomPaint(
            painter:
                new _DrawProgress(widget.color, widget.radius, angle: curAngle),
            size: widget.size,
          ),
          Text(
            widget.skipText,
            style: TextStyle(
                color: widget.color,
                fontSize: 13.5,
                decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}

abstract class OnSkipClickListener {
  void onSkipClick();
}
