import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  DateTime _date = DateTime.now();
  Timer _timer;

  AnimationController _minuteAnimationController;
  Animation<double> _minuteAnimationValue;

  AnimationController _hourAnimationController;
  Animation<double> _hourAnimationValue;

  AnimationController _secondAnimationController;
  Animation<double> _secondAnimationValue;
  
  final _darkColor = Color(0xFF212121);
  final _lightColor = Color(0xFFF9F9F9);

  /// This will be called when the widget is created
  /// We put here all the initialization code.
  /// However, please note that in this function the [BuildContext] does not
  /// exist
  @override
  void initState() {
    super.initState();
    // Create the animation Controllers for minutes
    _minuteAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    // This will create an animation that will go through the values that we 
    // need: first shrink the minutes and then expand it as far as we can until
    // finally it resets at the first position
    _minuteAnimationValue = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 40.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 20.0, end: 1.0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 60.0,
        ),
      ],
    ).animate(_minuteAnimationController);

    // Create the animation Controllers for hours
    _hourAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _hourAnimationValue = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 40.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 20.0, end: 1.0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 60.0,
        ),
      ],
    ).animate(_hourAnimationController);

    // Second animation, it will take 1 minute to finish it
    _secondAnimationController = AnimationController(
        duration: Duration(minutes: 1),
        vsync: this);

    _secondAnimationValue = Tween(begin: 0.0, end: 60.0).animate(_secondAnimationController);

    // When the animation is completed, reset it
    _secondAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        this._secondAnimationController.forward(from: 0);
      }
    });

    // We need to start the animation with a valid value in the range [0.0, 1.0],
    // so we calculate it with the current seconds divided by the number of
    // seconds in a minute
    _secondAnimationController.forward(from: (DateTime
        .now()
        .second
        .toDouble() + DateTime.now().millisecond/1000)/60);

    _updateTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColour(_date),
      body: Center(
        child: Stack(
          children: [
            // The animated builder accepts an animation and then rebuilds its child
            // with the value from that animation.
            // We will use it to draw the Seconds pointer on the screen
            AnimatedBuilder(
              animation: _secondAnimationValue,
              builder: (context, widget) {
                // To draw a pointer in the screen, we will draw two points on the screen,
                // One that starts at the center and another one that is at the edge of the screen
                return CustomPaint(
                  painter: PointerPainter(MediaQuery
                      .of(context)
                      .size,
                      // We will get the complementary background colour by adding 12 hours
                      _getBackgroundColour(_date.add(Duration(hours: 12))), _secondAnimationValue.value ?? 0),
                );}
            ),
            Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // The expanded widget will ocuppy all the remaining space on the page
                  Expanded(
                    // The scale transition will help us animate the text when the time changes
                    child: ScaleTransition(
                      scale: _hourAnimationValue,
                      // the alignment feature will set where the center of the scale will be
                      alignment: Alignment.centerRight,
                      child: Text(
                        _date.hour.toString(), textAlign: TextAlign.right,
                        style: _getTextStyle(),
                      ),
                    ),
                  ),
                  Text(":", style: _getTextStyle(),),
                  Expanded(
                    child: ScaleTransition(
                      scale: _minuteAnimationValue,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _date.minute <= 9 ? "0${_date.minute}" : _date.minute
                            .toString(), textAlign: TextAlign
                          .left, style: _getTextStyle(),),
                    ),
                  ),
                ],
              )
            ],
          ),
          ]
        ),
      ),
    );
  }

  /// This method will update the current time set on the screen
  /// We will also use it to animate both the minutes text and the hours text, if
  /// needed
  void _updateTime() {
    // update minutes
    setState(() {
      print("setState called");
      _date = DateTime.now();
      // Update once per minute.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _date.second) -
            Duration(milliseconds: _date.millisecond),
        () {
          // when changing the minutes, we will display the animation for the minutes
          _minuteAnimationController.forward(from: 0);
          // Then, we will check if the minutes = 0, which means that we have passed 1 hour
          print(_date.minute.toString());
          if (_date.minute == 0) {
            _hourAnimationController.forward(from: 0);
          }
          _updateTime();
        },
      );
    });
    //update hour
  }


  @override
  void dispose() {
    super.dispose();
    _timer?.cancel(); //the same as `if (_timer != null) _timer.cancel`
  }

  /// The Text Style for the text used in the app
  TextStyle _getTextStyle() =>
      TextStyle(
          fontSize: 90,
          color: Colors.lightGreen,
          fontWeight: FontWeight.bold);

  /// This method will give us a background colour depending on the time of the day
  Color _getBackgroundColour(DateTime date) {
    double lerp;
    if (date.hour <= 4 || date.hour >= 21) {
      lerp = 0;
    } else if (date.hour >= 12 && date.hour <= 16) {
      lerp = 1;
    } else if (date.hour > 4 && date.hour < 12) {
      lerp = (date.hour - 4) / (12 - 4);
    } else {
      lerp = 1 - (date.hour - 16) / (21 - 16);
    }

    return Color.lerp(_darkColor, _lightColor, lerp);
  }
}

/// This class will paint a line that will serve as the pointer for the seconds
class PointerPainter extends CustomPainter {
  final Size canvasSize;
  final Color color;
  final double animationValue;

  PointerPainter(this.canvasSize, this.color, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final totalWidth = sqrt(pow(canvasSize.width/2, 2) + pow(canvasSize.height/2, 2));
    final angle = 2 * pi * animationValue / 60 - pi / 2;

    final p1 = Offset(cos(angle) * totalWidth + canvasSize.width / 2, sin(angle) * totalWidth + canvasSize.height / 2);
    final p2 = Offset(canvasSize.width / 2, canvasSize.height / 2);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

